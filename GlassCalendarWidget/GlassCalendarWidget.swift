import SwiftUI
import WidgetKit

@main
struct GlassCalendarWidgetBundle: WidgetBundle {
    var body: some Widget {
        GlassCalendarWidget()
    }
}

struct GlassCalendarWidget: Widget {
    let kind = "GlassCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarProvider()) { entry in
            CalendarWidgetView(entry: entry)
        }
        .configurationDisplayName("Glass Calendar")
        .description("A minimal, beautiful monthly calendar for your desktop.")
        .supportedFamilies([.systemLarge])
    }
}
