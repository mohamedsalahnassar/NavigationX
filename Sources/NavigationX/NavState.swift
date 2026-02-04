import UIKit

// MARK: - Associated Object Key

private nonisolated(unsafe) var bridgeStateKey: UInt8 = 0

// MARK: - Navigation Bridge State

/// Per-controller navigation state stored via associated objects
/// This ensures each UINavigationController has its own isolated state
@MainActor
public final class NavState {
    
    /// Weak reference to the navigation controller
    public private(set) weak var navigationController: UINavigationController?
    
    /// Weak reference to the bridge delegate
    public weak var delegate: NavigationXDelegate?
    
    /// Whether this bridge is active and should intercept navigation
    public var isActive: Bool = true
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    /// Current view controllers in the navigation stack
    public var viewControllers: [UIViewController] {
        navigationController?.viewControllers ?? []
    }
}

// MARK: - UINavigationController Extension

public extension UINavigationController {
    
    /// Gets or creates the bridge state for this navigation controller
    /// Each controller has its own isolated state - no global singletons
    var bridgeState: NavState {
        if let existing = objc_getAssociatedObject(self, &bridgeStateKey) as? NavState {
            return existing
        }
        let state = NavState(navigationController: self)
        objc_setAssociatedObject(self, &bridgeStateKey, state, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return state
    }
    
    /// Convenience to set the bridge delegate
    var bridgeDelegate: NavigationXDelegate? {
        get { bridgeState.delegate }
        set { bridgeState.delegate = newValue }
    }
}
