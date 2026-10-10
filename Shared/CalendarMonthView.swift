import AppKit
import SwiftUI
import WidgetKit

struct CalendarMonthView: View {
    let grid: CalendarGrid

    fileprivate static let titleFontSize: CGFloat = 17
    fileprivate static let dayFontSize: CGFloat = 17
    private let columnWidth: CGFloat = 34
    private let weekdayFont = Font.system(size: 11, weight: .semibold)

    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        MonthLayout(rowCount: grid.rowCount, spacing: 10) {
            Text(grid.monthTitle)
                .font(.system(size: Self.titleFontSize, weight: .semibold))
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.leading, titleInset)
                .frame(maxWidth: .infinity, alignment: .leading)
            weekdayHeader
            dateRows
        }
    }

    private var titleInset: CGFloat {
        guard let firstSymbol = grid.weekdays.first?.shortSymbol else { return 0 }
        let font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        let labelWidth = firstSymbol.localizedUppercase.size(withAttributes: [.font: font]).width
        return max((columnWidth - labelWidth) / 2, 0)
    }

    private var weekdayHeader: some View {
        spreadColumns {
            ForEach(grid.weekdays) { weekday in
                Text(weekday.shortSymbol)
                    .font(weekdayFont)
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
                    .font(.system(size: Self.dayFontSize, weight: day.isToday ? .semibold : .regular))
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

private struct MonthLayout: Layout {
    let rowCount: Int
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == 3 else { return }
        let proposedWidth = ProposedViewSize(width: bounds.width, height: nil)
        let titleHeight = subviews[0].sizeThatFits(proposedWidth).height
        let headerHeight = subviews[1].sizeThatFits(proposedWidth).height
        let rowsTop = bounds.minY + titleHeight + headerHeight + 2 * spacing
        let availableHeight = bounds.maxY - rowsTop
        let rowsHeight = availableHeight + bottomOverhang(availableHeight: availableHeight)

        subviews[0].place(at: CGPoint(x: bounds.minX, y: bounds.minY), proposal: proposedWidth)
        subviews[1].place(
            at: CGPoint(x: bounds.minX, y: bounds.minY + titleHeight + spacing),
            proposal: proposedWidth
        )
        subviews[2].place(
            at: CGPoint(x: bounds.minX, y: rowsTop),
            proposal: ProposedViewSize(width: bounds.width, height: rowsHeight)
        )
    }

    private func bottomOverhang(availableHeight: CGFloat) -> CGFloat {
        let titleFont = NSFont.systemFont(ofSize: CalendarMonthView.titleFontSize, weight: .semibold)
        let dayFont = NSFont.systemFont(ofSize: CalendarMonthView.dayFontSize)
        let titleTopGap = titleFont.ascender - titleFont.capHeight
        let dayLineHeight = dayFont.ascender - dayFont.descender
        let dayBelowBaseline = -dayFont.descender
        let rows = CGFloat(max(rowCount, 1))
        let overhang = (availableHeight / rows - dayLineHeight + 2 * (dayBelowBaseline - titleTopGap)) / (2 - 1 / rows)
        return max(overhang, 0)
    }
}
