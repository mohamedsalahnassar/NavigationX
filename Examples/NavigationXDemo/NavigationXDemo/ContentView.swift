import SwiftUI
import NavigationX
import NavigationXLite

struct ContentView: View {
    var body: some View {
        TabView {
            // Tab A: Simple Demo
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
                    DeeplinkViewControllerWrapper(title: "UIKit Screen", subtitle: "Managed by NavStack", id: id)
                }
                .navDestination(name: "Profile") { id in
                    InspectorOverlayWrapper {
                        Text("Profile Screen") // Minimal example
                    }
                }
            }
            .tabItem {
                Label("Simple Demo", systemImage: "shippingbox")
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
                        SwiftUIDemoScreen(title: "Settings", id: id)
                    }
                }
            }
            .tabItem {
                Label("DeepLink", systemImage: "link")
            }
            
            // Tab C: Shop Flow (Complex Example)
            NavStack {
                ShopHomeView()
                    .navDestination(name: "ProductDetail") { id in
                        ProductDetailView(productId: id.id)
                    }
                    .navDestination(name: "LoginVC") { id in
                         // UIViewControllerRepresentable wrapper for LoginVC
                         NavigationXViewController(title: "Login", id: id) {
                             LoginViewController()
                         }
                    }
                    .navDestination(name: "CartView") { id in
                         CartView()
                    }
                    .navDestination(name: "PaymentVC") { id in
                         NavigationXViewController(title: "Payment", id: id) {
                             PaymentViewController()
                         }
                    }
                    .navDestination(name: "OrderSuccess") { id in
                        OrderSuccessView()
                    }
            }
            .tabItem {
                Label("Shop Flow (Complex)", systemImage: "cart.fill")
            }
            
            // Tab D: Lite Demo (Direct Access)
            NativeNavStack {
                LiteDemoView()
            }
            .tabItem {
                Label("Lite (Direct)", systemImage: "bolt.fill")
            }
        }
    }
}

struct LiteDemoView: View {
    @Environment(\.uiNavigationController) var nc
    
    var body: some View {
        VStack(spacing: 20) {
            Text("⚡️ NavigationLite")
                .font(.largeTitle)
                .bold()
            
            Text("Captured NC: \(nc != nil ? "✅" : "❌")")
                .foregroundColor(nc != nil ? .green : .red)
            
            if let nc = nc {
                Text(String(describing: nc))
                    .font(.caption)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Button("Push UIKit VC (Generic)") {
                    let vc = UIViewController()
                    vc.view.backgroundColor = .systemYellow
                    vc.title = "Generic VC"
                    nc.pushViewController(vc, animated: true)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("Waiting for Introspection...")
            }
        }
        .navigationTitle("Lite Demo")
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
