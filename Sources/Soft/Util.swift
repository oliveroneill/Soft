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
            string.append(characters[Int(arc4random()) % characters.count])
        }
        return string
    }
}
