import SwiftUI
import WidgetKit

struct CalendarWidgetView: View {
    private static let calendarAppURL = URL(string: "glasscalendar://open-calendar")

    let entry: CalendarEntry

    var body: some View {
        CalendarMonthView(grid: CalendarGrid(displaying: entry.date, today: entry.date, calendar: .current))
            .widgetURL(Self.calendarAppURL)
            .containerBackground(.fill.tertiary, for: .widget)
    }
}
