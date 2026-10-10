import Foundation
import Testing

struct CalendarGridTests {
    private func makeCalendar(
        identifier: Calendar.Identifier = .gregorian,
        timeZone: String = "UTC",
        locale: String = "en_US",
        firstWeekday: Int = 1
    ) -> Calendar {
        var calendar = Calendar(identifier: identifier)
        calendar.timeZone = TimeZone(identifier: timeZone)!
        calendar.locale = Locale(identifier: locale)
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12, calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    private func grid(_ year: Int, _ month: Int, today: Date? = nil, calendar: Calendar) -> CalendarGrid {
        CalendarGrid(displaying: date(year, month, 15, calendar: calendar), today: today, calendar: calendar)
    }

    @Test(arguments: Array(zip(1...12, [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31])))
    func dayCountsForNonLeapYear(month: Int, expectedDays: Int) {
        let calendar = makeCalendar()
        #expect(grid(2027, month, calendar: calendar).days.count == expectedDays)
    }

    @Test func leapYearFebruaryHas29Days() {
        #expect(grid(2028, 2, calendar: makeCalendar()).days.count == 29)
    }

    @Test func nonLeapYearFebruaryHas28Days() {
        #expect(grid(2027, 2, calendar: makeCalendar()).days.count == 28)
    }

    @Test func monthStartingOnSundayHasNoLeadingBlanks() {
        #expect(grid(2026, 2, calendar: makeCalendar()).leadingBlankCount == 0)
    }

    @Test func monthStartingOnMondayHasOneLeadingBlankWithSundayStart() {
        #expect(grid(2026, 6, calendar: makeCalendar()).leadingBlankCount == 1)
    }

    @Test func monthStartingOnMondayHasNoLeadingBlanksWithMondayStart() {
        #expect(grid(2026, 6, calendar: makeCalendar(firstWeekday: 2)).leadingBlankCount == 0)
    }

    @Test func saturdayStartWeekShiftsOffset() {
        #expect(grid(2026, 8, calendar: makeCalendar(firstWeekday: 7)).leadingBlankCount == 0)
    }

    @Test func fourRowMonth() {
        #expect(grid(2026, 2, calendar: makeCalendar()).rowCount == 4)
    }

    @Test func fiveRowMonth() {
        #expect(grid(2026, 10, calendar: makeCalendar()).rowCount == 5)
    }

    @Test func sixRowMonth() {
        let sixRowGrid = grid(2026, 8, calendar: makeCalendar())
        #expect(sixRowGrid.rowCount == 6)
        #expect(sixRowGrid.rows.count == 6)
    }

    @Test(arguments: 1...12)
    func everyRowHasSevenCellsAndAllDaysPresent(month: Int) {
        let monthGrid = grid(2026, month, calendar: makeCalendar())
        #expect(monthGrid.rows.allSatisfy { $0.count == 7 })
        #expect(monthGrid.rows.flatMap { $0 }.compactMap { $0?.number } == Array(1...monthGrid.days.count))
    }

    @Test func firstDayLandsUnderCorrectWeekday() {
        let calendar = makeCalendar()
        let octoberGrid = grid(2026, 10, calendar: calendar)
        let firstRow = octoberGrid.rows[0]
        #expect(firstRow.firstIndex { $0?.number == 1 } == 4)
        #expect(octoberGrid.weekdays[4].fullName == "Thursday")
    }

    @Test func weekdayHeadersFollowFirstWeekday() {
        let mondayFirst = grid(2026, 10, calendar: makeCalendar(firstWeekday: 2))
        #expect(mondayFirst.weekdays.map(\.fullName).first == "Monday")
        #expect(mondayFirst.weekdays.map(\.fullName).last == "Sunday")
    }

    @Test func decemberToJanuaryYearTransition() {
        let calendar = makeCalendar()
        let december = grid(2026, 12, calendar: calendar)
        let january = CalendarGrid(
            displaying: calendar.date(byAdding: .month, value: 1, to: december.monthStart)!,
            calendar: calendar
        )
        #expect(calendar.component(.year, from: january.monthStart) == 2027)
        #expect(calendar.component(.month, from: january.monthStart) == 1)
        #expect(january.days.count == 31)
    }

    @Test func todayIsHighlightedOnlyInItsOwnMonth() {
        let calendar = makeCalendar()
        let today = date(2026, 10, 11, calendar: calendar)
        let october = CalendarGrid(displaying: today, today: today, calendar: calendar)
        let november = grid(2026, 11, today: today, calendar: calendar)
        #expect(october.days.filter(\.isToday).map(\.number) == [11])
        #expect(november.days.contains(where: \.isToday) == false)
    }

    @Test func todayHighlightRespectsTimeZone() {
        let instant = Date(timeIntervalSince1970: 1_791_763_200 + 3 * 3600)
        let tokyo = makeCalendar(timeZone: "Asia/Tokyo")
        let losAngeles = makeCalendar(timeZone: "America/Los_Angeles")
        let tokyoDay = CalendarGrid(displaying: instant, today: instant, calendar: tokyo).days.first(where: \.isToday)
        let losAngelesDay = CalendarGrid(displaying: instant, today: instant, calendar: losAngeles).days.first(where: \.isToday)
        #expect(tokyoDay?.number != losAngelesDay?.number)
    }

    @Test(arguments: [
        ("en_US", "October 2026"),
        ("fr_FR", "octobre 2026"),
        ("de_DE", "Oktober 2026"),
        ("ja_JP", "2026年10月"),
    ])
    func monthTitleIsLocalized(localeIdentifier: String, expected: String) {
        let calendar = makeCalendar(locale: localeIdentifier)
        #expect(grid(2026, 10, calendar: calendar).monthTitle == expected)
    }

    @Test func islamicCalendarMonthsHave29Or30Days() {
        let calendar = makeCalendar(identifier: .islamicUmmAlQura)
        let monthGrid = CalendarGrid(displaying: date(2026, 10, 11, calendar: calendar), calendar: calendar)
        #expect([29, 30].contains(monthGrid.days.count))
        #expect(monthGrid.days.first?.number == 1)
    }

    @Test func accessibilityLabelIsFullDate() {
        let label = grid(2026, 10, calendar: makeCalendar()).days[10].accessibilityLabel
        #expect(label == "Sunday, October 11, 2026")
    }
}

struct CalendarTimelineTests {
    private func makeCalendar(timeZone: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timeZone)!
        return calendar
    }

    @Test func firstEntryIsNowAndRestAreMidnights() {
        let calendar = makeCalendar(timeZone: "UTC")
        let now = calendar.date(from: DateComponents(year: 2026, month: 10, day: 11, hour: 15, minute: 30))!
        let dates = CalendarTimeline.entryDates(startingAt: now, count: 3, calendar: calendar)
        #expect(dates.count == 3)
        #expect(dates[0] == now)
        #expect(dates[1] == calendar.date(from: DateComponents(year: 2026, month: 10, day: 12))!)
        #expect(dates[2] == calendar.date(from: DateComponents(year: 2026, month: 10, day: 13))!)
    }

    @Test func monthBoundaryEntryFallsOnFirstOfNextMonth() {
        let calendar = makeCalendar(timeZone: "UTC")
        let now = calendar.date(from: DateComponents(year: 2026, month: 10, day: 31, hour: 20))!
        let dates = CalendarTimeline.entryDates(startingAt: now, count: 2, calendar: calendar)
        #expect(calendar.component(.month, from: dates[1]) == 11)
        #expect(calendar.component(.day, from: dates[1]) == 1)
    }

    @Test(arguments: [
        (2026, 3, 8, "America/New_York"),
        (2026, 11, 1, "America/New_York"),
        (2026, 3, 29, "Europe/Berlin"),
    ])
    func daylightSavingDaysStillProduceDistinctMidnights(year: Int, month: Int, day: Int, zone: String) {
        let calendar = makeCalendar(timeZone: zone)
        let now = calendar.date(from: DateComponents(year: year, month: month, day: day - 1, hour: 12))!
        let dates = CalendarTimeline.entryDates(startingAt: now, count: 4, calendar: calendar)
        let dayStarts = dates.dropFirst()
        #expect(dayStarts.allSatisfy { calendar.startOfDay(for: $0) == $0 })
        #expect(Set(dayStarts).count == 3)
        #expect(zip(dates, dates.dropFirst()).allSatisfy { $0 < $1 })
        let days = dayStarts.map { calendar.component(.day, from: $0) }
        #expect(days == [day, day + 1, day + 2])
    }
}

struct WeekendTests {
    @Test func saturdayAndSundayAreWeekendsInUS() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let weekendNames = CalendarGrid(displaying: .now, calendar: calendar).weekdays.filter(\.isWeekend).map(\.fullName)
        #expect(weekendNames == ["Sunday", "Saturday"])
    }

    @Test func weekendFlagFollowsReorderedWeekdays() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.firstWeekday = 2
        let grid = CalendarGrid(displaying: .now, calendar: calendar)
        #expect(grid.weekdays.map(\.isWeekend) == [false, false, false, false, false, true, true])
        #expect(grid.days.filter(\.isWeekend).allSatisfy { [1, 7].contains(calendar.component(.weekday, from: $0.date)) })
    }
}
