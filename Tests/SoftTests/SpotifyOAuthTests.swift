import XCTest
@testable import Soft

final class SpotifyOAuthTests: XCTestCase {
    // Test input data
    let clientID = "client-id-123"
    let clientSecret = "A_SECRET_KEY"
    let redirectURI = "http://localhost:8080"
    let state = "fakeState"
    let cachePath = URL(fileURLWithPath: "delme.json")
    let accessToken = "token-123"
    let tokenType = "Bearer"
    let scope = "user-read-private"
    let refreshToken = "refresh-344"
    let expiresIn = 24
    let code = "fakeAuthorizationCode"
    // Headers are initialised in setUp
    var parameters: [String:String] = [:]
    // Token is initialised in setUp
    var networkToken: TokenInfo!
    var networkTokenJSON: Data!
    var cachedToken: TokenInfo!
    var cachedTokenJSON: Data!

    override func setUp() {
        parameters = [
            "redirect_uri": redirectURI,
            "code": code,
            "grant_type": "authorization_code",
            "scope": scope,
            "state": state
        ]
        initialiseNetworkToken()
        initialiseCachedToken()
    }

    func initialiseNetworkToken() {
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
        networkTokenJSON = d
        do {
            // Token is created using fromSpotify since it does not have an init
            networkToken = try TokenInfo.fromSpotify(data: d)
        } catch {
            XCTFail("Failed to create token: \(error)")
        }
    }

    func initialiseCachedToken() {
        // Create string from test input data
        let json = """
        {
        "access_token": "\(accessToken)",
        "token_type": "\(tokenType)",
        "scope": "\(scope)",
        "refresh_token": "\(refreshToken)",
        "expires_at": \((Date() + 10000).timeIntervalSinceReferenceDate)
        }
        """
        // Convert to data and fail if not possible
        guard let d = json.data(using: .utf8) else {
            XCTFail("Unable to convert string to bytes")
            return
        }
        cachedTokenJSON = d
        do {
            // Token is created using fromJSON since it does not have an init
            cachedToken = try TokenInfo.fromJSON(data: d)
        } catch {
            XCTFail("Failed to create token: \(error)")
        }
    }

    func createExpiredToken(refreshToken: String?) -> Data {
        // JSON for cached token with a different refresh token which is
        // expired
        var json = """
        {
        "access_token": "differentoken",
        "token_type": "different_type",
        "scope": "\(scope)",
        """
        if let token = refreshToken {
            json += """
            "refresh_token": "\(token)",
            """
        }
        json += """
        "expires_at": \((Date() - 1000).timeIntervalSinceNow)
        }
        """
        // Convert to data and fail if not possible
        guard let d = json.data(using: .utf8) else {
            XCTFail("Unable to convert string to bytes")
            return Data()
        }
        return d
    }

    func testSpotifyOAuthInvalidInput() {
        // Ensure it fails on empty strings
        do {
            _ = try SpotifyOAuth(
                clientID: "", clientSecret: "",
                redirectURI: URL(string: "http://localhost:8080")!,
                state: "", scope: ""
            )
            XCTFail("Expected failure")
        } catch {
            XCTAssertEqual(
                InvalidCredentialsError.emptyInput,
                error as? InvalidCredentialsError
            )
        }
    }

    func testSpotifyOAuthValidInput() {
        // Ensure it passes on strings that are not empty
        do {
            _ = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: "http://localhost:8080")!,
                state: "", scope: ""
            )
        } catch {
            XCTFail("Unexpected failure \(error)")
        }
    }

    /// Fake token fetcher for mocking network interaction
    class FakeTokenFetcher: AuthorizationTokenFetcher {
        /// Keeps track of calls to fetchAccessToken
        var calls: [(clientID: String, clientSecret: String, parameters: [String : String])] = []
        private let result: FetchTokenResult

        /// Create a FakeTokenFetcher
        ///
        /// - Parameter result: The result to be returned from fetchAccessToken
        init(result: FetchTokenResult) {
            self.result = result
        }

        func fetchAccessToken(clientID: String, clientSecret: String,
                              parameters: [String : String],
                              completionHandler: @escaping (FetchTokenResult) -> Void) {
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

    enum DataOrError {
        case data(Data)
        case error(Error)
    }

    class FakeFileHandler: FileHandler {
        var readCalls: [URL] = []
        var writeCalls: [(data: Data, url: URL)] = []
        private let readReturns: DataOrError
        private let writeReturns: Error?

        init(readReturns: DataOrError, writeReturns: Error? = nil) {
            self.readReturns = readReturns
            self.writeReturns = writeReturns
        }

        func read(from: URL) throws -> Data {
            readCalls.append(from)
            switch readReturns {
            case .data(let data): return data
            case .error(let error): throw error
            }
        }

        func write(data: Data, to: URL) throws {
            writeCalls.append((data: data, url: to))
            if let e = writeReturns {
                throw e
            }
        }
    }

    func testFetchAccessToken() {
        do {
            // Given
            // Create a fake client that returns valid JSON data and a
            // successful response
            let fakeFetcher = FakeTokenFetcher(result: .success(networkToken))
            let fileHandler = FakeFileHandler(readReturns: .data(Data()))
            let oauth = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: redirectURI)!, state: state,
                scope: scope, cachePath: cachePath, fetcher: fakeFetcher,
                fileHandler: fileHandler
            )
            // When
            oauth.fetchAccessToken(code: code) { result in
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
                    XCTAssertEqual(1, fileHandler.writeCalls.count)
                    XCTAssertEqual(0, fileHandler.readCalls.count)
                    do {
                        let json = try tokenInfo.toJSON()
                        XCTAssertEqual(json, fileHandler.writeCalls[0].data)
                        XCTAssertEqual(self.cachePath, fileHandler.writeCalls[0].url)
                    } catch {
                        XCTFail("\(error)")
                    }
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
            let fileHandler = FakeFileHandler(readReturns: .data(Data()))
            let oauth = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: redirectURI)!, state: state,
                scope: scope, cachePath: cachePath, fetcher: fakeFetcher,
                fileHandler: fileHandler
            )
            // When
            oauth.fetchAccessToken(code: code) { result in
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
                    XCTAssertEqual(0, fileHandler.writeCalls.count)
                    XCTAssertEqual(0, fileHandler.readCalls.count)
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testFetchAccessTokenFileError() {
        do {
            // Given
            let expectedError = FakeError.testError
            // Client returns an error
            let fakeFetcher = FakeTokenFetcher(result: .success(networkToken))
            let fileHandler = FakeFileHandler(
                readReturns: .data(Data()),
                writeReturns: expectedError
            )
            let oauth = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: redirectURI)!, state: state,
                scope: scope, cachePath: cachePath, fetcher: fakeFetcher,
                fileHandler: fileHandler
            )
            // When
            oauth.fetchAccessToken(code: code) { result in
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
                    XCTAssertEqual(1, fileHandler.writeCalls.count)
                    XCTAssertEqual(0, fileHandler.readCalls.count)
                    do {
                        let json = try self.networkToken.toJSON()
                        XCTAssertEqual(
                            json,
                            fileHandler.writeCalls[0].data
                        )
                        XCTAssertEqual(
                            self.cachePath,
                            fileHandler.writeCalls[0].url
                        )
                    } catch {
                        XCTFail("\(error)")
                    }
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testScopeIsSubset() {
        let scope1: Scope = "user-read-private user-read-email"
        let scope2: Scope = "user-read-private"
        XCTAssert(scope2.isSubset(of: scope1))
        XCTAssertFalse(scope1.isSubset(of: scope2))
    }

    func testGetCachedToken() {
        do {
            // Given
            // Create a fake client that returns valid JSON data and a
            // successful response
            let fakeFetcher = FakeTokenFetcher(result: .failure(FakeError.testError))
            let fileHandler = FakeFileHandler(readReturns: .data(cachedTokenJSON))
            let oauth = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: redirectURI)!, state: state,
                scope: scope, cachePath: cachePath, fetcher: fakeFetcher,
                fileHandler: fileHandler
            )
            // When
            oauth.getCachedToken { result in
                // Then
                // Ensure a successful result
                switch result {
                case .success(let tokenInfo):
                    // Ensure token info matches input
                    XCTAssertEqual(self.accessToken, tokenInfo.accessToken)
                    XCTAssertEqual(self.tokenType, tokenInfo.tokenType)
                    XCTAssertEqual(self.scope, tokenInfo.scope)
                    XCTAssertEqual(self.refreshToken, tokenInfo.refreshToken)
                    // Ensure that the file handler call uses the correct input
                    XCTAssertEqual(1, fileHandler.readCalls.count)
                    XCTAssertEqual(0, fileHandler.writeCalls.count)
                    XCTAssertEqual(self.cachePath, fileHandler.readCalls[0])
                case .failure(let error):
                    XCTFail("Unexpected failure: \(error)")
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testGetCachedTokenInvalidData() {
        do {
            // Given
            // Create a fake client that returns valid JSON data and a
            // successful response
            let fakeFetcher = FakeTokenFetcher(result: .failure(FakeError.testError))
            let fileHandler = FakeFileHandler(readReturns: .data(Data()))
            let oauth = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: redirectURI)!, state: state,
                scope: scope, cachePath: cachePath, fetcher: fakeFetcher,
                fileHandler: fileHandler
            )
            // When
            oauth.getCachedToken { result in
                // Then
                switch result {
                case .success(_):
                    // Ensure failure occurs
                    XCTFail("Unexpected success")
                case .failure(let error):
                    // Ensure the error is not the one from the network, as
                    // it should be a JSON parsing error
                    XCTAssertNotEqual(FakeError.testError, error as? FakeError)
                    // Ensure that the file handler call uses the correct input
                    XCTAssertEqual(0, fileHandler.writeCalls.count)
                    XCTAssertEqual(1, fileHandler.readCalls.count)
                    XCTAssertEqual(self.cachePath, fileHandler.readCalls[0])
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testGetCachedTokenMismatchScope() {
        do {
            // Given
            // Create a fake client that returns valid JSON data and a
            // successful response
            let fakeFetcher = FakeTokenFetcher(result: .failure(FakeError.testError))
            let fileHandler = FakeFileHandler(readReturns: .data(networkTokenJSON))
            let oauth = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: redirectURI)!, state: state,
                // Specify different scope
                scope: "different-scope", cachePath: cachePath,
                fetcher: fakeFetcher, fileHandler: fileHandler
            )
            // When
            oauth.getCachedToken { result in
                // Then
                switch result {
                case .success(_):
                    // Ensure failure occurs
                    XCTFail("Unexpected success")
                case .failure(let error):
                    // Ensure the error is not the one from the network, as
                    // it should be a JSON parsing error
                    XCTAssertEqual(CachedTokenError.mismatchScope, error as? CachedTokenError)
                    // Ensure that the file handler call uses the correct input
                    XCTAssertEqual(0, fileHandler.writeCalls.count)
                    XCTAssertEqual(1, fileHandler.readCalls.count)
                    XCTAssertEqual(self.cachePath, fileHandler.readCalls[0])
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testGetCachedTokenExpired() {
        let refreshToken = "randomRefreshToken"
        let d = createExpiredToken(refreshToken: refreshToken)
        do {
            // Given
            // Create a fake client that returns valid JSON data and a
            // successful response
            let fakeFetcher = FakeTokenFetcher(result: .success(networkToken))
            let fileHandler = FakeFileHandler(readReturns: .data(d))
            let oauth = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: redirectURI)!, state: state,
                scope: scope, cachePath: cachePath, fetcher: fakeFetcher,
                fileHandler: fileHandler
            )
            // When
            oauth.getCachedToken { result in
                // Then
                // Ensure a successful result
                switch result {
                case .success(let tokenInfo):
                    // Ensure token info matches input
                    XCTAssertEqual(self.accessToken, tokenInfo.accessToken)
                    XCTAssertEqual(self.tokenType, tokenInfo.tokenType)
                    XCTAssertEqual(self.scope, tokenInfo.scope)
                    XCTAssertEqual(self.refreshToken, tokenInfo.refreshToken)
                    // Ensure fetcher was used correctly
                    XCTAssertEqual(self.clientID, fakeFetcher.calls[0].clientID)
                    XCTAssertEqual(
                        self.clientSecret,
                        fakeFetcher.calls[0].clientSecret
                    )
                    XCTAssertEqual(
                        [
                            "refresh_token": refreshToken,
                            "grant_type": "refresh_token"
                        ],
                        fakeFetcher.calls[0].parameters
                    )
                    // Ensure that the file handler call uses the correct input
                    XCTAssertEqual(0, fileHandler.writeCalls.count)
                    XCTAssertEqual(1, fileHandler.readCalls.count)
                    XCTAssertEqual(self.cachePath, fileHandler.readCalls[0])
                case .failure(let error):
                    XCTFail("Unexpected failure: \(error)")
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testGetCachedTokenExpiredErrorOnRefresh() {
        let refreshToken = "randomRefreshToken"
        let d = createExpiredToken(refreshToken: refreshToken)
        do {
            // Given
            let expectedError = FakeError.testError
            // Create a fake client that returns valid JSON data and a
            // successful response
            let fakeFetcher = FakeTokenFetcher(result: .failure(expectedError))
            let fileHandler = FakeFileHandler(readReturns: .data(d))
            let oauth = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: redirectURI)!, state: state,
                scope: scope, cachePath: cachePath, fetcher: fakeFetcher,
                fileHandler: fileHandler
            )
            // When
            oauth.getCachedToken { result in
                // Then
                switch result {
                case .success(_):
                    XCTFail("Unexpected success")
                case .failure(let error):
                    XCTAssertEqual(expectedError, error as? FakeError)
                    // Ensure fetcher was used correctly
                    XCTAssertEqual(self.clientID, fakeFetcher.calls[0].clientID)
                    XCTAssertEqual(
                        self.clientSecret,
                        fakeFetcher.calls[0].clientSecret
                    )
                    XCTAssertEqual(
                        [
                            "refresh_token": refreshToken,
                            "grant_type": "refresh_token"
                        ],
                        fakeFetcher.calls[0].parameters
                    )
                    // Ensure that the file handler call uses the correct input
                    XCTAssertEqual(0, fileHandler.writeCalls.count)
                    XCTAssertEqual(1, fileHandler.readCalls.count)
                    XCTAssertEqual(self.cachePath, fileHandler.readCalls[0])
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testGetCachedTokenExpiredWithoutRefreshToken() {
        let d = createExpiredToken(refreshToken: nil)
        do {
            // Given
            let fakeFetcher = FakeTokenFetcher(result: .failure(FakeError.testError))
            let fileHandler = FakeFileHandler(readReturns: .data(d))
            let oauth = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: redirectURI)!, state: state,
                scope: scope, cachePath: cachePath, fetcher: fakeFetcher,
                fileHandler: fileHandler
            )
            // When
            oauth.getCachedToken { result in
                // Then
                switch result {
                case .success(_):
                    XCTFail("Unexpected success")
                case .failure(let error):
                    XCTAssertEqual(
                        CachedTokenError.noRefreshToken,
                        error as! CachedTokenError
                    )
                    XCTAssertEqual(0, fakeFetcher.calls.count)
                    XCTAssertEqual(0, fileHandler.writeCalls.count)
                    XCTAssertEqual(1, fileHandler.readCalls.count)
                    XCTAssertEqual(self.cachePath, fileHandler.readCalls[0])
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    /// Helper function for comparing URLs since the query parameters may be
    /// out of order
    ///
    /// - Parameters:
    ///   - first: The first URL to compare
    ///   - second: The second URL to compare
    func compareURLsIgnoringQueryParamOrder(first: URL, second: URL, file: StaticString = #file, line: UInt = #line) {
        guard let components = URLComponents(url: first, resolvingAgainstBaseURL: false) else {
            self.recordFailure(
                withDescription: "Unexpected nil",
                inFile: String(describing: file),
                atLine: Int(line), expected: true
            )
            return
        }
        guard let expected = URLComponents(url: second, resolvingAgainstBaseURL: false) else {
            self.recordFailure(
                withDescription: "Unexpected nil",
                inFile: String(describing: file),
                atLine: Int(line), expected: true
            )
            return
        }
        // Compare the query items once they're sorted
        XCTAssertEqual(
            expected.queryItems?.sorted {$0.name < $1.name},
            components.queryItems?.sorted {$0.name < $1.name},
            file: file, line: line
        )
        // Get the query string out so we can compare the rest
        guard let firstQuery = first.query else {
            self.recordFailure(
                withDescription: "Unexpected nil",
                inFile: String(describing: file),
                atLine: Int(line), expected: true
            )
            return
        }
        guard let secondQuery = second.query else {
            self.recordFailure(
                withDescription: "Unexpected nil",
                inFile: String(describing: file),
                atLine: Int(line), expected: true
            )
            return
        }
        // Compare the URL without the query string
        XCTAssertEqual(
            first.absoluteString.replacingOccurrences(of: firstQuery, with: ""),
            second.absoluteString.replacingOccurrences(of: secondQuery, with: ""),
            file: file, line: line
        )

    }

    func testGetAuthorizeURL() {
        // This error will never be called since the fetcher and file handler
        // will not be used
        let error = FakeError.testError
        let fakeFetcher = FakeTokenFetcher(result: .failure(error))
        let fileHandler = FakeFileHandler(readReturns: .error(error))
        do {
            let oauth = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: redirectURI)!, state: state,
                scope: scope, cachePath: cachePath, fetcher: fakeFetcher,
                fileHandler: fileHandler
            )
            let url = try oauth.getAuthorizeURL()
            let expectedURL = URL(
                string: "https://accounts.spotify.com/authorize?redirect_uri=\(redirectURI)&response_type=code&scope=\(scope)&state=\(state)&client_id=\(clientID)"
            )!
            compareURLsIgnoringQueryParamOrder(first: url, second: expectedURL)

        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testGetAuthorizeURLMultipleScopes() {
        let scope = "user-read-private user-read-public"
        // This error will never be called since the fetcher and file handler
        // will not be used
        let error = FakeError.testError
        let fakeFetcher = FakeTokenFetcher(result: .failure(error))
        let fileHandler = FakeFileHandler(readReturns: .error(error))
        do {
            let oauth = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: redirectURI)!, state: state,
                scope: scope, cachePath: cachePath, fetcher: fakeFetcher,
                fileHandler: fileHandler
            )
            let encodedScope = "user-read-private%20user-read-public"
            let url = try oauth.getAuthorizeURL()
            let expectedURL = URL(
                string: "https://accounts.spotify.com/authorize?redirect_uri=\(redirectURI)&response_type=code&scope=\(encodedScope)&state=\(state)&client_id=\(clientID)"
                )!
            compareURLsIgnoringQueryParamOrder(first: url, second: expectedURL)

        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testGetAuthorizeURLWithCustomState() {
        let state = "anotherState"
        // This error will never be called since the fetcher and file handler
        // will not be used
        let error = FakeError.testError
        let fakeFetcher = FakeTokenFetcher(result: .failure(error))
        let fileHandler = FakeFileHandler(readReturns: .error(error))
        do {
            let oauth = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: redirectURI)!, state: self.state,
                scope: scope, cachePath: cachePath, fetcher: fakeFetcher,
                fileHandler: fileHandler
            )
            let url = try oauth.getAuthorizeURL(state: state)
            let expectedURL = URL(
                string: "https://accounts.spotify.com/authorize?redirect_uri=\(redirectURI)&response_type=code&scope=\(scope)&state=\(state)&client_id=\(clientID)"
                )!
            compareURLsIgnoringQueryParamOrder(first: url, second: expectedURL)

        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testGetAuthorizeURLWithShowDialog() {
        // This error will never be called since the fetcher and file handler
        // will not be used
        let error = FakeError.testError
        let fakeFetcher = FakeTokenFetcher(result: .failure(error))
        let fileHandler = FakeFileHandler(readReturns: .error(error))
        do {
            let oauth = try SpotifyOAuth(
                clientID: clientID, clientSecret: clientSecret,
                redirectURI: URL(string: redirectURI)!, state: state,
                scope: scope, cachePath: cachePath, fetcher: fakeFetcher,
                fileHandler: fileHandler
            )
            let url = try oauth.getAuthorizeURL(showDialog: true)
            let expectedURL = URL(
                string: "https://accounts.spotify.com/authorize?redirect_uri=\(redirectURI)&response_type=code&scope=\(scope)&state=\(state)&client_id=\(clientID)&show_dialog=true"
                )!
            compareURLsIgnoringQueryParamOrder(first: url, second: expectedURL)

        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testParseResponseCode() {
        let result = SpotifyOAuth.parseResponseCode(url: "http://localhost:8080?code=\(code)&state=Wiu6mRqfDQyZz0QR")
        XCTAssertEqual(code, result)

        // Test error case
        XCTAssertNil(SpotifyOAuth.parseResponseCode(url: "http://localhost:8080"))
    }
}
