import SwiftUI
import NavigationX

struct ContentView: View {
    var body: some View {
        TabView {
            // Tab A: Starts with a SwiftUI View
            NavStack {
                SwiftUIDemoScreen(title: "Tab A Root (SwiftUI)")
            }
            .tabItem {
                Label("Stack A", systemImage: "a.square.fill")
            }
            
            // Tab B: Starts with a SwiftUI View, but let's make the second push a UIKit one easily
            NavStack {
                SwiftUIDemoScreen(title: "Tab B Root (SwiftUI)", color: .mint)
            }
            .tabItem {
                Label("Stack B", systemImage: "b.square.fill")
            }
            
            // Tab C: Deeplink Demo
            NavStack {
                DeeplinkDemoView()
                    .navigationTitle("Deeplinks")
            }
            .tabItem {
                Label("Deeplinks", systemImage: "link")
            }
        }
    }
}

#Preview {
    ContentView()
}
