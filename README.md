# Glass Calendar

A minimal native macOS calendar widget: one full month in a large (`systemLarge`) WidgetKit widget, with today highlighted. SwiftUI + WidgetKit only. No background app, no menu bar item, no network, no permissions, no dependencies.

## Requirements

- macOS 26 Tahoe or newer
- Xcode 26 or newer (built and tested with Xcode 27.0 / macOS 27.0 SDK)
- No paid Apple Developer membership

## Features

- Exactly one month, filling the large widget; 4-, 5- and 6-row months all fit
- Month title, weekday headers and first weekday follow the system locale and calendar
- Today highlighted by a circle using the system accent colour (full-colour mode)
- Timeline of daily entries at local midnights, so the highlight and month roll over without polling
- System-managed background via `containerBackground(.fill.tertiary, for: .widget)`
- VoiceOver: each day reads its full date, today is announced and marked selected

## Build and install

```sh
xcodebuild -project GlassCalendar.xcodeproj -scheme GlassCalendar -configuration Release build
```

Or open `GlassCalendar.xcodeproj` in Xcode and press Run.

The project signs ad hoc (`CODE_SIGN_IDENTITY = -`), which needs no Apple account. To make a stable install:

1. Copy the built `GlassCalendar.app` into `/Applications` or `~/Applications`.
2. Launch it once so macOS registers the widget extension, then quit it.
3. Right-click the desktop, choose **Edit Widgets**, search for **Glass Calendar**, and add the large widget.
4. Notification Center: open it, click **Edit Widgets** at the bottom, and add the same widget.
5. Clear appearance: System Settings > Desktop & Dock > Widgets, set the widget style (Automatic, Monochrome, Full-color) as desired. The system applies it; the widget does not draw its own glass.

### Troubleshooting widget discovery

- Make sure the app lives in `/Applications` or `~/Applications` and has been launched once.
- Check registration: `pluginkit -mAv | grep -i glass`
- Re-register: `pluginkit -a /path/to/GlassCalendar.app/Contents/PlugIns/GlassCalendarWidget.appex`
- Restart the widget daemons: `killall chronod NotificationCenter`
- With a free Apple ID, set your team under Signing & Capabilities in Xcode if ad hoc signing is rejected on your machine.

## Tests

```sh
xcodebuild -project GlassCalendar.xcodeproj -scheme GlassCalendar test
```

## Layout

- `Shared/` calendar maths (`CalendarGrid`, `CalendarTimeline`) and `CalendarMonthView`, compiled into the app, widget and tests
- `GlassCalendarWidget/` provider, entry, widget and bundle
- `GlassCalendar/` the minimal containing app (instructions plus a preview; quits when its window closes)
- `GlassCalendarTests/` Swift Testing suite
- `Config/` entitlements (sandbox only) and the extension Info.plist

## Test results

Passed (22 tests, `xcodebuild test`):

- Day counts for all twelve months of a non-leap year; leap and non-leap February
- Months starting on Sunday and Monday; Sunday, Monday and Saturday week starts
- 4-, 5- and 6-row layouts; every row has 7 cells and every day appears once
- Weekday alignment and header order; December to January transition
- Today highlight only in its own month; today differs by time zone
- Month title in en_US, fr_FR, de_DE, ja_JP; Islamic (Umm al-Qura) month lengths
- VoiceOver date label
- Timeline entries at local midnights, month boundary, DST days (New York, Berlin)

Verified manually:

- Release build succeeds; widget is sandboxed, signed ad hoc and registered with `pluginkit`
- Layout rendered at widget size (364x382) for a 5-row month in light mode and a 6-row month in dark mode: no clipping or overlap
- After quitting the app, no GlassCalendar process or launch agent remains

Not run (needs a person at the desktop):

- Adding the widget to the desktop and Notification Center
- Clear and tinted (accented) appearances on real wallpapers
- Midnight rollover on a live widget

## Known limitations

- Transparency and the clear/tinted styles are applied by macOS; there is no adjustable blur.
- In tinted mode the today marker is a translucent circle marked `widgetAccentable`; its look has not been checked on a real desktop.
- WidgetKit decides when to refresh, so the midnight update may be delayed. A time-zone change updates on the next system refresh.
- Day-number text uses the system rounded design only where the renderer honours it.
