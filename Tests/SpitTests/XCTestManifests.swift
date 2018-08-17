import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SpotifyTokenFetcherTests.allTests),
        testCase(SpotifyClientCredentialsTests.allTests),
        testCase(SpotifyOAuthTests.allTests),
    ]
}
#endif
