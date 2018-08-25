import XCTest
@testable import Soft

final class SpotifyAuthorizedHTTPClientTests: XCTestCase {
    // Test input data
    let accessToken = "token-123"
    let tokenType = "Bearer"
    let scope = "client"
    let refreshToken = "refresh-344"
    let expiresIn = 24

    // Token created in setUp
    var token: TokenInfo!
    var networkResponse: (Data?, HTTPURLResponse?, Error?)!
    var response: HTTPURLResponse!
    let data = Data(bytes: [12, 22, 43, 1, 90])
    let payload = Data(bytes: [44, 12, 63, 10, 99])
    let urlString = "http://y.com/"
    let url = URL(string: "http://x.com/")!
    let headers = ["a":"header", "x":"y"]
    let parameters = ["xyz":"123", "param":"x"]

    enum TestError: Error {
        case error
    }

    override func setUp() {
        // Create string from test input data
        let json = """
        {
        "access_token": "\(accessToken)",
        "token_type": "\(tokenType)",
        "scope": "\(scope)",
        "refresh_token": "\(refreshToken)",
        "expires_in": \(expiresIn)
        }
        """
        // Convert to data and fail if not possible
        guard let d = json.data(using: .utf8) else {
            XCTFail("Unable to convert string to bytes")
            return
        }
        // Token is created using fromSpotify since it does not have an init
        token = try! TokenInfo.fromSpotify(data: d)
        response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        networkResponse = (data, response, TestError.error)
    }

    /// Fake HTTP Client for mocking network interaction
    class FakeClient: HTTPClient {
        private let expected: (Data?, HTTPURLResponse?, Error?)
        var numCallsAuthenticationRequest = 0
        var getCalls: [(url: String, parameters: [String:String], headers: [String : String])] = []
        var postCalls: [(url: String, payload: Data, headers: [String : String])] = []
        var putCalls: [(url: String, payload: Data, headers: [String : String])] = []
        var deleteCalls: [(url: String, payload: Data, headers: [String : String])] = []

        /// Create a fake network interface
        ///
        /// - Parameter expected: This will be returned via
        /// authenticationRequest's completionHandler
        init(expected: (Data?, HTTPURLResponse?, Error?)) {
            self.expected = expected
        }

        func authenticationRequest(url: String, username: String,
                                   password: String,
                                   parameters: [String : String],
                                   completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
            numCallsAuthenticationRequest += 1
        }

        func get(url: String, parameters: [String:String],
                 headers: [String : String],
                 completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
            getCalls.append((url: url, parameters: parameters, headers: headers))
            completionHandler(expected.0, expected.1, expected.2)
        }

        func post(url: String, payload: Data,
                  headers: [String : String],
                  completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
            postCalls.append((url: url, payload: payload, headers: headers))
            completionHandler(expected.0, expected.1, expected.2)
        }
        func put(url: String, payload: Data,
                 headers: [String : String],
                 completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
            putCalls.append((url: url, payload: payload, headers: headers))
            completionHandler(expected.0, expected.1, expected.2)
        }

        func delete(url: String, payload: Data,
                    headers: [String : String],
                    completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
            deleteCalls.append((url: url, payload: payload, headers: headers))
            completionHandler(expected.0, expected.1, expected.2)
        }
    }

    /// Fake token fetcher for mocking network interaction
    class FakeTokenFetcher: AuthorizationTokenFetcher {
        /// Keeps track of calls to fetchAccessToken
        private let result: Result<TokenInfo>

        /// Create a FakeTokenFetcher
        ///
        /// - Parameter result: The result to be returned from fetchAccessToken
        init(result: Result<TokenInfo>) {
            self.result = result
        }

        func fetchAccessToken(clientID: String, clientSecret: String,
                              parameters: [String : String],
                              completionHandler: @escaping (Result<TokenInfo>) -> Void) {
            completionHandler(result)
        }
    }
    
    func testGet() {
        do {
            let clientCredentials = try SpotifyClientCredentials(
                clientID: "client-id", clientSecret: "client-secret",
                fetcher: FakeTokenFetcher(result: .success(token))
            )
            let fakeClient = FakeClient(expected: networkResponse)
            let client = SpotifyAuthorizedHTTPClient(
                client: fakeClient,
                clientCredentials: clientCredentials
            )
            let expectedHeaders = [
                "a":"header", "x":"y",
                "Authorization": "Bearer: \(accessToken)"
            ]
            client.get(url: urlString, parameters: parameters, headers: headers) {
                (data, response, error) in
                // Verify HTTP client is called correctly
                XCTAssertEqual(self.urlString, fakeClient.getCalls.first?.url)
                XCTAssertEqual(self.parameters, fakeClient.getCalls.first?.parameters)
                XCTAssertEqual(expectedHeaders, fakeClient.getCalls.first?.headers)
                // Verify the response is as expected
                XCTAssertEqual(self.networkResponse.0, data)
                XCTAssertEqual(self.networkResponse.1, response)
                XCTAssertEqual(self.networkResponse.2 as? TestError, error as? TestError)
                // Verify other client requests are not made
                XCTAssertEqual(0, fakeClient.numCallsAuthenticationRequest)
                XCTAssertEqual(0, fakeClient.postCalls.count)
                XCTAssertEqual(0, fakeClient.putCalls.count)
                XCTAssertEqual(0, fakeClient.deleteCalls.count)
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testPost() {
        do {
            let clientCredentials = try SpotifyClientCredentials(
                clientID: "client-id", clientSecret: "client-secret",
                fetcher: FakeTokenFetcher(result: .success(token))
            )
            let fakeClient = FakeClient(expected: networkResponse)
            let client = SpotifyAuthorizedHTTPClient(
                client: fakeClient,
                clientCredentials: clientCredentials
            )
            let expectedHeaders = [
                "a":"header", "x":"y",
                "Authorization": "Bearer: \(accessToken)"
            ]
            client.post(url: urlString, payload: payload, headers: headers) {
                (data, response, error) in
                // Verify HTTP client is called correctly
                XCTAssertEqual(self.urlString, fakeClient.postCalls.first?.url)
                XCTAssertEqual(self.payload, fakeClient.postCalls.first?.payload)
                XCTAssertEqual(expectedHeaders, fakeClient.postCalls.first?.headers)
                // Verify the response is as expected
                XCTAssertEqual(self.networkResponse.0, data)
                XCTAssertEqual(self.networkResponse.1, response)
                XCTAssertEqual(self.networkResponse.2 as? TestError, error as? TestError)
                // Verify other client requests are not made
                XCTAssertEqual(0, fakeClient.numCallsAuthenticationRequest)
                XCTAssertEqual(0, fakeClient.getCalls.count)
                XCTAssertEqual(0, fakeClient.putCalls.count)
                XCTAssertEqual(0, fakeClient.deleteCalls.count)
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testPut() {
        do {
            let clientCredentials = try SpotifyClientCredentials(
                clientID: "client-id", clientSecret: "client-secret",
                fetcher: FakeTokenFetcher(result: .success(token))
            )
            let fakeClient = FakeClient(expected: networkResponse)
            let client = SpotifyAuthorizedHTTPClient(
                client: fakeClient,
                clientCredentials: clientCredentials
            )
            let expectedHeaders = [
                "a":"header", "x":"y",
                "Authorization": "Bearer: \(accessToken)"
            ]
            client.put(url: urlString, payload: payload, headers: headers) {
                (data, response, error) in
                // Verify HTTP client is called correctly
                XCTAssertEqual(self.urlString, fakeClient.putCalls.first?.url)
                XCTAssertEqual(self.payload, fakeClient.putCalls.first?.payload)
                XCTAssertEqual(expectedHeaders, fakeClient.putCalls.first?.headers)
                // Verify the response is as expected
                XCTAssertEqual(self.networkResponse.0, data)
                XCTAssertEqual(self.networkResponse.1, response)
                XCTAssertEqual(self.networkResponse.2 as? TestError, error as? TestError)
                // Verify other client requests are not made
                XCTAssertEqual(0, fakeClient.numCallsAuthenticationRequest)
                XCTAssertEqual(0, fakeClient.getCalls.count)
                XCTAssertEqual(0, fakeClient.postCalls.count)
                XCTAssertEqual(0, fakeClient.deleteCalls.count)
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testDelete() {
        do {
            let clientCredentials = try SpotifyClientCredentials(
                clientID: "client-id", clientSecret: "client-secret",
                fetcher: FakeTokenFetcher(result: .success(token))
            )
            let fakeClient = FakeClient(expected: networkResponse)
            let client = SpotifyAuthorizedHTTPClient(
                client: fakeClient,
                clientCredentials: clientCredentials
            )
            let expectedHeaders = [
                "a":"header", "x":"y",
                "Authorization": "Bearer: \(accessToken)"
            ]
            client.delete(url: urlString, payload: payload, headers: headers) {
                (data, response, error) in
                // Verify HTTP client is called correctly
                XCTAssertEqual(self.urlString, fakeClient.deleteCalls.first?.url)
                XCTAssertEqual(self.payload, fakeClient.deleteCalls.first?.payload)
                XCTAssertEqual(expectedHeaders, fakeClient.deleteCalls.first?.headers)
                // Verify the response is as expected
                XCTAssertEqual(self.networkResponse.0, data)
                XCTAssertEqual(self.networkResponse.1, response)
                XCTAssertEqual(self.networkResponse.2 as? TestError, error as? TestError)
                // Verify other client requests are not made
                XCTAssertEqual(0, fakeClient.numCallsAuthenticationRequest)
                XCTAssertEqual(0, fakeClient.getCalls.count)
                XCTAssertEqual(0, fakeClient.postCalls.count)
                XCTAssertEqual(0, fakeClient.putCalls.count)
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
