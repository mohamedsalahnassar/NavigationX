import UIKit
import SwiftUI

// MARK: - Navigator

/// Main navigation interface for pushing and popping view controllers
/// Works with both SwiftUI views and UIKit view controllers
@MainActor
public final class Navigator: ObservableObject, NavigationXDelegate {
    
    /// The underlying navigation controller
    public private(set) weak var navigationController: UINavigationController?
    
    /// Initialize with a navigation controller
    public init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
        print("🧭 [Navigator] init - navigationController: \(String(describing: navigationController))")
        navigationController?.bridgeDelegate = self
    }
    
    /// Binds this navigator to a navigation controller
    public func bind(to navigationController: UINavigationController) {
        print("🧭 [Navigator] bind(to:) - binding to: \(navigationController)")
        self.navigationController = navigationController
        navigationController.bridgeDelegate = self
    }
    
    // MARK: - Push Operations
    
    /// Push a SwiftUI view onto the navigation stack
    public func push<V: View>(_ view: V, animated: Bool = true) {
        print("🧭 [Navigator] push(SwiftUI view: \(type(of: view)), animated: \(animated))")
        let viewWithEnv = view
            .environmentObject(self)
            .environment(\.navigator, self)
        let hostingController = UIHostingController(rootView: viewWithEnv)
        push(hostingController, animated: animated)
    }
    
    /// Push a UIViewController onto the navigation stack
    public func push(_ viewController: UIViewController, animated: Bool = true) {
        print("🧭 [Navigator] push(ViewController: \(type(of: viewController)), animated: \(animated))")
        print("🧭 [Navigator] navigationController is: \(String(describing: navigationController))")
        if let navController = navigationController {
            print("🧭 [Navigator] Calling pushViewController on \(navController)")
            navController.pushViewController(viewController, animated: animated)
        } else {
            print("🔴 [Navigator] ❌ Cannot push - navigationController is nil!")
        }
    }
    
    // MARK: - Pop Operations
    
    @discardableResult
    public func pop(animated: Bool = true) -> UIViewController? {
        print("🧭 [Navigator] pop(animated: \(animated))")
        let result = navigationController?.popViewController(animated: animated)
        print("🧭 [Navigator] pop returned: \(String(describing: result))")
        return result
    }
    
    @discardableResult
    public func pop(to viewController: UIViewController, animated: Bool = true) -> [UIViewController]? {
        print("🧭 [Navigator] pop(to: \(viewController), animated: \(animated))")
        return navigationController?.popToViewController(viewController, animated: animated)
    }
    
    @discardableResult
    public func popToRoot(animated: Bool = true) -> [UIViewController]? {
        print("🧭 [Navigator] popToRoot(animated: \(animated))")
        return navigationController?.popToRootViewController(animated: animated)
    }
    
    // MARK: - Stack Access
    
    public var viewControllers: [UIViewController] {
        navigationController?.viewControllers ?? []
    }
    
    public var topViewController: UIViewController? {
        navigationController?.topViewController
    }
    
    public var stackDepth: Int {
        navigationController?.viewControllers.count ?? 0
    }
    
    // MARK: - Stack Manipulation
    
    public func setViewControllers(_ viewControllers: [UIViewController], animated: Bool = true) {
        print("🧭 [Navigator] setViewControllers(count: \(viewControllers.count), animated: \(animated))")
        navigationController?.setViewControllers(viewControllers, animated: animated)
    }
    // MARK: - NavigationXDelegate
    
    public func navigationController(_ navigationController: UINavigationController, didPush viewController: UIViewController, animated: Bool) {
        print("🧭 [Navigator] Did push \(type(of: viewController)) - notifying observers")
        notifyObserversAfterTransition(for: navigationController)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didPop viewControllers: [UIViewController], animated: Bool) {
        print("🧭 [Navigator] Did pop \(viewControllers.count) VCs - notifying observers")
        notifyObserversAfterTransition(for: navigationController)
    }
    
    private func notifyObserversAfterTransition(for navigationController: UINavigationController) {
        // If there is an active transition, wait for it to complete.
        if let coordinator = navigationController.transitionCoordinator {
            print("🧭 [Navigator] Transition active, waiting for completion...")
            coordinator.animate(alongsideTransition: nil) { [weak self] _ in
                print("🧭 [Navigator] Transition completed, notifying observers now.")
                // Ensure we are on main actor (coordinator callback is usually on main, but safe to force)
                Task { @MainActor [weak self] in
                    self?.objectWillChange.send()
                }
            }
        } else {
            // No active transition, update immediately (async to be safe)
            print("🧭 [Navigator] No active transition, notifying immediately.")
            Task { @MainActor [weak self] in
                self?.objectWillChange.send()
            }
        }
    }


}

