import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private static let calendarSchemeProbeURL = URL(string: "webcal://")!
    private static let builtInCalendarBundleIdentifier = "com.apple.iCal"

    private var isDefaultLaunch = true

    func applicationDidFinishLaunching(_ notification: Notification) {
        isDefaultLaunch = notification.userInfo?[NSApplication.launchIsDefaultUserInfoKey] as? Bool ?? true
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard urls.contains(where: { $0.scheme == "glasscalendar" }) else { return }
        openDefaultCalendarApp()
        DispatchQueue.main.async { [self] in
            guard !isDefaultLaunch else { return }
            NSApp.windows.forEach { $0.orderOut(nil) }
            NSApp.terminate(nil)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func openDefaultCalendarApp() {
        let workspace = NSWorkspace.shared
        guard let calendarAppURL = workspace.urlForApplication(toOpen: Self.calendarSchemeProbeURL)
            ?? workspace.urlForApplication(withBundleIdentifier: Self.builtInCalendarBundleIdentifier)
        else { return }
        workspace.openApplication(at: calendarAppURL, configuration: NSWorkspace.OpenConfiguration())
    }
}

@main
struct GlassCalendarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
