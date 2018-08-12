import XCTest
@testable import Spit

final class OAuthTests: XCTestCase {
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

    func testSpotifyClientCredentialsInvalidInput() {
        // Ensure it fails on empty strings
        do {
            _ = try SpotifyClientCredentials(clientID: "", clientSecret: "")
            XCTFail("Expected failure")
        } catch {
            XCTAssertEqual(
                InvalidCredentialsError.emptyInput,
                error as? InvalidCredentialsError
            )
        }
    }

    func testSpotifyClientCredentialsValidInput() {
        // Ensure it passes on strings that are not empty
        do {
            _ = try SpotifyClientCredentials(
                clientID: clientID,
                clientSecret: clientSecret
            )
        } catch {
            XCTFail("Unexpected failure \(error)")
        }
    }

    func testFromJSON() {
        do {
            // Deserialised test input JSON data
            let tokenInfo = try TokenInfo.fromJSON(data: jsonData)
            // Ensure that the result matches the input
            XCTAssertEqual(accessToken, tokenInfo.accessToken)
            XCTAssertEqual(tokenType, tokenInfo.tokenType)
            XCTAssertEqual(scope, tokenInfo.scope)
            XCTAssertEqual(refreshToken, tokenInfo.refreshToken)
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testFromJSONMissingRefreshToken() {
        // JSON data that does not contain refresh_token since it is an optional
        // field
        let json = """
        {
            "access_token": "\(accessToken)",
            "token_type": "\(tokenType)",
            "scope": "\(scope)",
            "expires_in": \(expiresIn)
        }
        """
        guard let jsonData = json.data(using: .utf8) else {
            XCTFail("Unable to convert string to bytes")
            return
        }
        do {
            let tokenInfo = try TokenInfo.fromJSON(data: jsonData)
            // Ensure all other input values are set correctly
            XCTAssertEqual(accessToken, tokenInfo.accessToken)
            XCTAssertEqual(tokenType, tokenInfo.tokenType)
            XCTAssertEqual(scope, tokenInfo.scope)
            // Expect refresh token to be nil since it is not set
            XCTAssertNil(tokenInfo.refreshToken)
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
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
        do {
            // Given
            // Create a fake client that returns valid JSON data and a
            // successful response
            let fakeClient = FakeClient(expected: (jsonData, goodResponse, nil))
            let credentials = try SpotifyClientCredentials(
                clientID: clientID,
                clientSecret: clientSecret,
                httpClient: fakeClient
            )
            // When
            credentials.fetchAccessToken { result in
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
                case .failure(let error):
                    XCTFail("Unexpected failure: \(error)")
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testFetchAccessTokenNetworkError() {
        do {
            // Given
            let expectedError = FakeError.testError
            // Client returns an error
            let fakeClient = FakeClient(expected: (nil, nil, expectedError))
            let credentials = try SpotifyClientCredentials(
                clientID: clientID,
                clientSecret: clientSecret,
                httpClient: fakeClient
            )
            // When
            credentials.fetchAccessToken { result in
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
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testFetchAccessTokenNilBody() {
        do {
            // Given
            // The network will give a good response and a nil response body
            let fakeClient = FakeClient(expected: (nil, goodResponse, nil))
            let credentials = try SpotifyClientCredentials(
                clientID: clientID,
                clientSecret: clientSecret,
                httpClient: fakeClient
            )
            // When
            credentials.fetchAccessToken { result in
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
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testFetchAccessTokenInvalidResponse() {
        do {
            // Given
            // The network will return a 404
            let fakeClient = FakeClient(expected: (nil, badResponse, nil))
            let credentials = try SpotifyClientCredentials(
                clientID: clientID,
                clientSecret: clientSecret,
                httpClient: fakeClient
            )
            // When
            credentials.fetchAccessToken { result in
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
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    static var allTests = [
        ("testSpotifyClientCredentialsInvalidInput", testSpotifyClientCredentialsInvalidInput),
        ("testSpotifyClientCredentialsValidInput", testSpotifyClientCredentialsValidInput),
        ("testFromJSON", testFromJSON),
        ("testFromJSONMissingRefreshToken", testFromJSONMissingRefreshToken),
        ("testFetchAccessToken", testFetchAccessToken),
        ("testFetchAccessTokenNetworkError", testFetchAccessTokenNetworkError),
        ("testFetchAccessTokenNilBody", testFetchAccessTokenNilBody),
        ("testFetchAccessTokenInvalidResponse", testFetchAccessTokenInvalidResponse),
    ]
}
