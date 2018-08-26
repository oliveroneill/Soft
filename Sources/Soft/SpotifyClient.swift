import Foundation

extension Data {
    /// Decode snake case JSON data to Decodable
    ///
    /// - Returns: Returns a value of the type specified, decoded from JSON.
    /// - Throws: If the data is not valid
    func decoded<T: Decodable>() throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: self)
    }
}

/// Use this struct to make Spotify Web API calls
public struct SpotifyClient {
    private let apiURL = "https://api.spotify.com/v1/"
    private let client: HTTPClient

    /// Create a SpotifyClient instance
    ///
    /// - Parameter tokenInfo: Token retrieved via SpotifyOAuth
    public init(tokenInfo: TokenInfo) {
        self.init(
            clientCredentials: TokenInfoCredentials(tokenInfo: tokenInfo)
        )
    }

    /// Create a SpotifyClient instance that will automatically add
    /// authorization headers using the specified credentials.
    ///
    /// - Parameter clientCredentials: Used for retrieving credentials
    public init(clientCredentials: ClientCredentials) {
        self.init(
            client: SpotifyAuthorizedHTTPClient(
                client: SwiftyRequestClient(),
                clientCredentials: clientCredentials
            )
        )
    }

    /// Create a SpotifyClient instance by specifying an HTTP client. Note that
    /// you'll need add authorization headers yourself
    ///
    /// - Parameters:
    ///   - client: Specify the client to make network requests over
    init(client: HTTPClient) {
        self.client = client
    }

    /// Check the network response and decode if the response is successful
    ///
    /// - Parameters:
    ///   - body: Response body
    ///   - response: HTTP response
    ///   - error: An error
    /// - Returns: An error if the response is invalid or a new instance if
    /// successful
    private func decodeBody<T: Decodable>(body: Data?, response: HTTPURLResponse?,
                                          error: Error?) -> Result<T> {
        // If there is an error then fail
        if let error = error {
            return .failure(error)
        }
        // Ensure that response is not nil as we will validate the status
        // code
        guard let response = response else {
            return .failure(SpotifyAPIError.nilResponse)
        }
        // Ensure the response is a success
        guard response.statusCode == 200 else {
            return .failure(SpotifyAPIError.invalidResponse(response))
        }
        // Ensure that there is a response body
        guard let jsonData = body else {
            return .failure(SpotifyAPIError.nilBody)
        }
        do {
            let track = try jsonData.decoded() as T
            return .success(track)
        } catch {
            return .failure(error)
        }
    }

    /// Returns a single track given the track's ID
    /// See https://developer.spotify.com/web-api/get-track/
    ///
    /// - Parameters:
    ///   - trackID: Spotify Track ID
    ///   - completionHandler: Called on completion
    public func track(trackID: String, completionHandler: @escaping (Result<Track>) -> Void) {
        let url = apiURL + "tracks/" + trackID
        client.get(url: url, parameters: [:], headers: [:]) { body, response, error in
            completionHandler(
                self.decodeBody(body: body, response: response, error: error)
            )
        }
    }

    /// Returns multiple tracks using the IDs specified
    /// See https://developer.spotify.com/web-api/get-several-tracks/
    ///
    /// - Parameters:
    ///   - trackIDs: Spotify Track IDs
    ///   - market: Optionally specify the market. The format is ISO 3166-1
    ///   alpha-2 country code
    ///   - completionHandler: Called on completion
    public func tracks(trackIDs: [String], market: String? = nil, completionHandler: @escaping (Result<Tracks>) -> Void) {
        let url = apiURL + "tracks/"
        var parameters = ["ids": trackIDs.joined(separator: ",")]
        parameters["market"] = market
        client.get(url: url, parameters: parameters, headers: [:]) { body, response, error in
            completionHandler(
                self.decodeBody(body: body, response: response, error: error)
            )
        }
    }

    /// Get a single artist given the ID
    /// See https://developer.spotify.com/web-api/get-artist/
    ///
    /// - Parameters:
    ///   - artistID: Spotify artist ID
    ///   - completionHandler: Called on completion
    public func artist(artistID: String, completionHandler: @escaping (Result<Artist>) -> Void) {
        let url = apiURL + "artists/" + artistID
        client.get(url: url, parameters: [:], headers: [:]) { body, response, error in
            completionHandler(
                self.decodeBody(body: body, response: response, error: error)
            )
        }
    }

    /// Returns multiple artists using the IDs specified
    /// See https://developer.spotify.com/web-api/get-several-artists/
    ///
    /// - Parameters:
    ///   - artistIDs: List of Spotify artist IDs
    ///   - completionHandler: Called on completion
    public func artists(artistIDs: [String], completionHandler: @escaping (Result<Artists>) -> Void) {
        let url = apiURL + "artists/"
        let parameters = ["ids": artistIDs.joined(separator: ",")]
        client.get(url: url, parameters: parameters, headers: [:]) { body, response, error in
            completionHandler(
                self.decodeBody(body: body, response: response, error: error)
            )
        }
    }

    /// Get Spotify catalog information about an artist's albums
    /// See https://developer.spotify.com/web-api/get-artists-albums/
    ///
    /// - Parameters:
    ///   - artistID: Spotify artist ID
    ///   - albumTypes: Optional 'album', 'single', 'appears_on', 'compilation'
    ///   - country: Optional market. The format is ISO 3166-1 alpha-2 country
    ///     code
    ///   - limit: Optional the number of albums to return
    ///   - offset: Optional the index of the first album to return
    ///   - completionHandler: Called on completion
    public func artistAlbums(artistID: String, albumTypes: [AlbumType]? = nil,
                             country: String? = nil, limit: UInt? = nil,
                             offset: UInt? = nil,
                             completionHandler: @escaping (Result<Page<SimplifiedAlbum>>) -> Void) {
        let url = apiURL + "artists/" + artistID + "/albums"
        var parameters: [String:String] = [:]
        if let limit = limit {
            parameters["limit"] = "\(limit)"
        }
        if let albumTypes = albumTypes {
            parameters["include_groups"] = albumTypes.map{ $0.rawValue }.joined(separator: ",")
        }
        if let offset = offset {
            parameters["offset"] = "\(offset)"
        }
        parameters["market"] = country
        client.get(url: url, parameters: parameters, headers: [:]) { body, response, error in
            completionHandler(
                self.decodeBody(body: body, response: response, error: error)
            )
        }
    }

    /// Get top 10 tracks from an artist
    ///
    /// - Parameters:
    ///   - artistID: Spotify Artist ID
    ///   - country: Limit the query by market. The format is ISO 3166-1 alpha-2 country
    ///     code
    ///   - completionHandler: Called on completion
    public func artistTopTracks(artistID: String, country: String,
                                completionHandler: @escaping (Result<Tracks>) -> Void) {
        let url = apiURL + "artists/" + artistID + "/top-tracks"
        let parameters = ["country": country]
        client.get(url: url, parameters: parameters, headers: [:]) { body, response, error in
            completionHandler(
                self.decodeBody(body: body, response: response, error: error)
            )
        }
    }

    /// Get artists related to specified artist
    ///
    /// - Parameters:
    ///   - artistID: Spotify Artist ID
    ///   - completionHandler: Called on completion
    public func relatedArtists(artistID: String,
                                completionHandler: @escaping (Result<Artists>) -> Void) {
        let url = apiURL + "artists/" + artistID + "/related-artists"
        client.get(url: url, parameters: [:], headers: [:]) { body, response, error in
            completionHandler(
                self.decodeBody(body: body, response: response, error: error)
            )
        }
    }

}
