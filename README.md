# Soft

A Spotify Web API library for Swift. This is to be used with Swift Package
Manager and eventually support Linux, so that it can run in desktop
applications.

This is based on [rspotify](https://github.com/samrayleung/rspotify)'s
implementation.

This is still a work in progress as it does not yet support any operations.
Any help would be appreciated.

## Linux Support
Due to `keyEncodingStrategy` and `keyDecodingStrategy` not being supported,
this will hopefully be supported in the near future as a pull request was
merged [here](https://github.com/apple/swift-corelibs-foundation/pull/1561).
See the bug report [here](https://bugs.swift.org/browse/SR-7180).

## Installation
Add this to your Package.swift:

```swift
.package(url: "https://github.com/oliveroneill/Soft.git", .upToNextMajor(from: "0.0.1")),
```

## Usage
See `SpotifyClient.swift` for methods that are currently available.
There are a number of TODOs there and I'd appreciate help in completing
the implementation.

### Authorization
All methods require user authorization which means you will need to generate
an authorization token that indicates that the user has granted permission
for your application to perform the given task.

You will need to specify a redirect URL, this URL does not need to lead
anywhere and is purely used to retrieve query parameters that Spotify
has added.

### Example
```swift
import Foundation
import Soft

do {
    let oauth = try SpotifyOAuth(clientID: "CLIENT_ID", clientSecret: "CLIENT_SECRET", redirectURI: URL(string: "http://localhost:8888/callback")!, state: "STATE", scope: "playlist-read-private")

    // Dispatch group is used so that program does not exit until the result
    // is received
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    getToken(oauth: oauth) { result in
        switch result {
        case .success(let token):
            let client = SpotifyClient(tokenInfo: token)
            client.track(trackID: "11dFghVXANMlKmJXsNCbNl") {
                print($0)
                dispatchGroup.leave()
            }
        case .failure(let error):
            print("error: \(error)")
            dispatchGroup.leave()
        }
    }
    dispatchGroup.notify(queue: DispatchQueue.main) {
        exit(EXIT_SUCCESS)
    }
    dispatchMain()
} catch {
    print(error)
}
```
