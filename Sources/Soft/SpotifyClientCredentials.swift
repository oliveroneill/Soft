import Foundation

/// An error when credentials are initialised incorrectly
///
/// - emptyInput: Thrown when the clientID or clientSecret are empty strings
enum InvalidCredentialsError: Error {
    case emptyInput
}

/// Holds client credentials. Used for gaining access tokens
struct SpotifyClientCredentials {
    let clientID: String
    let clientSecret: String

    private let fetcher: AuthorizationTokenFetcher

    /// Create a SpotifyClientCredentials instance
    ///
    /// - Parameters:
    ///   - clientID: Spotify Client ID
    ///   - clientSecret: Spotify Client Secret
    ///   - fetcher: Optional token fetcher implementation. Defaults to
    ///   SpotifyTokenFetcher
    /// - Throws: If clientID or clientSecret are empty strings
    init(clientID: String, clientSecret: String,
         fetcher: AuthorizationTokenFetcher = SpotifyTokenFetcher()) throws {
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
    func fetchAccessToken(completionHandler: @escaping (FetchTokenResult) -> Void) {
        fetcher.fetchAccessToken(
            clientID: clientID,
            clientSecret: clientSecret,
            headers: ["grant_type": "client_credentials"],
            completionHandler: completionHandler
        )
    }
}
