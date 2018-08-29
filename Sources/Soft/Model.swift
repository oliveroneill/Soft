import Foundation

/// See https://developer.spotify.com/documentation/web-api/reference/ for
/// documentation on these structs

public struct Image: Decodable, Equatable {
    let url: String
    let width: UInt?
    let height: UInt?
}

/// https://developer.spotify.com/web-api/object-model/#album-object-simplified
public struct SimplifiedAlbum: Decodable, Equatable {
    let artists: [SimplifiedArtist]
    let albumType: AlbumType
    let availableMarkets: [String]
    let externalUrls: [String:String]
    let href: String
    let id: String
    let images: [Image]
    let name: String
    let uri: String

    enum CodingKeys: String, CodingKey {
        case artists
        case albumType = "album_type"
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href
        case id
        case images
        case name
        case uri
    }
}

/// https://developer.spotify.com/web-api/object-model/#artist-object-simplified
public struct SimplifiedArtist: Decodable, Equatable {
    let externalUrls: [String:String]
    let href: String
    let id: String
    let name: String
    let uri: String
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href
        case id
        case name
        case uri
    }
}

/// https://developer.spotify.com/web-api/object-model/#track-object-simplified
public struct SimplifiedTrack: Decodable, Equatable {
    let artists: [SimplifiedArtist]
    let availableMarkets: [String]?
    let discNumber: Int
    let durationMs: UInt
    let explicit: Bool
    let externalUrls: [String:String]
    let href: String
    let id: String
    let name: String
    let previewUrl: String?
    let trackNumber: UInt
    let uri: String

    enum CodingKeys: String, CodingKey {
        case artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMs = "duration_ms"
        case explicit
        case externalUrls = "external_urls"
        case href
        case id
        case name
        case previewUrl = "preview_url"
        case trackNumber = "track_number"
        case uri
    }
}

/// https://developer.spotify.com/web-api/object-model/#track-object-full
public struct Track: Decodable, Equatable {
    let album: SimplifiedAlbum
    let artists: [SimplifiedArtist]
    let availableMarkets: [String]
    let discNumber: Int
    let durationMs: UInt
    let externalIds: [String:String]
    let externalUrls: [String:String]
    let href: String
    let id: String
    let name: String
    let popularity: Int
    let previewUrl: String?
    let trackNumber: UInt
    let uri: String

    enum CodingKeys: String, CodingKey {
        case album
        case artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMs = "duration_ms"
        case externalIds = "external_ids"
        case externalUrls = "external_urls"
        case href
        case id
        case name
        case popularity
        case previewUrl = "preview_url"
        case trackNumber = "track_number"
        case uri
    }
}

public struct Tracks: Decodable, Equatable {
    let tracks: [Track]
}

/// https://developer.spotify.com/documentation/web-api/reference/object-model/#followers-object
public struct Followers: Decodable, Equatable {
    let href: String?
    let total: Int
}

/// https://developer.spotify.com/web-api/object-model/#artist-object-full
public struct Artist: Decodable, Equatable {
    let externalUrls: [String:String]
    let followers: Followers
    let genres: [String]
    let href: String
    let id: String
    let images: [Image]
    let name: String
    let popularity: UInt
    let uri: String

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers
        case genres
        case href
        case id
        case images
        case name
        case popularity
        case uri
    }
}

public struct Artists: Decodable, Equatable {
    let artists: [Artist]
}

public enum AlbumType: String, Decodable {
    case album = "album"
    case single = "single"
    case appearsOn = "appears_on"
    case compilation = "compilation"
}

/// https://developer.spotify.com/web-api/object-model/#paging-object
public struct Page<T:Decodable & Equatable>: Decodable, Equatable {
    let href: String
    let items: [T]
    let limit: UInt
    let next: String?
    let offset: UInt
    let previous: String?
    let total: UInt
}

/// https://developer.spotify.com/web-api/object-model/#album-object-full
public struct Album: Decodable, Equatable {
    let artists: [SimplifiedArtist]
    let albumType: AlbumType
    let availableMarkets: [String]
    let copyrights: [[String:String]]
    let externalIds: [String:String]
    let externalUrls: [String:String]
    let genres: [String]
    let href: String
    let id: String
    let images: [Image]
    let name: String
    let popularity: UInt
    let releaseDate: String
    let releaseDatePrecision: String
    let tracks: Page<SimplifiedTrack>
    let uri: String

    enum CodingKeys: String, CodingKey {
        case artists
        case albumType = "album_type"
        case availableMarkets = "available_markets"
        case copyrights
        case externalIds = "external_ids"
        case externalUrls = "external_urls"
        case genres
        case href
        case id
        case images
        case name
        case popularity
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case tracks
        case uri
    }
}

public struct PublicUser: Decodable, Equatable {
    let displayName: String?
    let externalUrls: [String:String]
    let followers: [String:String]?
    let href: String
    let id: String
    let images: [Image]?
    let uri: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case externalUrls = "external_urls"
        case followers
        case href
        case id
        case images
        case uri
    }
}

/// See https://developer.spotify.com/documentation/web-api/reference/search/search/#playlist-object---simplified
public struct TracksObject: Decodable, Equatable {
    let href: String
    let total:Int
}

/// See https://developer.spotify.com/documentation/web-api/reference/search/search/#playlist-object---simplified
public struct SimplifiedPlaylist: Decodable, Equatable {
    let collaborative: Bool
    let externalUrls: [String:String]
    let href: String
    let id: String
    let images: [Image]
    let name: String
    let owner: PublicUser
    let isPublic: Bool?
    let snapshotId: String
    let tracks: TracksObject
    let uri: String

    // Since public is a keyword we must use isPublic and convert it
    enum CodingKeys: String, CodingKey {
        case isPublic = "public"
        case collaborative
        case externalUrls = "external_urls"
        case href
        case id
        case images
        case name
        case owner
        case snapshotId = "snapshot_id"
        case tracks
        case uri
    }
}

public struct Albums: Decodable, Equatable {
    let albums: [Album]
}

public struct AlbumSearch: Decodable, Equatable {
    let albums: Page<SimplifiedAlbum>
}

public struct ArtistSearch: Decodable, Equatable {
    let artists: Page<Artist>
}

public struct TrackSearch: Decodable, Equatable {
    let artists: Page<Track>
}

public struct PlaylistSearch: Decodable, Equatable {
    let playlists: Page<SimplifiedPlaylist>
}

/// Context object
/// See https://developer.spotify.com/web-api/get-the-users-currently-playing-track/
public struct Context: Decodable, Equatable {
    let uri: String
    let href: String
    let externalUrls: [String:String]

    enum CodingKeys: String, CodingKey {
        case uri
        case href
        case externalUrls = "external_urls"
    }
}

/// See https://developer.spotify.com/web-api/object-model/#play-history-object
public struct PlayHistory: Decodable, Equatable {
    let track: SimplifiedTrack
    let playedAt: Date
    let context: Context?

    enum CodingKeys: String, CodingKey {
        case track
        case playedAt = "played_at"
        case context
    }
}

/// See https://developer.spotify.com/web-api/object-model/#cursor-based-paging-object
public struct CursorBasedPage<T:Decodable & Equatable>: Decodable, Equatable {
    let href: String
    let items: [T]
    let limit: UInt
    let next: String?
    let cursors: Cursor
    let total: UInt?
}

/// See https://developer.spotify.com/web-api/object-model/#cursor-object
public struct Cursor: Decodable, Equatable {
    let before: String?
    let after: String?
}
