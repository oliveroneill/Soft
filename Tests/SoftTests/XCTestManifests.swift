import XCTest

extension SpotifyClientCredentialsTests {
    static let __allTests = [
        ("testFetchAccessToken", testFetchAccessToken),
        ("testFetchAccessTokenNetworkError", testFetchAccessTokenNetworkError),
        ("testFromJSON", testFromJSON),
        ("testFromSpotify", testFromSpotify),
        ("testFromSpotifyMissingRefreshToken", testFromSpotifyMissingRefreshToken),
        ("testSpotifyClientCredentialsInvalidInput", testSpotifyClientCredentialsInvalidInput),
        ("testSpotifyClientCredentialsValidInput", testSpotifyClientCredentialsValidInput),
    ]
}

extension SpotifyOAuthTests {
    static let __allTests = [
        ("testFetchAccessToken", testFetchAccessToken),
        ("testFetchAccessTokenFileError", testFetchAccessTokenFileError),
        ("testFetchAccessTokenNetworkError", testFetchAccessTokenNetworkError),
        ("testGetAuthorizeURL", testGetAuthorizeURL),
        ("testGetAuthorizeURLMultipleScopes", testGetAuthorizeURLMultipleScopes),
        ("testGetAuthorizeURLWithCustomState", testGetAuthorizeURLWithCustomState),
        ("testGetAuthorizeURLWithShowDialog", testGetAuthorizeURLWithShowDialog),
        ("testGetCachedToken", testGetCachedToken),
        ("testGetCachedTokenExpired", testGetCachedTokenExpired),
        ("testGetCachedTokenExpiredErrorOnRefresh", testGetCachedTokenExpiredErrorOnRefresh),
        ("testGetCachedTokenExpiredWithoutRefreshToken", testGetCachedTokenExpiredWithoutRefreshToken),
        ("testGetCachedTokenInvalidData", testGetCachedTokenInvalidData),
        ("testGetCachedTokenMismatchScope", testGetCachedTokenMismatchScope),
        ("testParseResponseCode", testParseResponseCode),
        ("testScopeIsSubset", testScopeIsSubset),
        ("testSpotifyOAuthInvalidInput", testSpotifyOAuthInvalidInput),
        ("testSpotifyOAuthValidInput", testSpotifyOAuthValidInput),
    ]
}

extension SpotifyTokenFetcherTests {
    static let __allTests = [
        ("testFetchAccessToken", testFetchAccessToken),
        ("testFetchAccessTokenInvalidResponse", testFetchAccessTokenInvalidResponse),
        ("testFetchAccessTokenNetworkError", testFetchAccessTokenNetworkError),
        ("testFetchAccessTokenNilBody", testFetchAccessTokenNilBody),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SpotifyClientCredentialsTests.__allTests),
        testCase(SpotifyOAuthTests.__allTests),
        testCase(SpotifyTokenFetcherTests.__allTests),
    ]
}
#endif
