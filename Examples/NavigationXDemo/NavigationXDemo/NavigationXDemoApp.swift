import SwiftUI
import NavigationX

@main
struct NavigationXDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStackX {
                HomeSwiftUIScreen()
            }
            .tint(.white)
        }
    }
}
