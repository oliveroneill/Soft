import Foundation

/// See https://developer.spotify.com/documentation/web-api/reference/ for
/// documentation on these structs

public struct Image: Decodable, Equatable {
    public let url: String
    public let width: UInt?
    public let height: UInt?
}

/// https://developer.spotify.com/web-api/object-model/#album-object-simplified
public struct SimplifiedAlbum: Decodable, Equatable {
    public let artists: [SimplifiedArtist]
    public let albumType: AlbumType
    public let availableMarkets: [String]
    public let externalUrls: [String:String]
    public let href: String
    public let id: String
    public let images: [Image]
    public let name: String
    public let uri: String

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
    public let externalUrls: [String:String]
    public let href: String
    public let id: String
    public let name: String
    public let uri: String
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
    public let artists: [SimplifiedArtist]
    public let availableMarkets: [String]?
    public let discNumber: Int
    public let durationMs: UInt
    public let explicit: Bool
    public let externalUrls: [String:String]
    public let href: String
    public let id: String
    public let name: String
    public let previewUrl: String?
    public let trackNumber: UInt
    public let uri: String

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
    public let album: SimplifiedAlbum
    public let artists: [SimplifiedArtist]
    public let availableMarkets: [String]
    public let discNumber: Int
    public let durationMs: UInt
    public let externalIds: [String:String]
    public let externalUrls: [String:String]
    public let href: String
    public let id: String
    public let name: String
    public let popularity: Int
    public let previewUrl: String?
    public let trackNumber: UInt
    public let uri: String

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
    public let tracks: [Track]
}

/// https://developer.spotify.com/documentation/web-api/reference/object-model/#followers-object
public struct Followers: Decodable, Equatable {
    public let href: String?
    public let total: Int
}

/// https://developer.spotify.com/web-api/object-model/#artist-object-full
public struct Artist: Decodable, Equatable {
    public let externalUrls: [String:String]
    public let followers: Followers
    public let genres: [String]
    public let href: String
    public let id: String
    public let images: [Image]
    public let name: String
    public let popularity: UInt
    public let uri: String

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
    public let artists: [Artist]
}

public enum AlbumType: String, Decodable {
    case album = "album"
    case single = "single"
    case appearsOn = "appears_on"
    case compilation = "compilation"
}

/// https://developer.spotify.com/web-api/object-model/#paging-object
public struct Page<T:Decodable & Equatable>: Decodable, Equatable {
    public let href: String
    public let items: [T]
    public let limit: UInt
    public let next: String?
    public let offset: UInt
    public let previous: String?
    public let total: UInt
}

/// https://developer.spotify.com/web-api/object-model/#album-object-full
public struct Album: Decodable, Equatable {
    public let artists: [SimplifiedArtist]
    public let albumType: AlbumType
    public let availableMarkets: [String]
    public let copyrights: [[String:String]]
    public let externalIds: [String:String]
    public let externalUrls: [String:String]
    public let genres: [String]
    public let href: String
    public let id: String
    public let images: [Image]
    public let name: String
    public let popularity: UInt
    public let releaseDate: String
    public let releaseDatePrecision: String
    public let tracks: Page<SimplifiedTrack>
    public let uri: String

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
    public let displayName: String?
    public let externalUrls: [String:String]
    public let followers: [String:String]?
    public let href: String
    public let id: String
    public let images: [Image]?
    public let uri: String

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
    public let href: String
    public let total:Int
}

/// See https://developer.spotify.com/documentation/web-api/reference/search/search/#playlist-object---simplified
public struct SimplifiedPlaylist: Decodable, Equatable {
    public let collaborative: Bool
    public let externalUrls: [String:String]
    public let href: String
    public let id: String
    public let images: [Image]
    public let name: String
    public let owner: PublicUser
    public let isPublic: Bool?
    public let snapshotId: String
    public let tracks: TracksObject
    public let uri: String

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
    public let albums: [Album]
}

public struct AlbumSearch: Decodable, Equatable {
    public let albums: Page<SimplifiedAlbum>
}

public struct ArtistSearch: Decodable, Equatable {
    public let artists: Page<Artist>
}

public struct TrackSearch: Decodable, Equatable {
    public let artists: Page<Track>
}

public struct PlaylistSearch: Decodable, Equatable {
    public let playlists: Page<SimplifiedPlaylist>
}

/// Context object
/// See https://developer.spotify.com/web-api/get-the-users-currently-playing-track/
public struct Context: Decodable, Equatable {
    public let uri: String
    public let href: String
    public let externalUrls: [String:String]

    enum CodingKeys: String, CodingKey {
        case uri
        case href
        case externalUrls = "external_urls"
    }
}

/// See https://developer.spotify.com/web-api/object-model/#play-history-object
public struct PlayHistory: Decodable, Equatable {
    public let track: SimplifiedTrack
    public let playedAt: Date
    public let context: Context?

    enum CodingKeys: String, CodingKey {
        case track
        case playedAt = "played_at"
        case context
    }
}

/// See https://developer.spotify.com/web-api/object-model/#cursor-based-paging-object
public struct CursorBasedPage<T:Decodable & Equatable>: Decodable, Equatable {
    public let href: String
    public let items: [T]
    public let limit: UInt
    public let next: String?
    public let cursors: Cursor
    public let total: UInt?
}

/// See https://developer.spotify.com/web-api/object-model/#cursor-object
public struct Cursor: Decodable, Equatable {
    public let before: String?
    public let after: String?
}
