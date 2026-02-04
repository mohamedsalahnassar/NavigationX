import SwiftUI
import NavigationX

@main
struct NavigationXDemoApp: App {
    init() {
        print("🚀 [App] NavigationXDemoApp.init - Installing swizzling")
        SwizzlingManager.install()
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
