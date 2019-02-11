import Foundation

/// Apparently Spotify Web API does not always return dates with fractional
/// seconds included. This date formatter will handle the missing decimal if
/// needed
class SpotifyDateFormatter: DateFormatter {
    /// Formatter without the decimal
    let withoutDecimal: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    func setup() {
        // By default we include the decimal
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
    }

    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func date(from string: String) -> Date? {
        return super.date(from: string) ?? withoutDecimal.date(from: string)
    }
}
