import XCTest
@testable import Soft

final class SpotifyClientCredentialsTests: XCTestCase {
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
    var parameters = ["grant_type": "client_credentials"]

    /// JSON Data created from the input data. This will be set in the setUp
    /// function
    var jsonData = Data()
    // Token created in setUp
    var token: TokenInfo!

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
        jsonData = d
    }

    func testSpotifyClientCredentialsInvalidInput() {
        // Ensure it fails on empty strings
        XCTAssertThrowsError(try SpotifyClientCredentials(clientID: "", clientSecret: "")) {
            XCTAssertEqual(
                InvalidCredentialsError.emptyInput,
                $0 as? InvalidCredentialsError
            )
        }
    }

    func testSpotifyClientCredentialsValidInput() {
        // Ensure it passes on strings that are not empty
        XCTAssertNoThrow(
            try SpotifyClientCredentials(
                clientID: clientID,
                clientSecret: clientSecret
            )
        )
    }

    func testFromJSON() {
        let expiresAt = Date()
        let json = """
        {
        "access_token": "\(accessToken)",
        "token_type": "\(tokenType)",
        "scope": "\(scope)",
        "expires_at": \(expiresAt.timeIntervalSinceReferenceDate)
        }
        """
        guard let jsonData = json.data(using: .utf8) else {
            XCTFail("Unable to convert string to bytes")
            return
        }
        do {
            let tokenInfo = try TokenInfo.fromJSON(data: jsonData)
            XCTAssertEqual(accessToken, tokenInfo.accessToken)
            XCTAssertEqual(tokenType, tokenInfo.tokenType)
            XCTAssertEqual(scope, tokenInfo.scope)
            XCTAssertEqual(expiresAt, tokenInfo.expiresAt)
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testFromSpotify() {
        do {
            // Deserialised test input JSON data
            let tokenInfo = try TokenInfo.fromSpotify(data: jsonData)
            // Ensure that the result matches the input
            XCTAssertEqual(accessToken, tokenInfo.accessToken)
            XCTAssertEqual(tokenType, tokenInfo.tokenType)
            XCTAssertEqual(scope, tokenInfo.scope)
            XCTAssertEqual(refreshToken, tokenInfo.refreshToken)
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testFromSpotifyMissingRefreshToken() {
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
            let tokenInfo = try TokenInfo.fromSpotify(data: jsonData)
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

    /// Fake token fetcher for mocking network interaction
    class FakeTokenFetcher: AuthorizationTokenFetcher {
        /// Keeps track of calls to fetchAccessToken
        var calls: [(clientID: String, clientSecret: String, parameters: [String : String])] = []
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
            calls.append((clientID: clientID, clientSecret: clientSecret, parameters: parameters))
            completionHandler(result)
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
            let fakeFetcher = FakeTokenFetcher(result: .success(token))
            let credentials = try SpotifyClientCredentials(
                clientID: clientID,
                clientSecret: clientSecret,
                fetcher: fakeFetcher
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
                    XCTAssertEqual(self.clientID, fakeFetcher.calls[0].clientID)
                    XCTAssertEqual(
                        self.clientSecret,
                        fakeFetcher.calls[0].clientSecret
                    )
                    XCTAssertEqual(
                        self.parameters,
                        fakeFetcher.calls[0].parameters
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
            let fakeFetcher = FakeTokenFetcher(result: .failure(expectedError))
            let credentials = try SpotifyClientCredentials(
                clientID: clientID,
                clientSecret: clientSecret,
                fetcher: fakeFetcher
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
                    XCTAssertEqual(self.clientID, fakeFetcher.calls[0].clientID)
                    XCTAssertEqual(
                        self.clientSecret,
                        fakeFetcher.calls[0].clientSecret
                    )
                    XCTAssertEqual(
                        self.parameters,
                        fakeFetcher.calls[0].parameters
                    )
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }
}
