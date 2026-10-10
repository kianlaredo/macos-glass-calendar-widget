import SwiftUI

struct ContentView: View {
    private let installSteps = [
        "Right-click your desktop.",
        "Select Edit Widgets.",
        "Search for Glass Calendar.",
        "Add the large widget.",
    ]

    var body: some View {
        HStack(alignment: .top, spacing: 36) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Glass Calendar")
                        .font(.largeTitle.weight(.semibold))
                    Text("Your minimal monthly calendar for macOS.")
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(installSteps.enumerated()), id: \.offset) { index, step in
                        Label(step, systemImage: "\(index + 1).circle.fill")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
            .frame(width: 260, alignment: .leading)

            preview
        }
        .padding(32)
    }

    private var preview: some View {
        CalendarMonthView(grid: CalendarGrid(displaying: .now, today: .now, calendar: .current))
            .padding(20)
            .frame(width: 364, height: 382)
            .glassEffect(.regular, in: .rect(cornerRadius: 28))
            .accessibilityHidden(true)
    }
}
