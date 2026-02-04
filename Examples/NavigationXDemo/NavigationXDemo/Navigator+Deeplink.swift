import Foundation
import NavigationX
import UIKit

// Restore the handleDeeplink method specifically for this app
// since we removed it from the shared package core.

public extension Navigator {
    
    /// Handle a deeplink URL by delegating to the app's shared router
    /// - Parameter url: The deeplink URL
    func handleDeeplink(_ url: URL) {
        print("🧭 [Navigator+App] handleDeeplink: \(url.absoluteString)")
        
        // We use the same logic: find the source and delegate
        if let topVC = self.topViewController {
            print("🧭 [Navigator+App] using topViewController: \(topVC)")
            // Note: DeeplinkRouter is now the local one in this module
            DeeplinkRouter.shared.handle(url: url, from: topVC)
        } else if let navigationController = navigationController {
             print("🧭 [Navigator+App] using navigationController itself: \(navigationController)")
             DeeplinkRouter.shared.handle(url: url, from: navigationController)
        } else {
            print("🔴 [Navigator+App] Cannot handle deeplink - no view controller available to act as source")
        }
    }
}
