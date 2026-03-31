import Foundation

enum DateParsingService {
    /// Parses Japanese food label date formats from OCR text.
    /// Supports: YYYY.MM.DD, YYYY/MM/DD, YYYY年MM月DD日, YY.MM.DD, YYYYMMDD, YYYY.MM
    static func parseDates(from text: String) -> [Date] {
        var results: [Date] = []
        let calendar = Calendar.current

        let patterns: [(regex: String, handler: ([String]) -> Date?)] = [
            // YYYY年MM月DD日
            (#"(20\d{2})年\s*(\d{1,2})月\s*(\d{1,2})日"#, { matches in
                dateFrom(year: matches[1], month: matches[2], day: matches[3])
            }),
            // YYYY/MM/DD or YYYY.MM.DD
            (#"(20\d{2})[./](\d{1,2})[./](\d{1,2})"#, { matches in
                dateFrom(year: matches[1], month: matches[2], day: matches[3])
            }),
            // YY.MM.DD or YY/MM/DD
            (#"(\d{2})[./](\d{1,2})[./](\d{1,2})"#, { matches in
                guard let y = Int(matches[1]), y >= 20 && y <= 40 else { return nil }
                return dateFrom(year: "20\(matches[1])", month: matches[2], day: matches[3])
            }),
            // YYYYMMDD
            (#"(20\d{2})(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])"#, { matches in
                dateFrom(year: matches[1], month: matches[2], day: matches[3])
            }),
            // YYYY.MM or YYYY/MM (month only, no day follows)
            (#"(20\d{2})[./](\d{1,2})(?![./\d])"#, { matches in
                guard let year = Int(matches[1]), let month = Int(matches[2]),
                      (1...12).contains(month) else { return nil }
                var components = DateComponents(year: year, month: month)
                guard let startOfMonth = calendar.date(from: components) else { return nil }
                guard let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return nil }
                components.day = range.count
                return calendar.date(from: components)
            }),
        ]

        for (pattern, handler) in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let nsText = text as NSString
            let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))

            for match in matches {
                var groups: [String] = []
                for i in 0..<match.numberOfRanges {
                    let range = match.range(at: i)
                    if range.location != NSNotFound {
                        groups.append(nsText.substring(with: range))
                    } else {
                        groups.append("")
                    }
                }
                if let date = handler(groups), !results.contains(date) {
                    results.append(date)
                }
            }
        }

        return results.sorted()
    }

    private static func dateFrom(year: String, month: String, day: String) -> Date? {
        guard let y = Int(year), let m = Int(month), let d = Int(day),
              (1...12).contains(m), (1...31).contains(d) else { return nil }
        return Calendar.current.date(from: DateComponents(year: y, month: m, day: d))
    }
}
