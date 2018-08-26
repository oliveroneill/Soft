import Foundation

/// See https://developer.spotify.com/documentation/web-api/reference/ for
/// documentation on these structs

public struct Image: Decodable, Equatable {
    let url: String
    let width: UInt?
    let height: UInt?
}

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

public struct SimplifiedArtist: Decodable, Equatable {
    let externalUrls: [String:String]
    let href: String
    let id: String
    let name: String
    let uri: String
}

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
