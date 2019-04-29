/// An interface for retrieving a token to be used for authorization for
/// Spotify Web API requests
public protocol ClientCredentials {
    /// Retrieve a token to be used for authorization
    ///
    /// - Parameter completionHandler: Called with a successful token or an
    /// error if one could not be retrieved
    func fetchAccessToken(completionHandler: @escaping (Result<TokenInfo, Error>) -> Void)
}
