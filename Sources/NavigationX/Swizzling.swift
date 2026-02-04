import UIKit

// MARK: - Swizzling Setup

/// One-time swizzling setup for UINavigationController
@MainActor
public enum NavigationXSwizzling {
    
    nonisolated(unsafe) private static var isSwizzled = false
    
    /// Call this once at app startup to enable navigation interception
    public static func install() {
        guard !isSwizzled else {
            print("⚙️ [Swizzling] Already installed, skipping")
            return
        }
        isSwizzled = true
        print("⚙️ [Swizzling] Installing swizzling...")
        
        swizzlePush()
        swizzlePop()
        swizzlePopToVC()
        swizzlePopToRoot()
        
        print("⚙️ [Swizzling] ✅ Swizzling installed successfully")
    }
    
    private static func swizzlePush() {
        let originalSelector = #selector(UINavigationController.pushViewController(_:animated:))
        let swizzledSelector = #selector(UINavigationController.bridge_pushViewController(_:animated:))
        
        guard let originalMethod = class_getInstanceMethod(UINavigationController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UINavigationController.self, swizzledSelector) else {
            print("🔴 [Swizzling] Failed to get push methods")
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
        print("⚙️ [Swizzling] pushViewController swizzled")
    }
    
    private static func swizzlePop() {
        let originalSelector = #selector(UINavigationController.popViewController(animated:))
        let swizzledSelector = #selector(UINavigationController.bridge_popViewController(animated:))
        
        guard let originalMethod = class_getInstanceMethod(UINavigationController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UINavigationController.self, swizzledSelector) else {
            print("🔴 [Swizzling] Failed to get pop methods")
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
        print("⚙️ [Swizzling] popViewController swizzled")
    }
    
    private static func swizzlePopToVC() {
        let originalSelector = #selector(UINavigationController.popToViewController(_:animated:))
        let swizzledSelector = #selector(UINavigationController.bridge_popToViewController(_:animated:))
        
        guard let originalMethod = class_getInstanceMethod(UINavigationController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UINavigationController.self, swizzledSelector) else {
            print("🔴 [Swizzling] Failed to get popToVC methods")
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
        print("⚙️ [Swizzling] popToViewController swizzled")
    }
    
    private static func swizzlePopToRoot() {
        let originalSelector = #selector(UINavigationController.popToRootViewController(animated:))
        let swizzledSelector = #selector(UINavigationController.bridge_popToRootViewController(animated:))
        
        guard let originalMethod = class_getInstanceMethod(UINavigationController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UINavigationController.self, swizzledSelector) else {
            print("🔴 [Swizzling] Failed to get popToRoot methods")
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
        print("⚙️ [Swizzling] popToRootViewController swizzled")
    }
}

// MARK: - Swizzled Methods

extension UINavigationController {
    
    @objc func bridge_pushViewController(_ viewController: UIViewController, animated: Bool) {
        print("📍 [Swizzled] pushViewController - VC: \(type(of: viewController)), animated: \(animated)")
        let state = self.bridgeState
        
        if state.isActive {
            state.delegate?.navigationController(self, willPush: viewController, animated: animated)
        }
        
        // Call original (which is now swizzled to this selector)
        bridge_pushViewController(viewController, animated: animated)
        
        if state.isActive {
            state.delegate?.navigationController(self, didPush: viewController, animated: animated)
        }
        print("📍 [Swizzled] pushViewController complete - stack depth: \(viewControllers.count)")
    }
    
    @objc func bridge_popViewController(animated: Bool) -> UIViewController? {
        print("📍 [Swizzled] popViewController - animated: \(animated)")
        let state = self.bridgeState
        let topVC = self.topViewController
        
        if state.isActive, let topVC {
            state.delegate?.navigationController(self, willPop: [topVC], animated: animated)
        }
        
        let result = bridge_popViewController(animated: animated)
        
        if state.isActive, let topVC {
            state.delegate?.navigationController(self, didPop: [topVC], animated: animated)
        }
        
        print("📍 [Swizzled] popViewController complete - popped: \(String(describing: result)), stack depth: \(viewControllers.count)")
        return result
    }
    
    @objc func bridge_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        print("📍 [Swizzled] popToViewController - target: \(type(of: viewController)), animated: \(animated)")
        let state = self.bridgeState
        let currentStack = self.viewControllers
        let poppedVCs = currentStack.drop(while: { $0 !== viewController }).dropFirst()
        
        if state.isActive, !poppedVCs.isEmpty {
            state.delegate?.navigationController(self, willPop: Array(poppedVCs), animated: animated)
        }
        
        let result = bridge_popToViewController(viewController, animated: animated)
        
        if state.isActive, !poppedVCs.isEmpty {
            state.delegate?.navigationController(self, didPop: Array(poppedVCs), animated: animated)
        }
        
        print("📍 [Swizzled] popToViewController complete - popped count: \(result?.count ?? 0)")
        return result
    }
    
    @objc func bridge_popToRootViewController(animated: Bool) -> [UIViewController]? {
        print("📍 [Swizzled] popToRootViewController - animated: \(animated)")
        let state = self.bridgeState
        let poppedVCs = Array(self.viewControllers.dropFirst())
        
        if state.isActive, !poppedVCs.isEmpty {
            state.delegate?.navigationController(self, willPop: poppedVCs, animated: animated)
        }
        
        let result = bridge_popToRootViewController(animated: animated)
        
        if state.isActive, !poppedVCs.isEmpty {
            state.delegate?.navigationController(self, didPop: poppedVCs, animated: animated)
        }
        
        print("📍 [Swizzled] popToRootViewController complete - popped count: \(result?.count ?? 0)")
        return result
    }
}
