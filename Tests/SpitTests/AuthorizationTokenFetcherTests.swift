import XCTest
@testable import Spit

final class SpotifyTokenFetcherTests: XCTestCase {
    /// A good response with 200 status code used for testing status code
    /// handling
    let goodResponse = HTTPURLResponse(
        url: URL(string: "http://used.for/response")!, statusCode: 200,
        httpVersion: nil, headerFields: [:]
    )
    /// A failure response with 404 status code used for testing status code
    /// handling
    let badResponse = HTTPURLResponse(
        url: URL(string: "http://used.for/response")!, statusCode: 404,
        httpVersion: nil, headerFields: [:]
    )
    // Test input data
    let clientID = "client-id-123"
    let clientSecret = "A_SECRET_KEY"
    let headers = ["test_key": "test_val", "x": "y"]
    let accessToken = "token-123"
    let tokenType = "Bearer"
    let scope = "client"
    let refreshToken = "refresh-344"
    let expiresIn = 24

    /// JSON Data created from the input data. This will be set in the setUp
    /// function
    var jsonData = Data()

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
        jsonData = d
    }

    /// Fake HTTP Client for mocking network interaction
    class FakeClient: HTTPClient {
        private let expected: (Data?, HTTPURLResponse?, Error?)
        /// Keeps track of calls to authenticationRequest
        var calls: [(url: String, username: String, password: String, headers: [String : String])] = []

        /// Create a fake network interface
        ///
        /// - Parameter expected: This will be returned via
        /// authenticationRequest's completionHandler
        init(expected: (Data?, HTTPURLResponse?, Error?)) {
            self.expected = expected
        }

        func authenticationRequest(url: String, username: String,
                                   password: String, headers: [String : String],
                                   completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
            calls.append((url, username, password, headers))
            completionHandler(expected.0, expected.1, expected.2)
        }
    }

    /// A fake error for testing purposes
    ///
    /// - testError: An arbitrary error case
    enum FakeError: Error {
        case testError
    }

    func testFetchAccessToken() {
        // Given
        // Create a fake client that returns valid JSON data and a
        // successful response
        let fakeClient = FakeClient(expected: (jsonData, goodResponse, nil))
        let fetcher = SpotifyTokenFetcher(httpClient: fakeClient)
        // When
        fetcher.fetchAccessToken(clientID: clientID,
                                 clientSecret: clientSecret,
                                 headers: headers) { result in
            // Then
            // Ensure a successful result
            switch result {
            case .success(let tokenInfo):
                // Ensure token info matches input
                XCTAssertEqual(self.accessToken, tokenInfo.accessToken)
                XCTAssertEqual(self.tokenType, tokenInfo.tokenType)
                XCTAssertEqual(self.scope, tokenInfo.scope)
                XCTAssertEqual(self.refreshToken, tokenInfo.refreshToken)
                // Ensure that the network call uses the correct input
                XCTAssertEqual(self.clientID, fakeClient.calls[0].username)
                XCTAssertEqual(
                    self.clientSecret,
                    fakeClient.calls[0].password
                )
                XCTAssertEqual(
                    self.headers,
                    fakeClient.calls[0].headers
                )
            case .failure(let error):
                XCTFail("Unexpected failure: \(error)")
            }
        }
    }

    func testFetchAccessTokenNetworkError() {
        // Given
        let expectedError = FakeError.testError
        // Client returns an error
        let fakeClient = FakeClient(expected: (nil, nil, expectedError))
        let fetcher = SpotifyTokenFetcher(httpClient: fakeClient)
        // When
        fetcher.fetchAccessToken(clientID: clientID,
                                 clientSecret: clientSecret,
                                 headers: headers) { result in
            // Then
            switch result {
            case .success(_):
                // Ensure failure occurs
                XCTFail("Unexpected success")
            case .failure(let error):
                // Ensure error is as expected
                XCTAssertEqual(expectedError, error as? FakeError)
                // Ensure that the call used the correct input
                XCTAssertEqual(self.clientID, fakeClient.calls[0].username)
                XCTAssertEqual(
                    self.clientSecret,
                    fakeClient.calls[0].password
                )
                XCTAssertEqual(
                    self.headers,
                    fakeClient.calls[0].headers
                )
            }
        }
    }

    func testFetchAccessTokenNilBody() {
        // Given
        // The network will give a good response and a nil response body
        let fakeClient = FakeClient(expected: (nil, goodResponse, nil))
        let fetcher = SpotifyTokenFetcher(httpClient: fakeClient)
        // When
        fetcher.fetchAccessToken(clientID: clientID,
                                 clientSecret: clientSecret,
                                 headers: headers) { result in
            // Then
            switch result {
            case .success(_):
                // Ensure failure occurs
                XCTFail("Unexpected success")
            case .failure(let error):
                // Ensure error is as expected
                guard case .nilBody? = error as? SpotifyAPIError else {
                    XCTFail("Expected nil body error. Received \(error)")
                    return
                }
                // Ensure that the call used the correct input
                XCTAssertEqual(self.clientID, fakeClient.calls[0].username)
                XCTAssertEqual(
                    self.clientSecret,
                    fakeClient.calls[0].password
                )
                XCTAssertEqual(
                    self.headers,
                    fakeClient.calls[0].headers
                )
            }
        }
    }

    func testFetchAccessTokenInvalidResponse() {
        // Given
        // The network will return a 404
        let fakeClient = FakeClient(expected: (nil, badResponse, nil))
        let fetcher = SpotifyTokenFetcher(httpClient: fakeClient)
        // When
        fetcher.fetchAccessToken(clientID: clientID,
                                 clientSecret: clientSecret,
                                 headers: headers) { result in
            // Then
            switch result {
            case .success(_):
                XCTFail("Unexpected success")
            case .failure(let error):
                // Ensure error is as expected
                guard case .invalidResponse? = error as? SpotifyAPIError else {
                    XCTFail("Expected nil body error. Received \(error)")
                    return
                }
                // Ensure that the call used the correct input
                XCTAssertEqual(self.clientID, fakeClient.calls[0].username)
                XCTAssertEqual(
                    self.clientSecret,
                    fakeClient.calls[0].password
                )
                XCTAssertEqual(
                    self.headers,
                    fakeClient.calls[0].headers
                )
            }
        }
    }
}
