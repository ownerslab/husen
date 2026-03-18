import SwiftUI

@main
struct HusenApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 280, minHeight: 200)
        }
    }
}
