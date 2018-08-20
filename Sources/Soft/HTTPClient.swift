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
    ///   - headers: Request headers
    ///   - completionHandler: Called with the response
    func authenticationRequest(url: String, username: String, password: String,
                               headers: [String:String],
                               completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
}

/// An implementation of HTTPClient using SwiftyRequest
class SwiftyRequestClient: HTTPClient {
    func authenticationRequest(url: String, username: String, password: String,
                               headers: [String : String],
                               completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let request = RestRequest(method: .post, url: url)
        request.credentials = .basicAuthentication(
            username: username,
            password: password
        )
        request.headerParameters = headers
        request.response(completionHandler: completionHandler)
    }
}
