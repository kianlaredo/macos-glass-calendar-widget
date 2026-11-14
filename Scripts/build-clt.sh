#!/bin/sh
set -eu

BUNDLE_ID=com.kianlaredo.GlassCalendar
OUTPUT_APP=${1:-build/clt/GlassCalendar.app}
WIDGET_DIR=$OUTPUT_APP/Contents/PlugIns/GlassCalendarWidget.appex/Contents
APP_DIR=$OUTPUT_APP/Contents
SWIFT_FLAGS="-O -swift-version 6 -default-isolation MainActor -target arm64-apple-macosx26.0"

rm -rf "$OUTPUT_APP"
mkdir -p "$APP_DIR/MacOS" "$WIDGET_DIR/MacOS"

swiftc $SWIFT_FLAGS -parse-as-library -application-extension \
    -Xlinker -e -Xlinker _NSExtensionMain \
    -o "$WIDGET_DIR/MacOS/GlassCalendarWidget" \
    GlassCalendarWidget/*.swift Shared/*.swift

swiftc $SWIFT_FLAGS -parse-as-library \
    -o "$APP_DIR/MacOS/GlassCalendar" \
    GlassCalendar/*.swift Shared/*.swift

write_info_plist() {
    /usr/libexec/PlistBuddy \
        -c "Add :CFBundleIdentifier string $2" \
        -c "Add :CFBundleExecutable string $3" \
        -c "Add :CFBundleName string $3" \
        -c "Add :CFBundleDisplayName string Glass Calendar" \
        -c "Add :CFBundlePackageType string $4" \
        -c "Add :CFBundleShortVersionString string 1.0" \
        -c "Add :CFBundleVersion string 1" \
        -c "Add :LSMinimumSystemVersion string 26.0" \
        -c "Merge $5" \
        "$1" > /dev/null
}

write_info_plist "$APP_DIR/Info.plist" "$BUNDLE_ID" GlassCalendar APPL Config/App-Info.plist
write_info_plist "$WIDGET_DIR/Info.plist" "$BUNDLE_ID.Widget" GlassCalendarWidget XPC! Config/Widget-Info.plist

codesign --force -s - --entitlements Config/Widget.entitlements \
    "$OUTPUT_APP/Contents/PlugIns/GlassCalendarWidget.appex"
codesign --force -s - --entitlements Config/App.entitlements "$OUTPUT_APP"
