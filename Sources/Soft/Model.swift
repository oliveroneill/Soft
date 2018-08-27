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
}

/// https://developer.spotify.com/web-api/object-model/#artist-object-simplified
public struct SimplifiedArtist: Decodable, Equatable {
    let externalUrls: [String:String]
    let href: String
    let id: String
    let name: String
    let uri: String
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
