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

    func get(url: String, parameters: [String:String],
             headers: [String:String],
             completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)

    func post(url: String, payload: Data,
              headers: [String:String],
              completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)

    func put(url: String, payload: Data,
             headers: [String:String],
             completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)

    func delete(url: String, payload: Data,
                headers: [String:String],
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

    func get(url: String, parameters: [String:String],
             headers: [String:String],
             completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let request = RestRequest(method: .get, url: url)
        if parameters.count > 0 {
            request.queryItems = parameters.map {URLQueryItem(name: $0, value: $1)}
        }
        request.headerParameters = headers
        request.contentType = "application/json"
        request.response(completionHandler: completionHandler)
    }

    func post(url: String, payload: Data,
              headers: [String:String],
              completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let request = RestRequest(method: .post, url: url)
        request.messageBody = payload
        request.headerParameters = headers
        request.contentType = "application/json"
        request.response(completionHandler: completionHandler)
    }

    func put(url: String, payload: Data,
             headers: [String:String],
             completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let request = RestRequest(method: .put, url: url)
        request.messageBody = payload
        request.headerParameters = headers
        request.contentType = "application/json"
        request.response(completionHandler: completionHandler)
    }

    func delete(url: String, payload: Data,
                headers: [String:String],
                completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let request = RestRequest(method: .delete, url: url)
        request.messageBody = payload
        request.headerParameters = headers
        request.contentType = "application/json"
        request.response(completionHandler: completionHandler)
    }
}
