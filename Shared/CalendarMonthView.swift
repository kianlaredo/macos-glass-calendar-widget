import SwiftUI
import WidgetKit

struct CalendarMonthView: View {
    let grid: CalendarGrid

    private let columnWidth: CGFloat = 34

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
        spreadColumns {
            ForEach(grid.weekdays) { weekday in
                Text(weekday.shortSymbol)
                    .font(.system(size: 11, weight: .semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(weekday.isWeekend ? AnyShapeStyle(.tertiary) : AnyShapeStyle(.secondary))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(width: columnWidth)
                    .accessibilityLabel(weekday.fullName)
            }
        }
    }

    private var dateRows: some View {
        VStack(spacing: 0) {
            ForEach(Array(grid.rows.enumerated()), id: \.offset) { _, row in
                spreadColumns(fillsHeight: true) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, day in
                        cell(for: day)
                    }
                }
            }
        }
    }

    private func spreadColumns<Content: View>(
        fillsHeight: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        SpreadLayout(fillsHeight: fillsHeight) { content() }
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
                    .foregroundStyle(numberStyle(for: day))
            }
            .frame(width: columnWidth)
            .frame(maxHeight: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(day.isToday ? "\(String(localized: "Today")), \(day.accessibilityLabel)" : day.accessibilityLabel)
            .accessibilityAddTraits(day.isToday ? .isSelected : [])
        } else {
            Color.clear
                .frame(width: columnWidth)
                .frame(maxHeight: .infinity)
                .accessibilityHidden(true)
        }
    }

    private var todayFill: AnyShapeStyle {
        renderingMode == .fullColor ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.primary.opacity(0.3))
    }

    private func numberStyle(for day: CalendarGrid.Day) -> AnyShapeStyle {
        if day.isToday && renderingMode == .fullColor { return AnyShapeStyle(Color.white) }
        return day.isWeekend && !day.isToday ? AnyShapeStyle(.secondary) : AnyShapeStyle(.primary)
    }
}

private struct SpreadLayout: Layout {
    let fillsHeight: Bool

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let intrinsicHeight = subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
        return CGSize(
            width: proposal.width ?? subviews.map { $0.sizeThatFits(.unspecified).width }.reduce(0, +),
            height: fillsHeight ? (proposal.height ?? intrinsicHeight) : intrinsicHeight
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let columnWidths = subviews.map { $0.sizeThatFits(.unspecified).width }
        let gapCount = max(subviews.count - 1, 1)
        let gap = (bounds.width - columnWidths.reduce(0, +)) / CGFloat(gapCount)
        var originX = bounds.minX
        for (subview, width) in zip(subviews, columnWidths) {
            subview.place(
                at: CGPoint(x: originX, y: bounds.midY),
                anchor: .leading,
                proposal: ProposedViewSize(width: width, height: bounds.height)
            )
            originX += width + gap
        }
    }
}
