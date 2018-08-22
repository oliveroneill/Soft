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
            string.append(characters[Int(arc4random()) % characters.count])
        }
        return string
    }
}
