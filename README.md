# Glass Calendar

A minimal macOS widget showing one full month, with today highlighted.

## Requirements

- macOS 26 or newer
- Xcode 26 or newer

## Install

```sh
make install
```

This builds the app, copies it to `~/Applications`, launches it once so macOS registers the widget, then quits it and restarts the widget daemons.

Then right-click the desktop, choose **Edit Widgets**, and add **Glass Calendar** (large).

## Uninstall

```sh
make uninstall
```

This quits the app, unregisters the widget, removes `~/Applications/GlassCalendar.app` and restarts the widget daemons.
