import SwiftUI
import WidgetKit

struct CalendarMonthView: View {
    let grid: CalendarGrid

    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(grid.monthTitle)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            weekdayHeader
            dateRows
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(grid.weekdays) { weekday in
                Text(weekday.shortSymbol)
                    .font(.system(size: 11, weight: .semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel(weekday.fullName)
            }
        }
    }

    private var dateRows: some View {
        VStack(spacing: 0) {
            ForEach(Array(grid.rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, day in
                        cell(for: day)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func cell(for day: CalendarGrid.Day?) -> some View {
        if let day {
            ZStack {
                if day.isToday {
                    Circle()
                        .fill(todayFill)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(2)
                        .widgetAccentable()
                }
                Text(day.number, format: .number)
                    .font(.system(size: 17, weight: day.isToday ? .semibold : .regular, design: .rounded))
                    .foregroundStyle(numberStyle(isToday: day.isToday))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(day.isToday ? "\(String(localized: "Today")), \(day.accessibilityLabel)" : day.accessibilityLabel)
            .accessibilityAddTraits(day.isToday ? .isSelected : [])
        } else {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)
        }
    }

    private var todayFill: AnyShapeStyle {
        renderingMode == .fullColor ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.primary.opacity(0.3))
    }

    private func numberStyle(isToday: Bool) -> AnyShapeStyle {
        isToday && renderingMode == .fullColor ? AnyShapeStyle(Color.white) : AnyShapeStyle(.primary)
    }
}
