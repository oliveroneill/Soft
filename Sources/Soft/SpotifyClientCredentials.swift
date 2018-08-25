import Foundation

/// An error when credentials are initialised incorrectly
///
/// - emptyInput: Thrown when the clientID or clientSecret are empty strings
enum InvalidCredentialsError: Error {
    case emptyInput
}

/// Holds client credentials. Used for gaining access tokens
public struct SpotifyClientCredentials {
    let clientID: String
    let clientSecret: String

    private let fetcher: AuthorizationTokenFetcher

    /// Create a SpotifyClientCredentials instance
    ///
    /// - Parameters:
    ///   - clientID: Spotify Client ID
    ///   - clientSecret: Spotify Client Secret
    /// - Throws: If clientID or clientSecret are empty strings
    public init(clientID: String, clientSecret: String) throws {
        try self.init(
            clientID: clientID, clientSecret: clientSecret,
            fetcher: SpotifyTokenFetcher()
        )
    }

    /// Create a SpotifyClientCredentials instance
    ///
    /// - Parameters:
    ///   - clientID: Spotify Client ID
    ///   - clientSecret: Spotify Client Secret
    ///   - fetcher: Optional token fetcher implementation. Defaults to
    ///   SpotifyTokenFetcher
    /// - Throws: If clientID or clientSecret are empty strings
    init(clientID: String, clientSecret: String,
         fetcher: AuthorizationTokenFetcher) throws {
        guard !clientID.isEmpty && !clientSecret.isEmpty else {
            throw InvalidCredentialsError.emptyInput
        }
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.fetcher = fetcher
    }

    /// Request access token from Spotify API
    ///
    /// - Parameter completionHandler: Called upon completion
    func fetchAccessToken(completionHandler: @escaping (Result<TokenInfo>) -> Void) {
        fetcher.fetchAccessToken(
            clientID: clientID,
            clientSecret: clientSecret,
            parameters: ["grant_type": "client_credentials"],
            completionHandler: completionHandler
        )
    }
}
