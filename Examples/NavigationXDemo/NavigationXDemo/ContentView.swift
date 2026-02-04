import SwiftUI
import NavigationX

struct ContentView: View {
    var body: some View {
        TabView {
            // Tab A: Mixed Stack Test
            NavStack {
                InspectorOverlayWrapper {
                    SwiftUIDemoScreen(title: "Tab A Root", id: nil)
                }
                    .navDestination(name: "Detail") { id in
                        InspectorOverlayWrapper {
                            SwiftUIDemoScreen(title: "SwiftUI Detail", id: id)
                        }
                    }
                    .navDestination(name: "UIKit-Screen") { id in
                         // Native VC will handle its own inspector
                         DeeplinkViewControllerWrapper(title: "UIKit Screen", subtitle: "Managed by NavStack", id: id)
                    }
                    .navDestination(name: "Profile") { id in
                        InspectorOverlayWrapper {
                             Text("Profile Screen") // Minimal example
                        }
                    }
            }
            .tabItem {
                Label("Mixed Flow", systemImage: "shuffle")
            }
            
            // Tab B: Deep Link
            NavStack {
                InspectorOverlayWrapper {
                    DeeplinkDemoView()
                }
                    .navDestination(name: "Profile") { id in
                        InspectorOverlayWrapper {
                            SwiftUIDemoScreen(title: "Profile from Deep Link", id: id)
                        }
                    }
                     .navDestination(name: "Settings") { id in
                        InspectorOverlayWrapper {
                            SwiftUIDemoScreen(title: "Settings from Deep Link", id: id)
                        }
                    }
            }
            .tabItem {
                Label("DeepLink", systemImage: "link")
            }
        }
    }
}

struct CustomNavLink<Label: View>: View {
    let id: ScreenIdentifier
    let label: () -> Label
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        Button(action: {
            print("🔘 [CustomNavLink] Tapped \(id.name)")
            coordinator.push(id)
        }) {
            label()
        }
    }
}



import SwiftUI
import NavigationX

struct InspectorOverlayWrapper<Content: View>: View {
    let content: Content
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            content
            
            // Only show if NOT root (index > 0)
            if !coordinator.path.isEmpty {
                StackInspector(coordinator: coordinator)
                    .padding(.bottom, 50) // Lift above tab bar slightly
            }
        }
    }
}
