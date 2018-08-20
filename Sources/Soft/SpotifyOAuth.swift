import Foundation

/// Specifies the scope of Spotify Authorization
typealias Scope = String

extension Scope {
    /// Whether the specified scope is a subset of self
    ///
    /// - Parameter scope: The scope that may or may not be a subset
    /// - Returns: Whether the specified scope is contained within this one
    func isSubset(of scope: Scope) -> Bool {
        let needle = Set(split(separator: " "))
        let haystack = Set(scope.split(separator: " "))
        return needle.isSubset(of: haystack)
    }
}

/// Errors related to retrieving a cached token
///
/// - mismatchScope: If the cached token has a different scope to specified
/// - noRefreshToken: If refresh token is not specified and the cached token
///   is expired
enum CachedTokenError: Error {
    case mismatchScope
    case noRefreshToken
}

/// Errors related to building the authorization URL
///
/// - invalidQueryParams: Query parameters were invalid
/// - invalidURL: The URL was invalid
enum AuthorizationURLError: Error {
    case invalidQueryParams
    case invalidURL
}

/// Authorization for spotify
struct SpotifyOAuth {
    let clientID: String
    let clientSecret: String
    let redirectURI: URL
    let state: String
    let cachePath: URL
    let scope: Scope
    private let fetcher: AuthorizationTokenFetcher
    private let fileHandler: FileHandler

    /// Create a SpotifyOAuth instance
    ///
    /// - Parameters:
    ///   - clientID: Spotify Client ID
    ///   - clientSecret: Spotify Client Secret
    ///   - redirectURI: Specify the URI that the request will be redirected to
    ///   upon completion
    ///   - state: Used for correlating requests and responses
    ///   - scope: The scope of authorization
    ///   - cachePath: Optionally specify where cached tokens should be stored
    ///   and retrieved
    ///   - fetcher: Optional token fetcher implementation. Defaults to
    ///   SpotifyTokenFetcher
    /// - Throws: If clientID or clientSecret are empty strings
    init(clientID: String, clientSecret: String, redirectURI: URL,
         state: String, scope: Scope,
         cachePath: URL = URL(fileURLWithPath: ".spotify_token_cache.json"),
         fetcher: AuthorizationTokenFetcher = SpotifyTokenFetcher(),
         fileHandler: FileHandler = DataFileHandler()) throws {
        guard !clientID.isEmpty && !clientSecret.isEmpty else {
            throw InvalidCredentialsError.emptyInput
        }
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
        self.state = state
        self.cachePath = cachePath
        self.scope = scope
        self.fetcher = fetcher
        self.fileHandler = fileHandler
    }

    /// Get cached API token. This may refresh the cached token if necessary.
    /// Errors can be found in CachedTokenError.
    ///
    /// - Parameter completionHandler: Called with the result
    func getCachedToken(completionHandler: @escaping (FetchTokenResult) -> Void) {
        do {
            let data = try fileHandler.read(from: cachePath)
            let info = try TokenInfo.fromJSON(data: data)
            // Check that the scope matches expected
            guard scope.isSubset(of: info.scope) else {
                completionHandler(.failure(CachedTokenError.mismatchScope))
                return
            }
            // Check if the cached token is expired
            guard info.isExpired else {
                completionHandler(.success(info))
                return
            }
            guard let refreshToken = info.refreshToken else {
                completionHandler(.failure(CachedTokenError.noRefreshToken))
                return
            }
            // Refresh token
            refreshAccessToken(
                refreshToken: refreshToken,
                completionHandler: completionHandler
            )
        } catch {
            completionHandler(.failure(error))
        }
    }

    /// Refresh a token
    ///
    /// - Parameters:
    ///   - refreshToken: The refresh token from the Spotify API response
    ///   - completionHandler: Called upon completion of refresh
    private func refreshAccessToken(refreshToken: String,
                                    completionHandler: @escaping (FetchTokenResult) -> Void) {
        let payload = [
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ]
        fetcher.fetchAccessToken(
            clientID: clientID, clientSecret: clientSecret, headers: payload,
            completionHandler: completionHandler
        )
    }

    /// Fetch an access token
    ///
    /// - Parameters:
    ///   - code: Authorization code
    ///   - completionHandler: Called upon completion
    func fetchAccessToken(code: String,
                          completionHandler: @escaping (FetchTokenResult) -> Void) {
        let payload = [
            "redirect_uri": redirectURI.absoluteString,
            "code": code,
            "grant_type": "authorization_code",
            "scope": scope,
            "state": state
        ]
        fetcher.fetchAccessToken(
            clientID: clientID, clientSecret: clientSecret, headers: payload,
            completionHandler: {result in
                switch result {
                case .success(let info):
                    do {
                        // Save token if we were successful
                        try self.saveToken(tokenInfo: info)
                        completionHandler(.success(info))
                    } catch {
                        completionHandler(.failure(error))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
        })
    }

    /// Save token in cache location
    ///
    /// - Parameter tokenInfo: The token to store
    /// - Throws: If the write was unsuccessful
    private func saveToken(tokenInfo: TokenInfo) throws {
        try fileHandler.write(data: tokenInfo.toJSON(), to: cachePath)
    }

    /// Parse URL to retrieve code for authorization
    ///
    /// - Parameter url: URL redirected to as a response to authorization
    /// request
    /// - Returns: The code or nil if there was no code present
    static func parseResponseCode(url: String) -> String? {
        let components = url.components(separatedBy: "?code=")
        guard components.count > 1 else {
            return nil
        }
        let remainder = components[1]
        guard let code = remainder.split(separator: "&").first else {
            return nil
        }
        return String(code)
    }

    /// Gets the URL to use to authorize this app
    ///
    /// - Parameters:
    ///   - state: Optional state parameter. The state on self will be used
    ///   otherwise
    ///   - showDialog:
    /// - Returns: URL to request authorization for this OAuth object
    /// - Throws: If an error occurs while creating the URL
    func getAuthorizeURL(state: String? = nil, showDialog: Bool = false) throws -> URL {
        var payload: [String:String] = [
            "client_id": clientID,
            "response_type": "code",
            "redirect_uri": redirectURI.absoluteString,
            "scope": scope
        ]
        payload["state"] = state ?? self.state
        if showDialog {
            payload["show_dialog"] = "true"
        }
        var components = URLComponents()
        components.queryItems = payload.map {
            URLQueryItem(name: $0, value: $1.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))
        }
        guard let queryString = components.query else {
            throw AuthorizationURLError.invalidQueryParams
        }
        let authorizeURL = "https://accounts.spotify.com/authorize?" + queryString
        guard let url = URL(string: authorizeURL) else {
            throw AuthorizationURLError.invalidURL
        }
        return url
    }
}
