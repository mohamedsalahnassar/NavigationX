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
        // We must inject the navigation controller into the environment of the new view,
        // otherwise the new UIHostingController starts with a fresh environment (nc = nil).
        let viewWithEnv = view.environment(\.uiNavigationController, self)
        let hostingController = UIHostingController(rootView: viewWithEnv)
        hostingController.title = title
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
        
        print("🔍 [NavigationX] Searching for VC hosting: \(viewType)")
        for (index, vc) in viewControllers.reversed().enumerated() {
            let vcTypeString = String(describing: type(of: vc))
            print("   [\(index)] \(vcTypeString)")
            
            // Check if it's a UIHostingController and contains the View type name in its generic signature.
            // This handles ModifiedContent<View, ...> wrapping caused by environment injection.
            if vcTypeString.contains("UIHostingController") && vcTypeString.contains(String(describing: viewType)) {
                print("   ✅ Match found (via String check)!")
                return self.popToViewController(vc, animated: animated)
            }
        }
        
        print("⚠️ [NavigationX] popTo failed: No hosting controller found for type \(String(describing: viewType))")
        return nil
    }
    
    // MARK: - Check existence
    
    /// Checks if a SwiftUI View of a specific type exists in the stack.
    func contains<Content: View>(viewType: Content.Type) -> Bool {
        return viewControllers.contains { $0 is UIHostingController<Content> }
    }
}
