# Soft

[![Build Status](https://travis-ci.org/oliveroneill/Soft.svg?branch=master)](https://travis-ci.org/oliveroneill/Soft)
[![Platform](https://img.shields.io/badge/Swift-4.2-orange.svg)](https://img.shields.io/badge/Swift-4.2-orange.svg)
[![Swift Package Manager](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)

A Spotify Web API library for Swift. This is to be used with Swift Package
Manager and supports Linux, so that it can run in desktop and server-side
applications.

This is based on [rspotify](https://github.com/samrayleung/rspotify)'s
implementation.

This is still a work in progress and supports a limited number of calls.
See [SpotifyClient.swift](https://github.com/oliveroneill/Soft/blob/master/Sources/Soft/SpotifyClient.swift)
for the supported calls and some TODOs on what to implement next.
Any help is much appreciated.

## Linux Support
Linux is now supported in Soft! In future we will remove all the unnecessary
`CodingKey` declarations, once `keyEncodingStrategy` and `keyDecodingStrategy`
are supported. See the bug report
[here](https://bugs.swift.org/browse/SR-7180).

## Installation
Add this to your Package.swift:

```swift
.package(url: "https://github.com/oliveroneill/Soft.git", .upToNextMajor(from: "0.0.5")),
```

## Usage
See [SpotifyClient.swift](https://github.com/oliveroneill/Soft/blob/master/Sources/Soft/SpotifyClient.swift)
for the calls are currently available. There are a number of TODOs in that
class for calls that need implementing and I'd appreciate help in
completing the implementation.

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

### Running tests on Linux
Use this command to run tests on Linux while on macOS, using Docker:
```bash
docker run --rm -v "$(pwd):/pkg" -w "/pkg" swift:latest /bin/bash -c "swift test --build-path ./.build/linux"
```