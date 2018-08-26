import Foundation

/// Result type used for API calls
///
/// - success: If the call succeeds this will contain the successful type
/// - failure: If the call fails this will contain an error
public enum Result<T> {
    case success(T)
    case failure(Error)
}

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
