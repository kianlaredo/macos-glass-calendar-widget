import SwiftUI
import WidgetKit

struct CalendarWidgetView: View {
    let entry: CalendarEntry

    var body: some View {
        CalendarMonthView(grid: CalendarGrid(displaying: entry.date, today: entry.date, calendar: .current))
            .containerBackground(.fill.tertiary, for: .widget)
    }
}
