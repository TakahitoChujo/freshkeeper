import Testing
import Foundation
@testable import FreshKeeper

@Suite("DateParsingService Tests")
struct DateParsingServiceTests {

    private func date(year: Int, month: Int, day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test("Parses YYYY.MM.DD format")
    func dotFormat() {
        let results = DateParsingService.parseDates(from: "賞味期限 2026.04.15")
        #expect(results.count == 1)
        #expect(results.first == date(year: 2026, month: 4, day: 15))
    }

    @Test("Parses YYYY/MM/DD format")
    func slashFormat() {
        let results = DateParsingService.parseDates(from: "2026/04/15")
        #expect(results.count == 1)
        #expect(results.first == date(year: 2026, month: 4, day: 15))
    }

    @Test("Parses YYYY年MM月DD日 format")
    func japaneseFormat() {
        let results = DateParsingService.parseDates(from: "2026年4月15日")
        #expect(results.count == 1)
        #expect(results.first == date(year: 2026, month: 4, day: 15))
    }

    @Test("Parses YY.MM.DD format")
    func shortYearFormat() {
        let results = DateParsingService.parseDates(from: "26.04.15")
        #expect(results.count == 1)
        #expect(results.first == date(year: 2026, month: 4, day: 15))
    }

    @Test("Parses YYYYMMDD format")
    func compactFormat() {
        let results = DateParsingService.parseDates(from: "20260415")
        #expect(results.count == 1)
        #expect(results.first == date(year: 2026, month: 4, day: 15))
    }

    @Test("Parses year-month only format (uses last day of month)")
    func yearMonthOnly() {
        let results = DateParsingService.parseDates(from: "2026.04")
        #expect(!results.isEmpty)
        let result = results.first!
        let components = Calendar.current.dateComponents([.year, .month, .day], from: result)
        #expect(components.year == 2026)
        #expect(components.month == 4)
        #expect(components.day == 30) // April has 30 days
    }

    @Test("Handles multiple dates in text")
    func multipleDates() {
        let results = DateParsingService.parseDates(from: "製造日 2026.03.01 賞味期限 2026.04.15")
        #expect(results.count == 2)
        #expect(results[0] == date(year: 2026, month: 3, day: 1))
        #expect(results[1] == date(year: 2026, month: 4, day: 15))
    }

    @Test("Returns empty for no dates")
    func noDates() {
        let results = DateParsingService.parseDates(from: "これは日付ではないテキスト")
        #expect(results.isEmpty)
    }

    @Test("Ignores invalid short year formats")
    func invalidShortYear() {
        let results = DateParsingService.parseDates(from: "19.04.15") // year 19 < 20
        #expect(results.isEmpty)
    }
}
