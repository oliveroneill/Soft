import Foundation

/// A protocol for dealing with file handling
protocol FileHandler {
    /// Read data from file at URL
    ///
    /// - Parameter from: File location
    /// - Returns: The data stored in the file
    /// - Throws: If the operation fails
    func read(from: URL) throws -> Data

    /// Write data to file at URL
    ///
    /// - Parameters:
    ///   - data: Data to write
    ///   - to: Where to write the data
    /// - Throws: If the operation fails
    func write(data: Data, to: URL) throws
}

/// A file handler using Data function
class DataFileHandler: FileHandler {
    func read(from: URL) throws -> Data {
        return try Data(contentsOf: from)
    }

    func write(data: Data, to: URL) throws {
        try data.write(to: to)
    }
}
