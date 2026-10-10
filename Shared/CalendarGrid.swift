import Foundation

struct CalendarGrid: Equatable {
    static let daysPerWeek = 7

    struct Day: Equatable, Identifiable {
        let date: Date
        let number: Int
        let isToday: Bool
        let isWeekend: Bool
        let accessibilityLabel: String

        var id: Date { date }
    }

    struct Weekday: Equatable, Identifiable {
        let id: Int
        let shortSymbol: String
        let fullName: String
        let isWeekend: Bool
    }

    let calendar: Calendar
    let monthStart: Date
    let leadingBlankCount: Int
    let days: [Day]
    let monthTitle: String
    let weekdays: [Weekday]

    var rowCount: Int {
        (leadingBlankCount + days.count + Self.daysPerWeek - 1) / Self.daysPerWeek
    }

    var rows: [[Day?]] {
        let leading = [Day?](repeating: nil, count: leadingBlankCount)
        let filled = leading + days.map { Optional($0) }
        let trailing = [Day?](repeating: nil, count: rowCount * Self.daysPerWeek - filled.count)
        let cells = filled + trailing
        return stride(from: 0, to: cells.count, by: Self.daysPerWeek).map {
            Array(cells[$0..<$0 + Self.daysPerWeek])
        }
    }

    init(displaying date: Date, today: Date? = nil, calendar: Calendar) {
        let monthStart = calendar.dateInterval(of: .month, for: date)?.start ?? calendar.startOfDay(for: date)
        let dayCount = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 0
        let firstWeekdayOfMonth = calendar.component(.weekday, from: monthStart)
        let weekdayCount = Self.daysPerWeek

        let dayFormatter = Self.makeFormatter(calendar: calendar)
        dayFormatter.dateStyle = .full
        dayFormatter.timeStyle = .none

        let titleFormatter = Self.makeFormatter(calendar: calendar)
        titleFormatter.setLocalizedDateFormatFromTemplate("MMMMy")

        self.calendar = calendar
        self.monthStart = monthStart
        self.leadingBlankCount = (firstWeekdayOfMonth - calendar.firstWeekday + weekdayCount) % weekdayCount
        self.monthTitle = titleFormatter.string(from: monthStart)
        self.weekdays = Self.makeWeekdays(calendar: calendar)
        self.days = (0..<dayCount).compactMap { offset in
            guard let dayDate = calendar.date(byAdding: .day, value: offset, to: monthStart) else { return nil }
            return Day(
                date: dayDate,
                number: calendar.component(.day, from: dayDate),
                isToday: today.map { calendar.isDate(dayDate, inSameDayAs: $0) } ?? false,
                isWeekend: calendar.isDateInWeekend(dayDate),
                accessibilityLabel: dayFormatter.string(from: dayDate)
            )
        }
    }

    private static func makeFormatter(calendar: Calendar) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = calendar.locale ?? .current
        return formatter
    }

    private static func makeWeekdays(calendar: Calendar) -> [Weekday] {
        let shortSymbols = calendar.shortStandaloneWeekdaySymbols
        let fullNames = calendar.standaloneWeekdaySymbols
        return (0..<daysPerWeek).map { position in
            let symbolIndex = (calendar.firstWeekday - 1 + position) % daysPerWeek
            return Weekday(
                id: position,
                shortSymbol: shortSymbols[symbolIndex],
                fullName: fullNames[symbolIndex],
                isWeekend: isWeekend(weekday: symbolIndex + 1, calendar: calendar)
            )
        }
    }

    private static func isWeekend(weekday: Int, calendar: Calendar) -> Bool {
        let sampleDate = calendar.nextDate(
            after: Date(timeIntervalSinceReferenceDate: 0),
            matching: DateComponents(weekday: weekday),
            matchingPolicy: .nextTime
        )
        return sampleDate.map(calendar.isDateInWeekend) ?? false
    }
}
