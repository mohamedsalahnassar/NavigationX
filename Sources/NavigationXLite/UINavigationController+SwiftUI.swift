import UIKit
import SwiftUI

public extension UINavigationController {
    
    // MARK: - Push SwiftUI View
    
    /// Pushes a SwiftUI View onto the receiver’s stack and updates the display.
    /// - Parameters:
    ///   - view: The SwiftUI View to push.
    ///   - title: Optional title for the hosting controller.
    ///   - animated: Set this value to true to animate the transition.
    func push<Content: View>(view: Content, title: String? = nil, animated: Bool = true) {
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = title
        // We can also set a referencing environment object if needed, but for Lite we keep it simple.
        self.pushViewController(hostingController, animated: animated)
    }
    
    // MARK: - Pop to SwiftUI View Type
    
    /// Pops view controllers until the specified SwiftUI View type is at the top of the navigation stack.
    /// - Parameters:
    ///   - viewType: The type of the SwiftUI View to find (e.g. `MyView.self`).
    ///   - animated: Set this value to true to animate the transition.
    /// - Returns: The array of popped view controllers, or nil if the view type was not found.
    @discardableResult
    func popTo<Content: View>(viewType: Content.Type, animated: Bool = true) -> [UIViewController]? {
        // Iterate through the navigation stack in reverse order to find the *most recent* instance.
        // Actually, popToViewController usually targets the *first* instance found from the bottom? 
        // Standard behavior matches: find the VC in `viewControllers`.
        
        for vc in viewControllers.reversed() {
            if vc is UIHostingController<Content> {
                return self.popToViewController(vc, animated: animated)
            }
        }
        
        print("⚠️ [NavigationXLite] popTo failed: No hosting controller found for type \(String(describing: viewType))")
        return nil
    }
    
    // MARK: - Check existence
    
    /// Checks if a SwiftUI View of a specific type exists in the stack.
    func contains<Content: View>(viewType: Content.Type) -> Bool {
        return viewControllers.contains { $0 is UIHostingController<Content> }
    }
}
