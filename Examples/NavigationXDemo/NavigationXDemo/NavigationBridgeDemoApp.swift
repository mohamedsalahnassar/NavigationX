import SwiftUI
import NavigationX

@main
struct NavigationXDemoApp: App {
    // No setup needed for NavigationX (Lite)
    
    var body: some Scene {
        WindowGroup {
            let _ = print("🚀 [App] WindowGroup.body")
            ContentView()
                .onAppear {
                    print("🚀 [App] ContentView appeared")
                }
        }
    }
}
