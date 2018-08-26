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
}
