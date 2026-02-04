import SwiftUI
import NavigationX

@main
struct NavigationXDemoApp: App {
    init() {
        print("🚀 [App] NavigationXDemoApp.init - Swizzling DISABLED for NavigationStack compatibility")
        // SwizzlingManager.install()
    }
    
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
