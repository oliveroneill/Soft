import Foundation

/// Spotify token-info
struct TokenInfo: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let expiresAt: Date?
    let refreshToken: String?
    /// Whether this token has expired
    var isExpired: Bool {
        get {
            guard let expiresAt = expiresAt else {
                return true
            }
            // 10 second buffer
            return Date() > expiresAt - 10
        }
    }

    /// Struct that stores the exact response from the Spotify API
    /// This is an intermediate format that's mutated to a more convenient
    /// format using TokenInfo
    private struct SpotifyTokenInfo: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let expiresIn: Int?
        let refreshToken: String?
    }

    /// Convert a Spotify API network response to more convenient TokenInfo
    /// instance
    ///
    /// - Parameter token: A response from Spotify API
    private init(token: SpotifyTokenInfo) {
        accessToken = token.accessToken
        tokenType = token.tokenType
        scope = token.scope
        if let expiresIn = token.expiresIn {
            // Convert the expiresIn field to a Date
            expiresAt = Date().addingTimeInterval(TimeInterval(expiresIn))
        } else {
            expiresAt = nil
        }
        refreshToken = token.refreshToken
    }

    /// Convert TokenInfo into a JSON data
    ///
    /// - Returns: JSON data
    /// - Throws: If encoding fails
    func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try encoder.encode(self)
    }

    /// Convert Data from Spotify API network call to a TokenInfo instance
    ///
    /// - Parameter data: JSON data from Spotify API
    /// - Returns: A TokenInfo instance containing info from the deserialised
    /// JSON data
    /// - Throws: If decoding fails
    static func fromSpotify(data: Data) throws -> TokenInfo {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(
            SpotifyTokenInfo.self,
            from: data
        )
        return TokenInfo(token: response)
    }

    /// Convert serialied TokenInfo JSON to TokenInfo instance
    ///
    /// - Parameter data: JSON data
    /// - Returns: A TokenInfo instance containing info from the deserialised
    /// JSON data
    /// - Throws: If decoding fails
    static func fromJSON(data: Data) throws -> TokenInfo {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(
            TokenInfo.self,
            from: data
        )
    }
}
