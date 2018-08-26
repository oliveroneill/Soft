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
    let albumType: String
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
