GlassCalendar

Native macOS Liquid Glass Calendar Widget

1. Project Overview

Build a lightweight, completely free, native macOS calendar widget called GlassCalendar.

The widget must display exactly one full calendar month inside a large, square macOS desktop widget (systemLarge).

It should integrate seamlessly with macOS Tahoe’s native Liquid Glass appearance, including system-managed transparency.

The project must use Apple’s native frameworks, require no subscriptions or third-party widget engines, and operate without a continuously running companion application.

Primary goal: Create a beautiful, minimal, native macOS calendar widget that feels like something Apple would have shipped with macOS Tahoe.

⸻

2. Non-Negotiable Requirements

2.1 Functional Requirements

Requirement	Specification
Platform	macOS 26 Tahoe or newer
Application type	Native macOS application
Widget framework	WidgetKit
UI framework	SwiftUI
Programming language	Swift
Widget size	Large (systemLarge)
Calendar layout	Exactly ONE full month
Calendar updates	Automatically
Current date	Highlighted
Week start	Follow macOS locale/calendar settings
Calendar system	Respect the user’s system calendar
Placement	macOS Desktop and Notification Center
Internet connection	Not required
Calendar permissions	Not required
Account creation	Not required
Payment	Completely free
Subscriptions	None
Third-party dependencies	None

2.2 Background Execution Requirements

The application must not use:

* A persistent background application.
* A menu bar application.
* A custom desktop overlay.
* Login items.
* Launch agents or daemons.
* Background polling loops.
* Continuously running timers.
* Third-party widget engines.

Instead, implement the widget using a standard WidgetKit extension.

macOS should handle widget rendering, scheduling, and lifecycle management.

The containing application may be opened for installation, information, or optional configuration, but it must not need to remain running for the widget to work.

Normal system-managed widget extension processes are acceptable.

2.3 Pricing and Privacy

The application must be:

* Completely free.
* Fully functional without purchases.
* Free of advertisements.
* Free of analytics.
* Free of telemetry.
* Free of tracking.
* Free of unnecessary permissions.
* Functional entirely offline.

Do not integrate advertising, subscription, analytics, or account-management SDKs.

⸻

3. Visual Design

3.1 Overall Appearance

Design the widget to resemble a native Apple widget.

Visual direction:

Minimalist, elegant, translucent, modern, and consistent with macOS Tahoe.

Use:

* Native SwiftUI typography.
* SF Pro system fonts.
* Subtle rounded typography where appropriate.
* Native foreground styles.
* System-managed widget backgrounds.
* Comfortable spacing.
* Clean alignment.
* Automatic light/dark appearance.
* Native Liquid Glass-compatible styling.

Avoid:

* Custom fake glass effects.
* Excessive gradients.
* Bright decorative colors.
* Heavy shadows.
* Unnecessary borders.
* Custom floating windows.
* Web-based interfaces.
* Electron.
* Third-party rendering frameworks.

The widget should feel like a natural part of macOS.

⸻

4. Calendar Layout

4.1 Widget Size

Support the following widget family:

.systemLarge

The primary design must use the entire available large widget area.

Do not display multiple months.

Do not automatically switch to a four-month layout.

Do not use a small calendar surrounded by excessive empty space.

The calendar must remain readable at the standard large widget size.

4.2 Calendar Structure

The widget must display:

1. Current month and year.
2. Seven weekday headings.
3. All dates belonging to the current month.
4. Correct weekday alignment.
5. A distinct highlight for today’s date.

Example layout:

╭───────────────────────────────────╮
│                                   │
│  October 2026                     │
│                                   │
│  SUN  MON  TUE  WED  THU  FRI  SAT │
│                                   │
│                  1    2    3     │
│                                   │
│   4    5    6    7    8    9   10 │
│                                   │
│  11   12   13   14   15   16   17 │
│                                   │
│  18   19   20   21   22   23   24 │
│                                   │
│  25   26   27   28   29   30   31 │
│                                   │
╰───────────────────────────────────╯

The example is illustrative. Actual dates must be aligned according to the user’s calendar settings.

4.3 Month Heading

Display the current month and year.

Examples:

* October 2026
* November 2026
* December 2026

Use locale-aware date formatting.

Recommended typography:

* System font.
* Semibold weight.
* Approximately 24–28 points, adjusted to fit.
* Left aligned.
* Clear hierarchy.

Do not hardcode English month names.

4.4 Weekday Headers

Display seven weekday headings.

Examples:

S M T W T F S

or

Sun Mon Tue Wed Thu Fri Sat

Choose whichever format offers better readability at the available size.

Requirements:

* Respect the user’s configured first weekday.
* Use locale-aware weekday symbols.
* Keep columns evenly spaced.
* Use a visually secondary text style.
* Avoid clipping or truncation.

4.5 Date Grid

Use seven equally spaced columns.

The calendar must correctly handle months requiring four, five, or six calendar rows.

Requirements:

* Dates must align under the correct weekdays.
* Dates must not overlap.
* Empty cells before or after the month should remain visually empty.
* Dates should use readable typography.
* Dates should be horizontally centered within their cells.
* The calendar should adapt to the available widget height.

Use Calendar.current and Foundation date calculations.

Do not hardcode month lengths, leap years, or weekday offsets.

Support leap years and locale-dependent calendar configurations.

4.6 Today’s Date Highlight

Highlight the current date using a simple, elegant circular background.

Preferred design:

* Circular shape.
* Native accent or adaptive system color.
* High-contrast text.
* No glow.
* No animation.
* No distracting decorations.

Only highlight today when the displayed month contains the current date.

Use complete calendar date comparisons, not just the day number.

For example, do not highlight the 11th of an unrelated month merely because today is the 11th.

⸻

5. Liquid Glass and Transparency

This is one of the project’s highest-priority requirements.

5.1 Native macOS Tahoe Integration

The widget must use Apple’s native widget background APIs.

Investigate and implement the appropriate WidgetKit and SwiftUI APIs available in the macOS 26 SDK.

Prefer:

.containerBackground(for: .widget) {
    // Native system-compatible background
}

Use an appropriate system background fill or material supported by WidgetKit.

Do not assume an arbitrary SwiftUI material automatically produces native Liquid Glass.

The implementation must follow Apple’s current WidgetKit guidance for macOS Tahoe.

5.2 System Appearance

The widget should support the macOS system’s widget appearance settings wherever supported.

Expected behavior:

Default appearance

* Native macOS widget background.
* Readable text.
* Appropriate contrast.

Light appearance

* Automatic light-mode styling.
* Correct foreground colors.

Dark appearance

* Automatic dark-mode styling.
* Correct foreground colors.

Clear / translucent appearance

* Participate in macOS Tahoe’s native clear widget styling where supported.
* Allow the system to manage transparency.
* Preserve text readability over different wallpapers.

Tinted appearance

* Respect supported system widget tinting and rendering behavior.

Use relevant widget rendering environment values and supported APIs where necessary.

Do not simulate system transparency by sampling the desktop wallpaper.

5.3 Transparency Limitations

The widget should follow the transparency behavior actually provided by macOS.

Do not create a fake acrylic or frosted-glass layer that conflicts with native widget rendering.

Do not claim support for adjustable blur intensity unless an actual supported implementation exists.

If macOS controls transparency globally, allow the system to control it.

If a particular appearance mode cannot be implemented through public WidgetKit APIs, document that limitation instead of inventing a workaround.

⸻

6. Architecture

Use a simple native Xcode project.

Suggested structure:

GlassCalendar/
│
├── GlassCalendar.xcodeproj
│
├── GlassCalendar/
│   ├── GlassCalendarApp.swift
│   ├── ContentView.swift
│   └── Assets.xcassets
│
├── GlassCalendarWidget/
│   ├── GlassCalendarWidget.swift
│   ├── CalendarProvider.swift
│   ├── CalendarEntry.swift
│   ├── CalendarWidgetView.swift
│   ├── CalendarMonthView.swift
│   ├── CalendarGrid.swift
│   └── Assets.xcassets
│
├── GlassCalendarTests/
│   └── CalendarGridTests.swift
│
└── README.md

The exact file organization can be adjusted if a simpler structure is preferable.

Maintain clear separation between:

* Timeline generation.
* Calendar date calculations.
* Calendar presentation.
* Widget configuration.
* Containing application.

Do not introduce unnecessary architectural complexity.

⸻

7. WidgetKit Implementation

7.1 Widget Configuration

Use a standard WidgetKit configuration appropriate for a static calendar widget.

A StaticConfiguration is sufficient unless a compelling technical reason requires something else.

The widget must advertise only the supported large family.

Example:

.supportedFamilies([
    .systemLarge
])

Widget display name:

Glass Calendar

Widget description:

A minimal, beautiful monthly calendar for your desktop.

The widget must be discoverable in the native macOS widget gallery.

7.2 Timeline Provider

Implement a lightweight timeline provider.

Requirements:

* Display the correct current month.
* Update the highlighted date after midnight.
* Update the month when the month changes.
* Respect the user’s current calendar and time zone.
* Avoid unnecessary refreshes.
* Avoid background polling.

Use Calendar-based date calculations to determine the next day boundary.

Do not assume that every local calendar day lasts exactly 86,400 seconds.

Daylight saving transitions must not break the calendar.

WidgetKit controls the actual refresh schedule, so do not promise an exact midnight update if the system delays refreshing.

A timeline containing multiple upcoming daily entries is acceptable and may improve reliability.

Keep the timeline bounded and efficient.

7.3 Widget Entry

A timeline entry should contain the information required to render the calendar for a particular date.

A simple date-based entry is sufficient.

Avoid storing redundant calendar information unless it improves correctness or performance.

7.4 Calendar Calculations

Create reusable functions for:

* Determining the current month.
* Finding the first day of the month.
* Finding the number of days in the month.
* Determining the weekday offset.
* Generating calendar grid cells.
* Identifying today’s date.
* Formatting the month heading.
* Generating locale-aware weekday labels.

Use Foundation’s Calendar, Date, and DateFormatter or appropriate modern formatting APIs.

Do not manually calculate Gregorian leap years.

The implementation should work with the user’s selected system calendar where practical.

⸻

8. Layout Adaptability

The widget must remain visually balanced regardless of the month.

Some months require four rows.

Others require five or six.

The layout should accommodate all cases without clipping.

Recommended approach:

* Use a seven-column grid.
* Calculate the required number of rows.
* Distribute available vertical space appropriately.
* Keep the weekday header separate from the date grid.
* Maintain consistent horizontal spacing.
* Use geometry-aware sizing only where beneficial.

Avoid hardcoded layouts that work only for five-row months.

The month should occupy most of the widget without looking cramped.

Test the longest possible calendar layout.

⸻

9. Containing Application

WidgetKit requires a containing application.

Keep this application extremely minimal.

9.1 Main Window

The containing application should display:

Glass Calendar

A simple explanation:

“Your minimal monthly calendar for macOS.”

Then provide instructions:

1. Right-click your desktop.
2. Select Edit Widgets.
3. Search for Glass Calendar.
4. Add the large widget.

Optionally include a small visual preview.

9.2 Application Behavior

The containing application must:

* Not require continuous execution.
* Not automatically launch at login.
* Not install a background service.
* Not create a menu bar icon.
* Not request unnecessary permissions.

Closing the containing application must not remove the widget.

The widget should remain available as long as the containing application is installed.

⸻

10. Performance

The widget must be lightweight.

Priorities:

1. Minimal memory usage.
2. Minimal CPU usage.
3. No unnecessary background execution.
4. No network requests.
5. No third-party libraries.
6. Efficient calendar calculations.
7. Native system rendering.

Avoid unnecessary animations and continuously updating views.

A static monthly calendar does not require continuous rendering.

⸻

11. Accessibility

Support standard macOS accessibility behavior.

Requirements:

* Readable text.
* Appropriate contrast.
* Dynamic system appearance.
* Meaningful accessibility labels.
* Correct date descriptions.
* No information communicated exclusively through color.

Consider VoiceOver accessibility for calendar dates.

The current date should be identifiable through accessibility information.

⸻

12. Testing Requirements

The agent must test the calendar calculations and widget layout.

12.1 Calendar Tests

Verify:

* January through December.
* Leap-year February.
* Non-leap-year February.
* Months starting on Sunday.
* Months starting on Monday.
* Months requiring six calendar rows.
* Different first-weekday settings.
* Month transitions.
* Year transitions.
* Time-zone changes.
* Daylight saving transitions.
* Locale-aware month formatting.

12.2 Visual Tests

Verify:

* Large widget dimensions.
* One month only.
* Correct weekday alignment.
* No clipped dates.
* No overlapping labels.
* Proper today highlight.
* Light mode.
* Dark mode.
* Supported clear/tinted widget appearances.
* Readability over light and dark wallpapers.

12.3 Runtime Tests

Verify:

* The widget appears in the macOS widget gallery.
* The widget can be added to the desktop.
* The widget can be added to Notification Center.
* The widget continues functioning after the containing app is closed.
* No custom background application remains running.
* No login item is installed.
* No network connection is required.

Normal macOS WidgetKit processes are permitted.

⸻

13. Build and Installation

The agent must create a working Xcode project.

Requirements:

* Target macOS 26 or newer.
* Use an installed, compatible Xcode version.
* Configure the macOS app target.
* Configure the WidgetKit extension target.
* Configure valid bundle identifiers.
* Configure the widget extension’s required settings.
* Ensure the project compiles.
* Resolve build errors.
* Avoid unnecessary entitlements.
* Use standard local development signing.

The agent should not assume that App Store distribution is required.

A free Apple development setup should be sufficient for local development where supported.

Do not purchase a paid Apple Developer Program membership.

The agent must explain any signing or installation limitations encountered.

⸻

14. Deliverables

The agent must provide:

A. Complete Xcode Project

A working project containing:

* Native macOS application.
* WidgetKit extension.
* SwiftUI calendar interface.
* Timeline provider.
* Calendar calculation logic.
* Required assets and configuration.

B. Working Large Calendar Widget

A widget that:

* Displays exactly one month.
* Uses the large square widget size.
* Highlights today.
* Updates automatically.
* Supports native macOS widget appearance behavior.

C. Installation Instructions

Provide clear steps for:

1. Opening the project in Xcode.
2. Configuring signing if necessary.
3. Building the application.
4. Installing or running the application.
5. Adding the widget to the desktop.
6. Adding the widget to Notification Center.
7. Enabling the supported macOS Tahoe clear appearance.
8. Troubleshooting widget discovery.

D. README

Include:

* Project overview.
* Requirements.
* Features.
* Installation instructions.
* Widget customization notes.
* Known limitations.
* Build instructions.

E. Test Results

Document which tests were executed and their outcomes.

Clearly distinguish tests that passed from tests that could not be run.

⸻

15. Explicitly Out of Scope

Do not implement the following in the initial version:

* Calendar event synchronization.
* Google Calendar integration.
* iCloud Calendar integration.
* EventKit access.
* Reminders integration.
* Weather.
* Clocks.
* Menu bar functionality.
* Custom desktop windows.
* Desktop overlays.
* Subscriptions.
* Accounts.
* Analytics.
* Network features.
* Multiple-month layouts.
* Complex settings screens.

This project is intentionally focused on displaying a beautiful, simple monthly calendar.

⸻

16. Definition of Done

The project is complete only when all of the following conditions are satisfied.

Calendar

* Exactly one full month is displayed.
* The widget uses the large square family.
* All dates are correct.
* Weekday alignment is correct.
* Today’s date is highlighted.
* Four-, five-, and six-row layouts work.
* Month transitions are handled.

Appearance

* The design looks native to macOS.
* Light mode works.
* Dark mode works.
* Supported macOS Tahoe widget appearance modes are respected.
* The background uses appropriate native WidgetKit APIs.
* The calendar remains readable.

System Integration

* The widget appears in the widget gallery.
* Desktop placement works.
* Notification Center placement works.
* The containing app can be closed.
* No continuously running custom background app is required.
* No menu bar item is created.
* No login item is installed.

Project

* The Xcode project builds successfully.
* The source code is included.
* No paid dependencies are required.
* No third-party dependencies are required.
* Installation instructions are included.
* Tests are included and results documented.

⸻

17. Instructions to the Coding Agent

You are responsible for implementing this project, not merely generating example code.

Follow this workflow:

Phase 1 — Research and validation

Inspect the installed macOS SDK and Xcode environment.

Confirm the public WidgetKit and SwiftUI APIs required for macOS 26.

Pay particular attention to system widget rendering, background treatment, and Liquid Glass compatibility.

Use Apple’s official documentation as the primary technical reference.

Phase 2 — Project creation

Create the native macOS application and WidgetKit extension.

Configure project settings, bundle identifiers, and deployment targets.

Phase 3 — Calendar implementation

Implement robust, locale-aware calendar calculations.

Build the single-month calendar view.

Ensure correct behavior across different month lengths and week-start preferences.

Phase 4 — Native appearance

Integrate the appropriate widget background APIs.

Support system-managed widget appearances where publicly supported.

Do not introduce custom transparency hacks.

Phase 5 — Testing

Build the project.

Run automated calendar tests.

Verify the widget’s visual layout.

Test the widget on an actual macOS Tahoe environment if available.

Phase 6 — Delivery

Provide the completed project, README, installation instructions, and test results.

If a requirement cannot be met because of a macOS platform limitation, clearly explain the limitation and implement the closest native alternative.

Do not silently substitute paid software, third-party widget engines, or background desktop applications.

Final Priority Order

When making implementation decisions, prioritize:

1. Native macOS Tahoe integration and Liquid Glass compatibility.
2. Exactly one month in a large square widget.
3. No continuously running companion application.
4. Completely free and dependency-free operation.
5. Clean, Apple-like visual design.
6. Reliable date calculations and updates.
7. Low resource consumption.

The final result should be a simple, elegant calendar widget that users can place on their macOS desktop and forget about.

Build the actual working application, not just a prototype.
