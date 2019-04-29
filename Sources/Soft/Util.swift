import Foundation

extension String {
    /// Generate a random string
    ///
    /// - Parameter count: The length of the string
    /// - Returns: A randomly generated string of the specified length
    static func random(count: Int) -> String {
        let characters = Array(
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        )
        var string = ""
        for _ in 0..<count {
            string.append(characters[randomNumber(max: characters.count)])
        }
        return string
    }
}

private func randomNumber(max: Int) -> Int {
    #if os(Linux)
    return Int(random() % max)
    #else
    return Int(arc4random_uniform(UInt32(max)))
    #endif
}
