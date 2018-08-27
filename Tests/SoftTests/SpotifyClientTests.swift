import XCTest
@testable import Soft

final class SpotifyClientTests: XCTestCase {
    var response: HTTPURLResponse!

    enum TestError: Error {
        case error
    }

    override func setUp() {
        response = HTTPURLResponse(
            url: URL(string: "http://x.com/")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
    }

    /// Fake HTTP Client for mocking network interaction
    class FakeClient: HTTPClient {
        private let expected: (Data?, HTTPURLResponse?, Error?)
        var numCallsAuthenticationRequest = 0
        var getCalls: [(url: String, parameters: [String:String], headers: [String : String])] = []
        var postCalls: [(url: String, payload: Data, headers: [String : String])] = []
        var putCalls: [(url: String, payload: Data, headers: [String : String])] = []
        var deleteCalls: [(url: String, payload: Data, headers: [String : String])] = []

        /// Create a fake network interface
        ///
        /// - Parameter expected: This will be returned via
        /// authenticationRequest's completionHandler
        init(expected: (Data?, HTTPURLResponse?, Error?)) {
            self.expected = expected
        }

        func authenticationRequest(url: String, username: String,
                                   password: String,
                                   parameters: [String : String],
                                   completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
            numCallsAuthenticationRequest += 1
        }

        func get(url: String, parameters: [String:String],
                 headers: [String : String],
                 completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
            getCalls.append((url: url, parameters: parameters, headers: headers))
            completionHandler(expected.0, expected.1, expected.2)
        }

        func post(url: String, payload: Data,
                  headers: [String : String],
                  completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
            postCalls.append((url: url, payload: payload, headers: headers))
            completionHandler(expected.0, expected.1, expected.2)
        }
        func put(url: String, payload: Data,
                 headers: [String : String],
                 completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
            putCalls.append((url: url, payload: payload, headers: headers))
            completionHandler(expected.0, expected.1, expected.2)
        }

        func delete(url: String, payload: Data,
                    headers: [String : String],
                    completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
            deleteCalls.append((url: url, payload: payload, headers: headers))
            completionHandler(expected.0, expected.1, expected.2)
        }
    }

    func testTrack() {
        let images = [
            Image(
                url: "https://i.scdn.co/image/966ade7a8c43b72faa53822b74a899c675aaafee",
                width: nil, height: nil
            )
        ]
        let artists = [
            SimplifiedArtist(
                externalUrls: ["spotify": "https://open.spotify.com/artist/6sFIWsNpZYqfjUpaCgueju"],
                href: "https://api.spotify.com/v1/artists/6sFIWsNpZYqfjUpaCgueju",
                id: "6sFIWsNpZYqfjUpaCgueju",
                name: "Carly Rae Jepsen",
                uri: "spotify:artist:6sFIWsNpZYqfjUpaCgueju"
            )
        ]
        let album = SimplifiedAlbum(
            artists: artists, albumType: .single,
            availableMarkets: ["AD"],
            externalUrls: ["spotify": "https://open.spotify.com/album/0tGPJ0bkWOUmH7MEOR77qc"],
            href: "https://api.spotify.com/v1/albums/0tGPJ0bkWOUmH7MEOR77qc",
            id: "0tGPJ0bkWOUmH7MEOR77qc",
            images: images, name: "Cut To The Feeling",
            uri: "spotify:album:0tGPJ0bkWOUmH7MEOR77qc"
        )
        let expectedTrack = Track(
            album: album, artists: artists, availableMarkets: ["AD"],
            discNumber: 1, durationMs: 207959,
            externalIds: ["isrc": "USUM71703861"],
            externalUrls: ["spotify": "https://open.spotify.com/track/11dFghVXANMlKmJXsNCbNl"],
            href: "https://api.spotify.com/v1/tracks/11dFghVXANMlKmJXsNCbNl",
            id: "11dFghVXANMlKmJXsNCbNl", name: "Cut To The Feeling",
            popularity: 63,
            previewUrl: "https://p.scdn.co/mp3-preview/3eb16018c2a700240e9dfb8817b6f2d041f15eb1?cid=774b29d4f13844c495f206cafdad9c86",
            trackNumber: 1, uri: "spotify:track:11dFghVXANMlKmJXsNCbNl"
        )
        let data = """
{
  "album": {
    "album_type": "single",
    "artists": [
      {
        "external_urls": {
          "spotify": "https://open.spotify.com/artist/6sFIWsNpZYqfjUpaCgueju"
        },
        "href": "https://api.spotify.com/v1/artists/6sFIWsNpZYqfjUpaCgueju",
        "id": "6sFIWsNpZYqfjUpaCgueju",
        "name": "Carly Rae Jepsen",
        "type": "artist",
        "uri": "spotify:artist:6sFIWsNpZYqfjUpaCgueju"
      }
    ],
    "available_markets": [
      "AD"
    ],
    "external_urls": {
      "spotify": "https://open.spotify.com/album/0tGPJ0bkWOUmH7MEOR77qc"
    },
    "href": "https://api.spotify.com/v1/albums/0tGPJ0bkWOUmH7MEOR77qc",
    "id": "0tGPJ0bkWOUmH7MEOR77qc",
    "images": [
      {
        "url": "https://i.scdn.co/image/966ade7a8c43b72faa53822b74a899c675aaafee"
      }
    ],
    "name": "Cut To The Feeling",
    "release_date": "2017-05-26",
    "release_date_precision": "day",
    "type": "album",
    "uri": "spotify:album:0tGPJ0bkWOUmH7MEOR77qc"
  },
  "artists": [
    {
      "external_urls": {
        "spotify": "https://open.spotify.com/artist/6sFIWsNpZYqfjUpaCgueju"
      },
      "href": "https://api.spotify.com/v1/artists/6sFIWsNpZYqfjUpaCgueju",
      "id": "6sFIWsNpZYqfjUpaCgueju",
      "name": "Carly Rae Jepsen",
      "type": "artist",
      "uri": "spotify:artist:6sFIWsNpZYqfjUpaCgueju"
    }
  ],
  "available_markets": [
    "AD"
  ],
  "disc_number": 1,
  "duration_ms": 207959,
  "explicit": false,
  "external_ids": {
    "isrc": "USUM71703861"
  },
  "external_urls": {
    "spotify": "https://open.spotify.com/track/11dFghVXANMlKmJXsNCbNl"
  },
  "href": "https://api.spotify.com/v1/tracks/11dFghVXANMlKmJXsNCbNl",
  "id": "11dFghVXANMlKmJXsNCbNl",
  "is_local": false,
  "name": "Cut To The Feeling",
  "popularity": 63,
  "preview_url": "https://p.scdn.co/mp3-preview/3eb16018c2a700240e9dfb8817b6f2d041f15eb1?cid=774b29d4f13844c495f206cafdad9c86",
  "track_number": 1,
  "type": "track",
  "uri": "spotify:track:11dFghVXANMlKmJXsNCbNl"
}
""".data(using: .utf8)!
        let networkResponse: (Data?, HTTPURLResponse?, Error?) = (data, response, nil)
        let trackID = "track_1223"
        let client = SpotifyClient(client: FakeClient(expected: networkResponse))
        client.track(trackID: trackID) {
            switch $0 {
            case .success(let track):
                XCTAssertEqual(expectedTrack, track)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testTracks() {
        let images = [
            Image(
                url: "https://i.scdn.co/image/966ade7a8c43b72faa53822b74a899c675aaafee",
                width: nil, height: nil
            )
        ]
        let artists = [
            SimplifiedArtist(
                externalUrls: ["spotify": "https://open.spotify.com/artist/6sFIWsNpZYqfjUpaCgueju"],
                href: "https://api.spotify.com/v1/artists/6sFIWsNpZYqfjUpaCgueju",
                id: "6sFIWsNpZYqfjUpaCgueju",
                name: "Carly Rae Jepsen",
                uri: "spotify:artist:6sFIWsNpZYqfjUpaCgueju"
            )
        ]
        let album = SimplifiedAlbum(
            artists: artists, albumType: .single,
            availableMarkets: ["AD"],
            externalUrls: ["spotify": "https://open.spotify.com/album/0tGPJ0bkWOUmH7MEOR77qc"],
            href: "https://api.spotify.com/v1/albums/0tGPJ0bkWOUmH7MEOR77qc",
            id: "0tGPJ0bkWOUmH7MEOR77qc",
            images: images, name: "Cut To The Feeling",
            uri: "spotify:album:0tGPJ0bkWOUmH7MEOR77qc"
        )
        let track = Track(
            album: album, artists: artists, availableMarkets: ["AD"],
            discNumber: 1, durationMs: 207959,
            externalIds: ["isrc": "USUM71703861"],
            externalUrls: ["spotify": "https://open.spotify.com/track/11dFghVXANMlKmJXsNCbNl"],
            href: "https://api.spotify.com/v1/tracks/11dFghVXANMlKmJXsNCbNl",
            id: "11dFghVXANMlKmJXsNCbNl", name: "Cut To The Feeling",
            popularity: 63,
            previewUrl: "https://p.scdn.co/mp3-preview/3eb16018c2a700240e9dfb8817b6f2d041f15eb1?cid=774b29d4f13844c495f206cafdad9c86",
            trackNumber: 1, uri: "spotify:track:11dFghVXANMlKmJXsNCbNl"
        )
        let expectedTracks = Tracks(tracks: [track])
        let data = """
{"tracks": [
{
  "album": {
    "album_type": "single",
    "artists": [
      {
        "external_urls": {
          "spotify": "https://open.spotify.com/artist/6sFIWsNpZYqfjUpaCgueju"
        },
        "href": "https://api.spotify.com/v1/artists/6sFIWsNpZYqfjUpaCgueju",
        "id": "6sFIWsNpZYqfjUpaCgueju",
        "name": "Carly Rae Jepsen",
        "type": "artist",
        "uri": "spotify:artist:6sFIWsNpZYqfjUpaCgueju"
      }
    ],
    "available_markets": [
      "AD"
    ],
    "external_urls": {
      "spotify": "https://open.spotify.com/album/0tGPJ0bkWOUmH7MEOR77qc"
    },
    "href": "https://api.spotify.com/v1/albums/0tGPJ0bkWOUmH7MEOR77qc",
    "id": "0tGPJ0bkWOUmH7MEOR77qc",
    "images": [
      {
        "url": "https://i.scdn.co/image/966ade7a8c43b72faa53822b74a899c675aaafee"
      }
    ],
    "name": "Cut To The Feeling",
    "release_date": "2017-05-26",
    "release_date_precision": "day",
    "type": "album",
    "uri": "spotify:album:0tGPJ0bkWOUmH7MEOR77qc"
  },
  "artists": [
    {
      "external_urls": {
        "spotify": "https://open.spotify.com/artist/6sFIWsNpZYqfjUpaCgueju"
      },
      "href": "https://api.spotify.com/v1/artists/6sFIWsNpZYqfjUpaCgueju",
      "id": "6sFIWsNpZYqfjUpaCgueju",
      "name": "Carly Rae Jepsen",
      "type": "artist",
      "uri": "spotify:artist:6sFIWsNpZYqfjUpaCgueju"
    }
  ],
  "available_markets": [
    "AD"
  ],
  "disc_number": 1,
  "duration_ms": 207959,
  "explicit": false,
  "external_ids": {
    "isrc": "USUM71703861"
  },
  "external_urls": {
    "spotify": "https://open.spotify.com/track/11dFghVXANMlKmJXsNCbNl"
  },
  "href": "https://api.spotify.com/v1/tracks/11dFghVXANMlKmJXsNCbNl",
  "id": "11dFghVXANMlKmJXsNCbNl",
  "is_local": false,
  "name": "Cut To The Feeling",
  "popularity": 63,
  "preview_url": "https://p.scdn.co/mp3-preview/3eb16018c2a700240e9dfb8817b6f2d041f15eb1?cid=774b29d4f13844c495f206cafdad9c86",
  "track_number": 1,
  "type": "track",
  "uri": "spotify:track:11dFghVXANMlKmJXsNCbNl"
}]
}
""".data(using: .utf8)!
        let networkResponse: (Data?, HTTPURLResponse?, Error?) = (data, response, nil)
        let trackID = "track_1223"
        let client = SpotifyClient(client: FakeClient(expected: networkResponse))
        client.tracks(trackIDs: [trackID]) {
            switch $0 {
            case .success(let tracks):
                XCTAssertEqual(expectedTracks, tracks)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testArtist() {
        let images = [
            Image(
                url: "https://i.scdn.co/image/eb266625dab075341e8c4378a177a27370f91903",
                width: 1000,
                height: 816
            )
        ]
        let expectedArtist = Artist(
            externalUrls: ["spotify" : "https://open.spotify.com/artist/0OdUWJ0sBjDrqHygGUXeCF"],
            followers: Followers(href: nil, total: 306565),
            genres: ["indie folk", "indie pop"],
            href: "https://api.spotify.com/v1/artists/0OdUWJ0sBjDrqHygGUXeCF",
            id: "0OdUWJ0sBjDrqHygGUXeCF",
            images: images,
            name: "Band of Horses",
            popularity: 59,
            uri: "spotify:artist:0OdUWJ0sBjDrqHygGUXeCF"
        )
        let data = """
{
  "external_urls" : {
    "spotify" : "https://open.spotify.com/artist/0OdUWJ0sBjDrqHygGUXeCF"
  },
  "followers" : {
    "href" : null,
    "total" : 306565
  },
  "genres" : [ "indie folk", "indie pop" ],
  "href" : "https://api.spotify.com/v1/artists/0OdUWJ0sBjDrqHygGUXeCF",
  "id" : "0OdUWJ0sBjDrqHygGUXeCF",
  "images" : [ {
    "height" : 816,
    "url" : "https://i.scdn.co/image/eb266625dab075341e8c4378a177a27370f91903",
    "width" : 1000
  }],
  "name" : "Band of Horses",
  "popularity" : 59,
  "type" : "artist",
  "uri" : "spotify:artist:0OdUWJ0sBjDrqHygGUXeCF"
}
""".data(using: .utf8)!
        let networkResponse: (Data?, HTTPURLResponse?, Error?) = (data, response, nil)
        let artistID = "artist_1223"
        let client = SpotifyClient(client: FakeClient(expected: networkResponse))
        client.artist(artistID: artistID) {
            switch $0 {
            case .success(let artist):
                XCTAssertEqual(expectedArtist, artist)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testArtists() {
        let images = [
            Image(
                url: "https://i.scdn.co/image/eb266625dab075341e8c4378a177a27370f91903",
                width: 1000,
                height: 816
            )
        ]
        let expectedArtists = Artists(
            artists:[
                Artist(
                    externalUrls: ["spotify" : "https://open.spotify.com/artist/0OdUWJ0sBjDrqHygGUXeCF"],
                    followers: Followers(href: nil, total: 306565),
                    genres: ["indie folk", "indie pop"],
                    href: "https://api.spotify.com/v1/artists/0OdUWJ0sBjDrqHygGUXeCF",
                    id: "0OdUWJ0sBjDrqHygGUXeCF",
                    images: images,
                    name: "Band of Horses",
                    popularity: 59,
                    uri: "spotify:artist:0OdUWJ0sBjDrqHygGUXeCF"
                )
            ]
        )
        let data = """
{
"artists": [
{
  "external_urls" : {
    "spotify" : "https://open.spotify.com/artist/0OdUWJ0sBjDrqHygGUXeCF"
  },
  "followers" : {
    "href" : null,
    "total" : 306565
  },
  "genres" : [ "indie folk", "indie pop" ],
  "href" : "https://api.spotify.com/v1/artists/0OdUWJ0sBjDrqHygGUXeCF",
  "id" : "0OdUWJ0sBjDrqHygGUXeCF",
  "images" : [ {
    "height" : 816,
    "url" : "https://i.scdn.co/image/eb266625dab075341e8c4378a177a27370f91903",
    "width" : 1000
  }],
  "name" : "Band of Horses",
  "popularity" : 59,
  "type" : "artist",
  "uri" : "spotify:artist:0OdUWJ0sBjDrqHygGUXeCF"
}]
}
""".data(using: .utf8)!
        let networkResponse: (Data?, HTTPURLResponse?, Error?) = (data, response, nil)
        let artistID = "artist_1223"
        let client = SpotifyClient(client: FakeClient(expected: networkResponse))
        client.artists(artistIDs: [artistID]) {
            switch $0 {
            case .success(let artists):
                XCTAssertEqual(expectedArtists, artists)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testArtistAlbums() {
        let artist = SimplifiedArtist(
            externalUrls: ["spotify": "https://open.spotify.com/artist/0LyfQWJT6nXafLPZqxe9Of"],
            href: "https://api.spotify.com/v1/artists/0LyfQWJT6nXafLPZqxe9Of",
            id: "0LyfQWJT6nXafLPZqxe9Of",
            name: "Various Artists",
            uri: "spotify:artist:0LyfQWJT6nXafLPZqxe9Of"
        )
        let album = SimplifiedAlbum(
            artists: [artist],
            albumType: .album,
            availableMarkets: ["AD"],
            externalUrls: ["spotify": "https://open.spotify.com/album/43977e0YlJeMXG77uCCSMX"],
            href: "https://api.spotify.com/v1/albums/43977e0YlJeMXG77uCCSMX",
            id: "43977e0YlJeMXG77uCCSMX",
            images: [Image(url: "https://i.scdn.co/image/0da79956d0440a55b20ea4e8e38877bce43275cd", width: nil, height: nil)],
            name: "Shut Up Lets Dance (Vol. II)",
            uri: "spotify:album:43977e0YlJeMXG77uCCSMX"
        )
        let expectedPage = Page<SimplifiedAlbum>(
            href: "https://api.spotify.com/v1/artists/1vCWHaC5f2uS3yhpwWbIA6/albums?offset=0&limit=2&include_groups=appears_on&market=ES",
            items: [album],
            limit: 2,
            next: "https://api.spotify.com/v1/artists/1vCWHaC5f2uS3yhpwWbIA6/albums?offset=2&limit=2&include_groups=appears_on&market=ES",
            offset: 0,
            previous: nil,
            total: 308
        )
        let data = """
{
  "href": "https://api.spotify.com/v1/artists/1vCWHaC5f2uS3yhpwWbIA6/albums?offset=0&limit=2&include_groups=appears_on&market=ES",
  "items": [
    {
      "album_group": "appears_on",
      "album_type": "album",
      "artists": [
        {
          "external_urls": {
            "spotify": "https://open.spotify.com/artist/0LyfQWJT6nXafLPZqxe9Of"
          },
          "href": "https://api.spotify.com/v1/artists/0LyfQWJT6nXafLPZqxe9Of",
          "id": "0LyfQWJT6nXafLPZqxe9Of",
          "name": "Various Artists",
          "type": "artist",
          "uri": "spotify:artist:0LyfQWJT6nXafLPZqxe9Of"
        }
      ],
      "available_markets": ["AD"],
      "external_urls": {
        "spotify": "https://open.spotify.com/album/43977e0YlJeMXG77uCCSMX"
      },
      "href": "https://api.spotify.com/v1/albums/43977e0YlJeMXG77uCCSMX",
      "id": "43977e0YlJeMXG77uCCSMX",
      "images": [
        {
          "url": "https://i.scdn.co/image/0da79956d0440a55b20ea4e8e38877bce43275cd"
        }
      ],
      "name": "Shut Up Lets Dance (Vol. II)",
      "release_date": "2018-02-09",
      "release_date_precision": "day",
      "type": "album",
      "uri": "spotify:album:43977e0YlJeMXG77uCCSMX"
    }
  ],
  "limit": 2,
  "next": "https://api.spotify.com/v1/artists/1vCWHaC5f2uS3yhpwWbIA6/albums?offset=2&limit=2&include_groups=appears_on&market=ES",
  "offset": 0,
  "previous": null,
  "total": 308
}
""".data(using: .utf8)!
        let networkResponse: (Data?, HTTPURLResponse?, Error?) = (data, response, nil)
        let artistID = "artist_1223"
        let client = SpotifyClient(client: FakeClient(expected: networkResponse))
        client.artistAlbums(artistID: artistID) {
            switch $0 {
            case .success(let page):
                XCTAssertEqual(expectedPage, page)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testArtistTopTracks() {
        let images = [
            Image(
                url: "https://i.scdn.co/image/966ade7a8c43b72faa53822b74a899c675aaafee",
                width: nil, height: nil
            )
        ]
        let artists = [
            SimplifiedArtist(
                externalUrls: ["spotify": "https://open.spotify.com/artist/6sFIWsNpZYqfjUpaCgueju"],
                href: "https://api.spotify.com/v1/artists/6sFIWsNpZYqfjUpaCgueju",
                id: "6sFIWsNpZYqfjUpaCgueju",
                name: "Carly Rae Jepsen",
                uri: "spotify:artist:6sFIWsNpZYqfjUpaCgueju"
            )
        ]
        let album = SimplifiedAlbum(
            artists: artists, albumType: .single,
            availableMarkets: ["AD"],
            externalUrls: ["spotify": "https://open.spotify.com/album/0tGPJ0bkWOUmH7MEOR77qc"],
            href: "https://api.spotify.com/v1/albums/0tGPJ0bkWOUmH7MEOR77qc",
            id: "0tGPJ0bkWOUmH7MEOR77qc",
            images: images, name: "Cut To The Feeling",
            uri: "spotify:album:0tGPJ0bkWOUmH7MEOR77qc"
        )
        let track = Track(
            album: album, artists: artists, availableMarkets: ["AD"],
            discNumber: 1, durationMs: 207959,
            externalIds: ["isrc": "USUM71703861"],
            externalUrls: ["spotify": "https://open.spotify.com/track/11dFghVXANMlKmJXsNCbNl"],
            href: "https://api.spotify.com/v1/tracks/11dFghVXANMlKmJXsNCbNl",
            id: "11dFghVXANMlKmJXsNCbNl", name: "Cut To The Feeling",
            popularity: 63,
            previewUrl: "https://p.scdn.co/mp3-preview/3eb16018c2a700240e9dfb8817b6f2d041f15eb1?cid=774b29d4f13844c495f206cafdad9c86",
            trackNumber: 1, uri: "spotify:track:11dFghVXANMlKmJXsNCbNl"
        )
        let expectedTracks = Tracks(tracks: [track])
        let data = """
{"tracks": [
{
  "album": {
    "album_type": "single",
    "artists": [
      {
        "external_urls": {
          "spotify": "https://open.spotify.com/artist/6sFIWsNpZYqfjUpaCgueju"
        },
        "href": "https://api.spotify.com/v1/artists/6sFIWsNpZYqfjUpaCgueju",
        "id": "6sFIWsNpZYqfjUpaCgueju",
        "name": "Carly Rae Jepsen",
        "type": "artist",
        "uri": "spotify:artist:6sFIWsNpZYqfjUpaCgueju"
      }
    ],
    "available_markets": [
      "AD"
    ],
    "external_urls": {
      "spotify": "https://open.spotify.com/album/0tGPJ0bkWOUmH7MEOR77qc"
    },
    "href": "https://api.spotify.com/v1/albums/0tGPJ0bkWOUmH7MEOR77qc",
    "id": "0tGPJ0bkWOUmH7MEOR77qc",
    "images": [
      {
        "url": "https://i.scdn.co/image/966ade7a8c43b72faa53822b74a899c675aaafee"
      }
    ],
    "name": "Cut To The Feeling",
    "release_date": "2017-05-26",
    "release_date_precision": "day",
    "type": "album",
    "uri": "spotify:album:0tGPJ0bkWOUmH7MEOR77qc"
  },
  "artists": [
    {
      "external_urls": {
        "spotify": "https://open.spotify.com/artist/6sFIWsNpZYqfjUpaCgueju"
      },
      "href": "https://api.spotify.com/v1/artists/6sFIWsNpZYqfjUpaCgueju",
      "id": "6sFIWsNpZYqfjUpaCgueju",
      "name": "Carly Rae Jepsen",
      "type": "artist",
      "uri": "spotify:artist:6sFIWsNpZYqfjUpaCgueju"
    }
  ],
  "available_markets": [
    "AD"
  ],
  "disc_number": 1,
  "duration_ms": 207959,
  "explicit": false,
  "external_ids": {
    "isrc": "USUM71703861"
  },
  "external_urls": {
    "spotify": "https://open.spotify.com/track/11dFghVXANMlKmJXsNCbNl"
  },
  "href": "https://api.spotify.com/v1/tracks/11dFghVXANMlKmJXsNCbNl",
  "id": "11dFghVXANMlKmJXsNCbNl",
  "is_local": false,
  "name": "Cut To The Feeling",
  "popularity": 63,
  "preview_url": "https://p.scdn.co/mp3-preview/3eb16018c2a700240e9dfb8817b6f2d041f15eb1?cid=774b29d4f13844c495f206cafdad9c86",
  "track_number": 1,
  "type": "track",
  "uri": "spotify:track:11dFghVXANMlKmJXsNCbNl"
}]
}
""".data(using: .utf8)!
        let networkResponse: (Data?, HTTPURLResponse?, Error?) = (data, response, nil)
        let artistID = "artist_1223"
        let client = SpotifyClient(client: FakeClient(expected: networkResponse))
        client.artistTopTracks(artistID: artistID, country: "AD") {
            switch $0 {
            case .success(let tracks):
                XCTAssertEqual(expectedTracks, tracks)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }


    func testRelatedArtists() {
        let images = [
            Image(
                url: "https://i.scdn.co/image/eb266625dab075341e8c4378a177a27370f91903",
                width: 1000,
                height: 816
            )
        ]
        let expectedArtists = Artists(
            artists:[
                Artist(
                    externalUrls: ["spotify" : "https://open.spotify.com/artist/0OdUWJ0sBjDrqHygGUXeCF"],
                    followers: Followers(href: nil, total: 306565),
                    genres: ["indie folk", "indie pop"],
                    href: "https://api.spotify.com/v1/artists/0OdUWJ0sBjDrqHygGUXeCF",
                    id: "0OdUWJ0sBjDrqHygGUXeCF",
                    images: images,
                    name: "Band of Horses",
                    popularity: 59,
                    uri: "spotify:artist:0OdUWJ0sBjDrqHygGUXeCF"
                )
            ]
        )
        let data = """
{
"artists": [
{
  "external_urls" : {
    "spotify" : "https://open.spotify.com/artist/0OdUWJ0sBjDrqHygGUXeCF"
  },
  "followers" : {
    "href" : null,
    "total" : 306565
  },
  "genres" : [ "indie folk", "indie pop" ],
  "href" : "https://api.spotify.com/v1/artists/0OdUWJ0sBjDrqHygGUXeCF",
  "id" : "0OdUWJ0sBjDrqHygGUXeCF",
  "images" : [ {
    "height" : 816,
    "url" : "https://i.scdn.co/image/eb266625dab075341e8c4378a177a27370f91903",
    "width" : 1000
  }],
  "name" : "Band of Horses",
  "popularity" : 59,
  "type" : "artist",
  "uri" : "spotify:artist:0OdUWJ0sBjDrqHygGUXeCF"
}]
}
""".data(using: .utf8)!
        let networkResponse: (Data?, HTTPURLResponse?, Error?) = (data, response, nil)
        let artistID = "artist_1223"
        let client = SpotifyClient(client: FakeClient(expected: networkResponse))
        client.relatedArtists(artistID: artistID) {
            switch $0 {
            case .success(let artists):
                XCTAssertEqual(expectedArtists, artists)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testAlbum() {
        let images = [
            Image(
                url: "https://i.scdn.co/image/07c323340e03e25a8e5dd5b9a8ec72b69c50089d",
                width: 640, height: 640
            )
        ]
        let artist = SimplifiedArtist(
            externalUrls: ["spotify" : "https://open.spotify.com/artist/2BTZIqw0ntH9MvilQ3ewNY"],
            href: "https://api.spotify.com/v1/artists/2BTZIqw0ntH9MvilQ3ewNY",
            id: "2BTZIqw0ntH9MvilQ3ewNY",
            name: "Cyndi Lauper",
            uri: "spotify:artist:2BTZIqw0ntH9MvilQ3ewNY"
        )
        let track = SimplifiedTrack(
            artists: [artist],
            availableMarkets: ["AD"],
            discNumber: 1,
            durationMs: 305560,
            explicit: false,
            externalUrls: ["spotify" : "https://open.spotify.com/track/3f9zqUnrnIq0LANhmnaF0V"],
            href: "https://api.spotify.com/v1/tracks/3f9zqUnrnIq0LANhmnaF0V",
            id: "3f9zqUnrnIq0LANhmnaF0V",
            name: "Money Changes Everything",
            previewUrl: "https://p.scdn.co/mp3-preview/01bb2a6c9a89c05a4300aea427241b1719a26b06",
            trackNumber: 1,
            uri: "spotify:track:3f9zqUnrnIq0LANhmnaF0V"
        )

        let page = Page(
            href: "https://api.spotify.com/v1/albums/0sNOF9WDwhWunNAHPD3Baj/tracks?offset=0&limit=50",
            items: [track],
            limit: 50,
            next: nil,
            offset: 0,
            previous: nil,
            total: 13
        )
        let expectedAlbum = Album(
            artists: [artist],
            albumType: .album,
            availableMarkets: ["AD"],
            copyrights: [["text" : "(P) 2000 Sony Music Entertainment Inc.", "type" : "P"]],
            externalIds: ["upc" : "5099749994324"],
            externalUrls: ["spotify" : "https://open.spotify.com/album/0sNOF9WDwhWunNAHPD3Baj"],
            genres: [],
            href: "https://api.spotify.com/v1/albums/0sNOF9WDwhWunNAHPD3Baj",
            id: "0sNOF9WDwhWunNAHPD3Baj",
            images: images,
            name: "She's So Unusual",
            popularity: 39,
            releaseDate: "1983",
            releaseDatePrecision: "year",
            tracks: page,
            uri: "spotify:album:0sNOF9WDwhWunNAHPD3Baj"
        )
        let data = """
{
  "album_type" : "album",
  "artists" : [ {
    "external_urls" : {
      "spotify" : "https://open.spotify.com/artist/2BTZIqw0ntH9MvilQ3ewNY"
    },
    "href" : "https://api.spotify.com/v1/artists/2BTZIqw0ntH9MvilQ3ewNY",
    "id" : "2BTZIqw0ntH9MvilQ3ewNY",
    "name" : "Cyndi Lauper",
    "type" : "artist",
    "uri" : "spotify:artist:2BTZIqw0ntH9MvilQ3ewNY"
  } ],
  "available_markets" : [ "AD" ],
  "copyrights" : [ {
    "text" : "(P) 2000 Sony Music Entertainment Inc.",
    "type" : "P"
  } ],
  "external_ids" : {
    "upc" : "5099749994324"
  },
  "external_urls" : {
    "spotify" : "https://open.spotify.com/album/0sNOF9WDwhWunNAHPD3Baj"
  },
  "genres" : [ ],
  "href" : "https://api.spotify.com/v1/albums/0sNOF9WDwhWunNAHPD3Baj",
  "id" : "0sNOF9WDwhWunNAHPD3Baj",
  "images" : [ {
    "height" : 640,
    "url" : "https://i.scdn.co/image/07c323340e03e25a8e5dd5b9a8ec72b69c50089d",
    "width" : 640
  } ],
  "name" : "She's So Unusual",
  "popularity" : 39,
  "release_date" : "1983",
  "release_date_precision" : "year",
  "tracks" : {
    "href" : "https://api.spotify.com/v1/albums/0sNOF9WDwhWunNAHPD3Baj/tracks?offset=0&limit=50",
    "items" : [ {
      "artists" : [ {
        "external_urls" : {
          "spotify" : "https://open.spotify.com/artist/2BTZIqw0ntH9MvilQ3ewNY"
        },
        "href" : "https://api.spotify.com/v1/artists/2BTZIqw0ntH9MvilQ3ewNY",
        "id" : "2BTZIqw0ntH9MvilQ3ewNY",
        "name" : "Cyndi Lauper",
        "type" : "artist",
        "uri" : "spotify:artist:2BTZIqw0ntH9MvilQ3ewNY"
      } ],
      "available_markets" : [ "AD"  ],
      "disc_number" : 1,
      "duration_ms" : 305560,
      "explicit" : false,
      "external_urls" : {
        "spotify" : "https://open.spotify.com/track/3f9zqUnrnIq0LANhmnaF0V"
      },
      "href" : "https://api.spotify.com/v1/tracks/3f9zqUnrnIq0LANhmnaF0V",
      "id" : "3f9zqUnrnIq0LANhmnaF0V",
      "name" : "Money Changes Everything",
      "preview_url" : "https://p.scdn.co/mp3-preview/01bb2a6c9a89c05a4300aea427241b1719a26b06",
      "track_number" : 1,
      "type" : "track",
      "uri" : "spotify:track:3f9zqUnrnIq0LANhmnaF0V"
    } ],
    "limit" : 50,
    "next" : null,
    "offset" : 0,
    "previous" : null,
    "total" : 13
  },
  "type" : "album",
  "uri" : "spotify:album:0sNOF9WDwhWunNAHPD3Baj"
}
""".data(using: .utf8)!
        let networkResponse: (Data?, HTTPURLResponse?, Error?) = (data, response, nil)
        let albumID = "album_1223"
        let client = SpotifyClient(client: FakeClient(expected: networkResponse))
        client.album(albumID: albumID) {
            switch $0 {
            case .success(let album):
                XCTAssertEqual(expectedAlbum, album)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testSearchArtist() {
        let images = [
            Image(
                url: "https://i.scdn.co/image/f2798ddab0c7b76dc2d270b65c4f67ddef7f6718",
                width: 640,
                height: 640
            )
        ]
        let page = Page(
            href: "https://api.spotify.com/v1/search?query=tania+bowra&offset=0&limit=20&type=artist",
            items: [
                Artist(
                    externalUrls: ["spotify": "https://open.spotify.com/artist/08td7MxkoHQkXnWAYD8d6Q"],
                    followers: Followers(href: nil, total: 147),
                    genres: [],
                    href: "https://api.spotify.com/v1/artists/08td7MxkoHQkXnWAYD8d6Q",
                    id: "08td7MxkoHQkXnWAYD8d6Q",
                    images: images,
                    name: "Tania Bowra",
                    popularity: 0,
                    uri: "spotify:artist:08td7MxkoHQkXnWAYD8d6Q"
                )
            ],
            limit: 20,
            next: nil,
            offset: 0,
            previous: nil,
            total: 1
        )
        let expected = ArtistSearch(artists: page)
        let data = """
{
  "artists": {
    "href": "https://api.spotify.com/v1/search?query=tania+bowra&offset=0&limit=20&type=artist",
    "items": [ {
      "external_urls": {
        "spotify": "https://open.spotify.com/artist/08td7MxkoHQkXnWAYD8d6Q"
      },
      "followers": {
        "href": null,
        "total": 147
      },
      "genres": [ ],
      "href": "https://api.spotify.com/v1/artists/08td7MxkoHQkXnWAYD8d6Q",
      "id": "08td7MxkoHQkXnWAYD8d6Q",
      "images": [ {
        "height": 640,
        "url": "https://i.scdn.co/image/f2798ddab0c7b76dc2d270b65c4f67ddef7f6718",
        "width": 640
      } ],
      "name": "Tania Bowra",
      "popularity": 0,
      "type": "artist",
      "uri": "spotify:artist:08td7MxkoHQkXnWAYD8d6Q"
    } ],
    "limit": 20,
    "next": null,
    "offset": 0,
    "previous": null,
    "total": 1
  }
}
""".data(using: .utf8)!
        let networkResponse: (Data?, HTTPURLResponse?, Error?) = (data, response, nil)
        let client = SpotifyClient(client: FakeClient(expected: networkResponse))
        client.searchArtist(query: "Example Query") {
            switch $0 {
            case .success(let result):
                XCTAssertEqual(expected, result)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testSearchPlaylist() {
        let user = PublicUser(
            displayName: "Holger Ihrig",
            externalUrls: ["spotify": "https://open.spotify.com/user/holgar_the_red"],
            followers: nil,
            href: "https://api.spotify.com/v1/users/holgar_the_red",
            id: "holgar_the_red",
            images: nil,
            uri: "spotify:user:holgar_the_red"
        )
        let images = [
            Image(
                url: "https://i.scdn.co/image/067acb64fa0b09d3f4892ac3924b17dcb1acdd1b",
                width: 300,
                height: 300
            )
        ]
        let page = Page(
            href: "https://api.spotify.com/v1/search?query=%22doom+metal%22&type=playlist&market=AU&offset=0&limit=20",
            items: [
                SimplifiedPlaylist(
                    collaborative: false,
                    externalUrls: ["spotify": "https://open.spotify.com/user/holgar_the_red/playlist/5Lzif2bIMW8RiRLtbYJHU0"],
                    href: "https://api.spotify.com/v1/users/holgar_the_red/playlists/5Lzif2bIMW8RiRLtbYJHU0",
                    id: "5Lzif2bIMW8RiRLtbYJHU0",
                    images: images,
                    name: "Doom Metal",
                    owner: user,
                    isPublic: true,
                    snapshotId: "MTY0LGYxYmFhNWQ1OGQwMzZlNzViZjM3OTRmN2QwZDgzNDI4NWZiMTQ1NmI=",
                    tracks: TracksObject(
                        href: "https://api.spotify.com/v1/users/holgar_the_red/playlists/5Lzif2bIMW8RiRLtbYJHU0/tracks",
                        total: 61
                    ),
                    uri: "spotify:user:holgar_the_red:playlist:5Lzif2bIMW8RiRLtbYJHU0"
                )
            ],
            limit: 20,
            next: "https://api.spotify.com/v1/search?query=%22doom+metal%22&type=playlist&market=AU&offset=20&limit=20",
            offset: 0,
            previous: nil,
            total: 1201
        )
        let expected = PlaylistSearch(playlists: page)
        let data = """
{
  "playlists": {
    "href": "https://api.spotify.com/v1/search?query=%22doom+metal%22&type=playlist&market=AU&offset=0&limit=20",
    "items": [
      {
        "collaborative": false,
        "external_urls": {
          "spotify": "https://open.spotify.com/user/holgar_the_red/playlist/5Lzif2bIMW8RiRLtbYJHU0"
        },
        "href": "https://api.spotify.com/v1/users/holgar_the_red/playlists/5Lzif2bIMW8RiRLtbYJHU0",
        "id": "5Lzif2bIMW8RiRLtbYJHU0",
        "images": [
          {
            "height": 300,
            "url": "https://i.scdn.co/image/067acb64fa0b09d3f4892ac3924b17dcb1acdd1b",
            "width": 300
          }
        ],
        "name": "Doom Metal",
        "owner": {
          "display_name": "Holger Ihrig",
          "external_urls": {
            "spotify": "https://open.spotify.com/user/holgar_the_red"
          },
          "href": "https://api.spotify.com/v1/users/holgar_the_red",
          "id": "holgar_the_red",
          "type": "user",
          "uri": "spotify:user:holgar_the_red"
        },
        "primary_color": null,
        "public": true,
        "snapshot_id": "MTY0LGYxYmFhNWQ1OGQwMzZlNzViZjM3OTRmN2QwZDgzNDI4NWZiMTQ1NmI=",
        "tracks": {
          "href": "https://api.spotify.com/v1/users/holgar_the_red/playlists/5Lzif2bIMW8RiRLtbYJHU0/tracks",
          "total": 61
        },
        "type": "playlist",
        "uri": "spotify:user:holgar_the_red:playlist:5Lzif2bIMW8RiRLtbYJHU0"
      }
    ],
    "limit": 20,
    "next": "https://api.spotify.com/v1/search?query=%22doom+metal%22&type=playlist&market=AU&offset=20&limit=20",
    "offset": 0,
    "previous": null,
    "total": 1201
  }
}
""".data(using: .utf8)!
        let networkResponse: (Data?, HTTPURLResponse?, Error?) = (data, response, nil)
        let client = SpotifyClient(client: FakeClient(expected: networkResponse))
        client.searchPlaylist(query: "Example Query") {
            switch $0 {
            case .success(let result):
                XCTAssertEqual(expected, result)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testUser() {
        let user = PublicUser(
            displayName: "Holger Ihrig",
            externalUrls: ["spotify": "https://open.spotify.com/user/holgar_the_red"],
            followers: nil,
            href: "https://api.spotify.com/v1/users/holgar_the_red",
            id: "holgar_the_red",
            images: nil,
            uri: "spotify:user:holgar_the_red"
        )
        let data = """
{
  "display_name": "Holger Ihrig",
  "external_urls": {
    "spotify": "https://open.spotify.com/user/holgar_the_red"
  },
  "href": "https://api.spotify.com/v1/users/holgar_the_red",
  "id": "holgar_the_red",
  "type": "user",
  "uri": "spotify:user:holgar_the_red"
}
""".data(using: .utf8)!
        let networkResponse: (Data?, HTTPURLResponse?, Error?) = (data, response, nil)
        let client = SpotifyClient(client: FakeClient(expected: networkResponse))
        client.user(userID: "example-user123") {
            switch $0 {
            case .success(let result):
                XCTAssertEqual(user, result)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
}
