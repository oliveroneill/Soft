import Foundation

/// An error when credentials are initialised incorrectly
///
/// - emptyInput: Thrown when the clientID or clientSecret are empty strings
enum InvalidCredentialsError: Error {
    case emptyInput
}

/// Errors from Spotify API errors
///
/// - nilResponse: The response object was nil
/// - invalidResponse: The status code was not 200
/// - nilBody: The response body was nil
enum SpotifyAPIError: Error {
    case nilResponse
    case invalidResponse(HTTPURLResponse)
    case nilBody
}

/// A result type for fetchAccessToken
///
/// - success: When the call succeeds, this will contain the deserialised token
/// information
/// - failure: When the call fails, this will contain the error
enum FetchTokenResult {
    case success(TokenInfo)
    case failure(Error)
}

/// Holds client credentials. Used for gaining access tokens
struct SpotifyClientCredentials {
    let clientID: String
    let clientSecret: String

    private let apiURL = "https://accounts.spotify.com/api/token"
    private let httpClient: HTTPClient

    /// Create a SpotifyClientCredentials instance
    ///
    /// - Parameters:
    ///   - clientID: Spotify Client ID
    ///   - clientSecret: Spotify Client Secret
    ///   - httpClient: Optional client for making network requests
    /// - Throws: If clientID or clientSecret are empty strings
    init(clientID: String, clientSecret: String,
         httpClient: HTTPClient = SwiftyRequestClient()) throws {
        guard !clientID.isEmpty && !clientSecret.isEmpty else {
            throw InvalidCredentialsError.emptyInput
        }
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.httpClient = httpClient
    }

    /// Fetch an access token from the Spotify API
    ///
    /// - Parameter completionHandler: Called with the result of the API call
    func fetchAccessToken(completionHandler: @escaping (FetchTokenResult) -> Void) {
        // Make the request
        httpClient.authenticationRequest(
            url: apiURL, username: clientID, password: clientSecret,
            // Specify the grant type
            headers: ["grant_type": "client_credentials"]
        ) { body, response, error in
            // If there is an error then fail
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            // Ensure that response is not nil as we will validate the status
            // code
            guard let response = response else {
                completionHandler(.failure(SpotifyAPIError.nilResponse))
                return
            }
            // Ensure the response is a success
            guard response.statusCode == 200 else {
                completionHandler(.failure(SpotifyAPIError.invalidResponse(response)))
                return
            }
            // Ensure that there is a response body
            guard let jsonData = body else {
                completionHandler(.failure(SpotifyAPIError.nilBody))
                return
            }
            do {
                // Parse the JSON response
                let tokenInfo = try TokenInfo.fromJSON(data: jsonData)
                completionHandler(.success(tokenInfo))
            } catch {
                // Handle JSON error
                completionHandler(.failure(error))
            }
        }
    }
}

/// Authorization for spotify
struct SpotifyOAuth {
    let clientID: String
    let clientSecret: String
    let redirectURI: String
    let state: String
    let cachePath: URL
    let scope: String
    let proxies: String?
}

/// Spotify token-info
struct TokenInfo: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let expiresAt: Date?
    let refreshToken: String?

    /// The keys coming from the network. These are slightly different to
    /// the struct variables as we convert expiresIn to a date called expiresAt
    private enum CodingKeys: String, CodingKey {
        case accessToken, tokenType, scope, expiresIn, refreshToken
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        tokenType = try container.decode(String.self, forKey: .tokenType)
        scope = try container.decode(String.self, forKey: .scope)
        // Allow nil value for refreshToken
        refreshToken = try? container.decode(String.self, forKey: .refreshToken)
        // Convert expiresIn to a Date for convenience
        let expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        expiresAt = Date().addingTimeInterval(TimeInterval(expiresIn))
    }

    /// Convert Data containing JSON to a TokenInfo instance
    ///
    /// - Parameter data: JSON data
    /// - Returns: A TokenInfo instance containing info from the deserialised
    /// JSON data
    /// - Throws: If decoding fails
    static func fromJSON(data: Data) throws -> TokenInfo {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(
            TokenInfo.self,
            from: data
        )
    }
}
