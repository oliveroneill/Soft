import Foundation

/// A client that adds Spotify Authorization headers to each request
class SpotifyAuthorizedHTTPClient: HTTPClient {
    private let client: HTTPClient
    private let clientCredentials: SpotifyClientCredentials

    /// Create a SpotifyAuthorizedHTTPClient instance which will fetch
    /// credentials using the input clientCredentials and add them as
    /// authorization headers for requests
    ///
    /// - Parameters:
    ///   - client: This will be used for requests
    ///   - clientCredentials: Credentials will be added as authorization
    ///     headers to each request
    init(client: HTTPClient, clientCredentials: SpotifyClientCredentials) {
        self.client = client
        self.clientCredentials = clientCredentials
    }

    /// Retrieve the headers to be added to Spotify requests
    ///
    /// - Parameter completionHandler: Called with headers to be added or an
    ///   error if fetching token's fails
    private func getAuthorizationHeaders(completionHandler: @escaping (Result<[String:String]>) -> Void) {
        clientCredentials.fetchAccessToken { result in
            switch result {
            case .success(let token):
                let header = ["Authorization": "Bearer: \(token.accessToken)"]
                completionHandler(.success(header))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    func authenticationRequest(url: String, username: String, password: String,
                               parameters: [String:String],
                               completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        client.authenticationRequest(
            url: url, username: username, password: password,
            parameters: parameters, completionHandler: completionHandler
        )
    }

    func get(url: String, parameters: [String:String],
             headers: [String:String],
             completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        getAuthorizationHeaders { result in
            switch result {
            case .success(let authHeaders):
                self.client.get(
                    url: url, parameters: parameters,
                    headers: headers.merging(authHeaders) { $1 },
                    completionHandler: completionHandler
                )
            case .failure(let error):
                completionHandler(nil, nil, error)
            }
        }
    }

    func post(url: String, payload: Data,
              headers: [String:String],
              completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        getAuthorizationHeaders { result in
            switch result {
            case .success(let authHeaders):
                self.client.post(
                    url: url, payload: payload,
                    headers: headers.merging(authHeaders) { $1 },
                    completionHandler: completionHandler
                )
            case .failure(let error):
                completionHandler(nil, nil, error)
            }
        }
    }

    func put(url: String, payload: Data,
             headers: [String:String],
             completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        getAuthorizationHeaders { result in
            switch result {
            case .success(let authHeaders):
                self.client.put(
                    url: url, payload: payload,
                    headers: headers.merging(authHeaders) { $1 },
                    completionHandler: completionHandler
                )
            case .failure(let error):
                completionHandler(nil, nil, error)
            }
        }
    }

    func delete(url: String, payload: Data,
                headers: [String:String],
                completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        getAuthorizationHeaders { result in
            switch result {
            case .success(let authHeaders):
                self.client.delete(
                    url: url, payload: payload,
                    headers: headers.merging(authHeaders) { $1 },
                    completionHandler: completionHandler
                )
            case .failure(let error):
                completionHandler(nil, nil, error)
            }
        }
    }
}
