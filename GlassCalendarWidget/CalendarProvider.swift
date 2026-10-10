import WidgetKit

struct CalendarProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        completion(CalendarEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let entryDates = CalendarTimeline.entryDates(startingAt: .now, calendar: .current)
        completion(Timeline(entries: entryDates.map(CalendarEntry.init), policy: .atEnd))
    }
}
