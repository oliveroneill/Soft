import Foundation

import SwiftyRequest

/// A protocol for making HTTP requests
protocol HTTPClient {
    /// Send a POST request with the specified username and password
    ///
    /// - Parameters:
    ///   - url: The URL to send to
    ///   - username: Username for authentication
    ///   - password: Password for authentication
    ///   - parameters: Query parameters
    ///   - completionHandler: Called with the response
    func authenticationRequest(url: String, username: String, password: String,
                               parameters: [String:String],
                               completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
}

/// An implementation of HTTPClient using SwiftyRequest
class SwiftyRequestClient: HTTPClient {
    func authenticationRequest(url: String, username: String, password: String,
                               parameters: [String : String],
                               completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let request = RestRequest(method: .post, url: url)
        request.credentials = .basicAuthentication(
            username: username,
            password: password
        )
        request.queryItems = parameters.map {URLQueryItem(name: $0, value: $1)}
        request.contentType = "application/x-www-form-urlencoded"
        request.response(completionHandler: completionHandler)
    }
}
