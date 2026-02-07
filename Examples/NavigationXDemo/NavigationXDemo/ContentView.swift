import SwiftUI
import NavigationX

// MARK: - Content View

/// Main entry point for the NavigationX Demo.
/// Wraps the HomeScreen in a NavigationStackX to enable hybrid navigation.
struct ContentView: View {
    var body: some View {
        NavigationStackX {
            HomeScreen()
        }
    }
}

#Preview {
    ContentView()
}
