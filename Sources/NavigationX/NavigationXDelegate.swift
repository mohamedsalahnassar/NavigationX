import UIKit

// MARK: - Navigation Bridge Delegate

/// Protocol for receiving navigation events from a UINavigationController
@MainActor
public protocol NavigationXDelegate: AnyObject {
    /// Called before a view controller is pushed onto the navigation stack
    func navigationController(_ navigationController: UINavigationController, willPush viewController: UIViewController, animated: Bool)
    
    /// Called after a view controller is pushed onto the navigation stack
    func navigationController(_ navigationController: UINavigationController, didPush viewController: UIViewController, animated: Bool)
    
    /// Called before view controllers are popped from the navigation stack
    func navigationController(_ navigationController: UINavigationController, willPop viewControllers: [UIViewController], animated: Bool)
    
    /// Called after view controllers are popped from the navigation stack
    func navigationController(_ navigationController: UINavigationController, didPop viewControllers: [UIViewController], animated: Bool)
}

// MARK: - Default Implementations

public extension NavigationXDelegate {
    func navigationController(_ navigationController: UINavigationController, willPush viewController: UIViewController, animated: Bool) {}
    func navigationController(_ navigationController: UINavigationController, didPush viewController: UIViewController, animated: Bool) {}
    func navigationController(_ navigationController: UINavigationController, willPop viewControllers: [UIViewController], animated: Bool) {}
    func navigationController(_ navigationController: UINavigationController, didPop viewControllers: [UIViewController], animated: Bool) {}
}
