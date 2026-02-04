import UIKit
import SwiftUI

// MARK: - UIViewController Extension for Navigation

public extension UIViewController {
    
    /// Push a SwiftUI view from this view controller
    @MainActor
    func pushSwiftUIView<V: View>(_ view: V, animated: Bool = true) {
        print("📱 [UIViewController] pushSwiftUIView - view: \(type(of: view)), animated: \(animated)")
        let hostingController = UIHostingController(rootView: view)
        navigationController?.pushViewController(hostingController, animated: animated)
    }
    
    /// Push a SwiftUI view with navigator environment injected
    @MainActor
    func pushBridgedSwiftUIView<V: View>(_ view: V, animated: Bool = true) {
        print("📱 [UIViewController] pushBridgedSwiftUIView - view: \(type(of: view)), animated: \(animated)")
        guard let navController = navigationController else {
            print("🔴 [UIViewController] pushBridgedSwiftUIView - navigationController is nil!")
            return
        }
        
        print("📱 [UIViewController] Creating Navigator and wrapping view with environment")
        let navigator = Navigator(navigationController: navController)
        let wrappedView = view.environment(\.navigator, navigator)
        let hostingController = UIHostingController(rootView: wrappedView)
        print("📱 [UIViewController] Pushing hosting controller")
        navController.pushViewController(hostingController, animated: animated)
    }
}

// MARK: - Convenience for Creating Bridged Hosting Controllers

@MainActor
public func makeBridgedHostingController<V: View>(
    for view: V,
    with navigationController: UINavigationController
) -> UIHostingController<some View> {
    print("📱 [makeBridgedHostingController] Creating for view: \(type(of: view))")
    let navigator = Navigator(navigationController: navigationController)
    let wrappedView = view.environment(\.navigator, navigator)
    return UIHostingController(rootView: wrappedView)
}
