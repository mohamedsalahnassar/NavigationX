import UIKit
import SwiftUI

/// Manages swizzling of UINavigationController methods to intercept navigation events.
public class SwizzlingManager {
    @MainActor static let shared = SwizzlingManager()
    private var isSwizzled = false
    
    @MainActor
    public static func install() {
        shared.swizzle()
    }
    
    private func swizzle() {
        guard !isSwizzled else { return }
        isSwizzled = true
        
        // Swizzle pushViewController
        let pushSelector = #selector(UINavigationController.pushViewController(_:animated:))
        let swizzledPushSelector = #selector(UINavigationController.navx_pushViewController(_:animated:))
        method_exchangeImplementations(
            class_getInstanceMethod(UINavigationController.self, pushSelector)!,
            class_getInstanceMethod(UINavigationController.self, swizzledPushSelector)!
        )
        
        // Swizzle popViewController
        let popSelector = #selector(UINavigationController.popViewController(animated:))
        let swizzledPopSelector = #selector(UINavigationController.navx_popViewController(animated:))
        method_exchangeImplementations(
            class_getInstanceMethod(UINavigationController.self, popSelector)!,
            class_getInstanceMethod(UINavigationController.self, swizzledPopSelector)!
        )
        
        // TODO: popToViewController, popToRootViewController, setViewControllers
    }
}

extension UINavigationController {
    
    @objc func navx_pushViewController(_ viewController: UIViewController, animated: Bool) {
        // Check if I am managed by NavigationX
        if let coordinator = self.coordinator {
             print("🕵️ [Swizzling] Intercepted push on managed NC: \(viewController)")
            // If managed, we should check if this push is coming from the sync engine or imperative code
            // How do we distinguish? 
            // 1. Sync engine uses `setViewControllers` or we can set a flag on the coordinator.
            // 2. OR, we just update the path and let the observer sync?
            // If we update path -> Observer -> Sync -> pushViewController -> Loop!
            
            // To avoid loop:
            // Sync engine should append the ID to the VC before pushing?
            // Or use a lock/flag.
            
            // But wait, user requirement: "delegate this action to the coordinator"
            // And "coordinator will sync the requested changes to the navigation path array"
            
            // If we delegate to coordinator:
            // Coordinator.push(viewController)
            // This appends to path.
            // Path change triggers sync.
            // Sync triggers push.
            // Push triggers INTERCEPT. -> LOOP.
            
            // FIX:
            // If the VC already has an identifier that matches the destination in path, we assume it's a sync action?
            // Or we check a flag `isSyncing`.
            
            let id = viewController.screenIdentifier ?? ScreenIdentifier(name: "Imperative_\(type(of: viewController))")
            viewController.screenIdentifier = id
            
            print("🕵️ [Swizzling] Intercepted push: \(id.name)")

            // If this ID is ALREADY the last item in the path, proceed (it's the sync action).
            if let last = coordinator.path.last, last == id {
                 print("✅ [Swizzling] Sync push authorized for \(id.name)")
                 self.navx_pushViewController(viewController, animated: animated)
                 return
            }
            
            // OTHERWISE, it is an IMPERATIVE push.
            // We want to delegate this to the coordinator to keep the path in sync.
            print("🔄 [Swizzling] Delegating imperative push of \(id.name) to Coordinator")
            
            // Allow the push to happen natively
            self.navx_pushViewController(viewController, animated: animated)
            
            // Update the path to reflect this change
            Task { @MainActor in
                print("➕ [Swizzling] Updating path with imperative push: \(id.name)")
                // Check again to make sure we aren't adding it if it appeared via sync race condition
                if coordinator.path.last != id {
                     coordinator.path.append(id)
                } else {
                    print("⚠️ [Swizzling] Skipped appending \(id.name) - already last in path")
                }
            }
            
        } else {
            // Not managed, standard behavior
            print("⚪️ [Swizzling] Standard push (unmanaged)")
            self.navx_pushViewController(viewController, animated: animated)
        }
    }
    
    @objc func navx_popViewController(animated: Bool) -> UIViewController? {
        if let coordinator = self.coordinator {
             print("🕵️ [Swizzling] Intercepted pop on managed NC")
             
             // Check if this pop is initiated by Coordinator sync?
             // Sync pop uses `setViewControllers`.
             // Manual pop uses `popViewController`.
             
             // Execute pop
             let popped = self.navx_popViewController(animated: animated)
             
             // Update path
             if let poppedVC = popped {
                 Task { @MainActor in
                     print("➖ [Swizzling] Updating path after pop")
                     // We should remove the LAST item from path if it matches
                     // Or just sync path to current stack count?
                     // Safer to sync to stack.
                     // But we are in a Task, stack might have changed?
                     // Let's just removeLast if it matches popped ID?
                     // Or simply `coordinator.pop()`?
                     
                     coordinator.pop() 
                 }
             }
             return popped
        } else {
            return self.navx_popViewController(animated: animated)
        }
    }
    
    // Helper to find coordinator
    // We attached it in `makeUIViewController`
    // var coordinator: NavigationCoordinator? { ... } <-- REMOVED (inherited from UIViewController)
}
