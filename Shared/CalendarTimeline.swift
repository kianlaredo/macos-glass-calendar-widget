import Foundation

enum CalendarTimeline {
    static let defaultEntryCount = 7

    static func entryDates(startingAt now: Date, count: Int = defaultEntryCount, calendar: Calendar) -> [Date] {
        var dates = [now]
        var dayStart = calendar.startOfDay(for: now)
        while dates.count < count {
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: dayStart) else { break }
            dayStart = calendar.startOfDay(for: nextDay)
            dates.append(dayStart)
        }
        return dates
    }
}
