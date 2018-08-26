import XCTest

extension SpotifyAuthorizedHTTPClientTests {
    static let __allTests = [
        ("testDelete", testDelete),
        ("testGet", testGet),
        ("testPost", testPost),
        ("testPut", testPut),
    ]
}

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

extension SpotifyClientTests {
    static let __allTests = [
        ("testTrack", testTrack),
        ("testTracks", testTracks),
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
        testCase(SpotifyAuthorizedHTTPClientTests.__allTests),
        testCase(SpotifyClientCredentialsTests.__allTests),
        testCase(SpotifyClientTests.__allTests),
        testCase(SpotifyOAuthTests.__allTests),
        testCase(SpotifyTokenFetcherTests.__allTests),
    ]
}
#endif
