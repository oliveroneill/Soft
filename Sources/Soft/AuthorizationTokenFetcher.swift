import Foundation

private let apiURL = "https://accounts.spotify.com/api/token"

/// Interface for retrieving an access token
protocol AuthorizationTokenFetcher {
    /// Fetch an access token
    ///
    /// - Parameter completionHandler: Called with the result of the API call
    func fetchAccessToken(clientID: String, clientSecret: String,
                          headers: [String:String],
                          completionHandler: @escaping (FetchTokenResult) -> Void)
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
public enum FetchTokenResult {
    case success(TokenInfo)
    case failure(Error)
}

/// Used to get an access token from the Spotify API
class SpotifyTokenFetcher: AuthorizationTokenFetcher {
    private let httpClient: HTTPClient

    /// Create a SpotifyTokenFetcher
    ///
    /// - Parameter httpClient: To be used for HTTP requests
    init(httpClient: HTTPClient = SwiftyRequestClient()) {
        self.httpClient = httpClient
    }

    /// Fetch an access token from the Spotify API
    ///
    /// - Parameter completionHandler: Called with the result of the API call
    func fetchAccessToken(clientID: String, clientSecret: String,
                          headers: [String:String],
                          completionHandler: @escaping (FetchTokenResult) -> Void) {
        // Make the request
        httpClient.authenticationRequest(
            url: apiURL, username: clientID, password: clientSecret,
            // Specify the grant type
            headers: headers
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
                let tokenInfo = try TokenInfo.fromSpotify(data: jsonData)
                completionHandler(.success(tokenInfo))
            } catch {
                // Handle JSON error
                completionHandler(.failure(error))
            }
        }
    }
}
