import UIKit
import NavigationX

/// Defines the navigation type for a deeplink destination
public enum DeeplinkNavigationType {
    case push
    case present
}

/// Protocol that ViewControllers conform to for deeplink handling capabilities
public protocol DeeplinkNavigatable: UIViewController {
    /// Navigate to a deeplink destination
    /// - Parameter url: The deeplink URL
    func navigate(to url: URL)
}

public extension DeeplinkNavigatable {
    func navigate(to url: URL) {
        // Default implementation delegates to the singleton router
        // passing self as the source view controller
        DeeplinkRouter.shared.handle(url: url, from: self)
    }
}

// Extension to make it easier for any UIViewController to be "Deeplink Aware"
// even if they don't explicitly conform (though conformance is preferred)
public extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        }
        return self
    }
}
