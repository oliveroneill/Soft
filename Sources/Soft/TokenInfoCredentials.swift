/// Error cases for TokenInfoCredentials
///
/// - expiredToken: When the specified token has expired
enum TokenInfoCredentialsError: Error {
    case expiredToken
}

/// A credentials implementation that just returns the specified token if it
/// has not expired. This should be used for "Authorization Code Flow" as
/// opposed to "Client Credentials Flow"
struct TokenInfoCredentials: ClientCredentials {
    private let tokenInfo: TokenInfo

    /// The token to return when fetchAccessToken is called
    ///
    /// - Parameter tokenInfo: Used as authorization
    public init(tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
    }

    public func fetchAccessToken(completionHandler: @escaping (Result<TokenInfo>) -> Void) {
        guard !tokenInfo.isExpired else {
            completionHandler(.failure(TokenInfoCredentialsError.expiredToken))
            return
        }
        completionHandler(.success(tokenInfo))
    }
}
