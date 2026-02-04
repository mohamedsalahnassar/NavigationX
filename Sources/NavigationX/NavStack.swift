import SwiftUI
import NavigationIntrospect

// MARK: - Bridged Navigation Stack

/// A drop-in replacement for NavigationStack that provides UIKit/SwiftUI bridging
public struct NavStack<Content: View>: View {
    // We use a Holder to own the Navigator via StateObject so it survives,
    // BUT we intentionally do not want NavStack to observe Navigator's changes.
    // Accessing `navigator` inside the body of a View where `navigator` is a StateObject 
    // implicitly subscribes the View to updates.
    // By wrapping it in a Holder that doesn't forward changes, we break the loop.
    @StateObject private var holder = NavigatorHolder()
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
        print("🌉 [NavStack] init")
    }
    
    public var body: some View {
        // Accessing holder is fine because Holder doesn't publish changes when Navigator does.
        let navigator = holder.navigator
        
        NavigationStack {
            content
                .environment(\.navigator, navigator)
                .environmentObject(navigator)
        }
        .introspectNavigationController { [weak navigator] navigationController in
            guard let navigator else { return }
            if navigator.navigationController !== navigationController {
                print("🌉 [NavStack] Binding navigator to navigationController")
                navigator.bind(to: navigationController)
            }
        }
        .onAppear {
            print("🌉 [NavStack] onAppear - installing swizzling")
            NavigationXSwizzling.install()
        }
    }
}

// A wrapper to hold the Navigator instance.
// It is an ObservableObject so it can be used with StateObject to maintain lifecycle,
// but it DOES NOT emit changes when the underlying navigator changes.
@MainActor
private class NavigatorHolder: ObservableObject {
    let navigator = Navigator()
}
