import UIKit
import SwiftUI

// MARK: - Push Operations

public extension UINavigationController {
    
    /// Pushes a SwiftUI View onto the receiver's stack and updates the display.
    /// - Parameters:
    ///   - view: The SwiftUI View to push.
    ///   - title: Optional title for the hosting controller.
    ///   - animated: Set this value to true to animate the transition.
    func push<Content: View>(view: Content, title: String? = nil, animated: Bool = true) {
        let viewWithEnv = view.environment(\.uiNavigationController, self)
        let hostingController = UIHostingController(rootView: viewWithEnv)
        hostingController.title = title
        pushViewController(hostingController, animated: animated)
    }
    
    /// Pushes a SwiftUI View and waits for the animation to complete.
    /// - Parameters:
    ///   - view: The SwiftUI View to push.
    ///   - title: Optional title for the hosting controller.
    ///   - animated: Set this value to true to animate the transition.
    func pushAsync<Content: View>(view: Content, title: String? = nil, animated: Bool = true) async {
        let viewWithEnv = view.environment(\.uiNavigationController, self)
        let hostingController = UIHostingController(rootView: viewWithEnv)
        hostingController.title = title
        await pushViewControllerAsync(hostingController, animated: animated)
    }
    
    /// Pushes a view controller and waits for the animation to complete.
    func pushViewControllerAsync(_ viewController: UIViewController, animated: Bool) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                continuation.resume()
            }
            pushViewController(viewController, animated: animated)
            CATransaction.commit()
        }
    }
}

// MARK: - Pop Operations

public extension UINavigationController {
    
    /// Pops the top view controller and waits for the animation to complete.
    @discardableResult
    func popViewControllerAsync(animated: Bool) async -> UIViewController? {
        await withCheckedContinuation { continuation in
            CATransaction.begin()
            CATransaction.setCompletionBlock { [weak self] in
                // Return what was popped (now gone from stack)
                continuation.resume(returning: nil)
            }
            let popped = popViewController(animated: animated)
            if popped == nil {
                CATransaction.commit()
                continuation.resume(returning: nil)
                return
            }
            CATransaction.commit()
        }
    }
    
    /// Pops to the root view controller and waits for the animation to complete.
    @discardableResult
    func popToRootViewControllerAsync(animated: Bool) async -> [UIViewController]? {
        await withCheckedContinuation { continuation in
            CATransaction.begin()
            var poppedControllers: [UIViewController]?
            CATransaction.setCompletionBlock {
                continuation.resume(returning: poppedControllers)
            }
            poppedControllers = popToRootViewController(animated: animated)
            CATransaction.commit()
        }
    }
    
    /// Pops view controllers until the specified SwiftUI View type is at the top of the navigation stack.
    /// - Parameters:
    ///   - viewType: The type of the SwiftUI View to find (e.g. `MyView.self`).
    ///   - animated: Set this value to true to animate the transition.
    /// - Returns: The array of popped view controllers, or nil if the view type was not found.
    @discardableResult
    func popTo<Content: View>(viewType: Content.Type, animated: Bool = true) -> [UIViewController]? {
        let targetTypeName = String(describing: viewType)
        
        for vc in viewControllers.reversed() {
            let vcTypeString = String(describing: type(of: vc))
            
            if vcTypeString.contains("UIHostingController") && vcTypeString.contains(targetTypeName) {
                return popToViewController(vc, animated: animated)
            }
        }
        
        return nil
    }
    
    /// Pops to a specific SwiftUI view type and waits for the animation to complete.
    /// - Parameters:
    ///   - viewType: The type of the SwiftUI View to find.
    ///   - animated: Set this value to true to animate the transition.
    /// - Returns: True if the view was found and popped to, false otherwise.
    @discardableResult
    func popToAsync<Content: View>(viewType: Content.Type, animated: Bool = true) async -> Bool {
        let targetTypeName = String(describing: viewType)
        
        for vc in viewControllers.reversed() {
            let vcTypeString = String(describing: type(of: vc))
            
            if vcTypeString.contains("UIHostingController") && vcTypeString.contains(targetTypeName) {
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    CATransaction.begin()
                    CATransaction.setCompletionBlock {
                        continuation.resume()
                    }
                    popToViewController(vc, animated: animated)
                    CATransaction.commit()
                }
                return true
            }
        }
        
        return false
    }
}

// MARK: - Query Operations

public extension UINavigationController {
    
    /// Checks if a SwiftUI View of a specific type exists in the stack.
    func contains<Content: View>(viewType: Content.Type) -> Bool {
        let targetTypeName = String(describing: viewType)
        return viewControllers.contains { vc in
            let vcTypeString = String(describing: type(of: vc))
            return vcTypeString.contains("UIHostingController") && vcTypeString.contains(targetTypeName)
        }
    }
    
    /// Returns the index of a SwiftUI View type in the stack, or nil if not found.
    func indexOf<Content: View>(viewType: Content.Type) -> Int? {
        let targetTypeName = String(describing: viewType)
        return viewControllers.firstIndex { vc in
            let vcTypeString = String(describing: type(of: vc))
            return vcTypeString.contains("UIHostingController") && vcTypeString.contains(targetTypeName)
        }
    }
}

