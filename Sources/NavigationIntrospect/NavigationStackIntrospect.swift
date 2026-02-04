import SwiftUI
import UIKit

// MARK: - NavigationStack Introspection

extension View {
    /// Introspects the underlying UINavigationController of a NavigationStack
    @MainActor
    public func introspectNavigationController(
        customize: @escaping @MainActor (UINavigationController) -> Void
    ) -> some View {
        self.modifier(NavigationControllerIntrospectModifier(customize: customize))
    }
}

// MARK: - Modifier Implementation

struct NavigationControllerIntrospectModifier: ViewModifier {
    let id = IntrospectionViewID()
    let customize: @MainActor (UINavigationController) -> Void
    
    init(customize: @escaping @MainActor (UINavigationController) -> Void) {
        self.customize = customize
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                IntrospectionAnchorView(id: id)
                    .frame(width: 0, height: 0)
                    .accessibility(hidden: true)
            )
            .overlay(
                IntrospectionView(
                    id: id,
                    selector: findNavigationController,
                    customize: customize
                )
                .frame(width: 0, height: 0)
                .accessibility(hidden: true)
            )
    }
    
    /// Finds the UINavigationController by looking for it as a sibling in the VC hierarchy
    @MainActor
    private func findNavigationController(_ controller: IntrospectionPlatformViewController) -> UINavigationController? {
        print("🟡 [Introspect] findNavigationController called for: \(controller)")
        
        // Method 1: Try direct navigationController property
        if let navController = controller.navigationController {
            print("🟡 [Introspect] ✅ Found via .navigationController property: \(navController)")
            return navController
        }
        
        // Method 2: Look for UINavigationController as a sibling (same parent)
        // The UIKitNavigationController is a sibling of our IntrospectionPlatformViewController
        // Both are children of TabHostingController
        if let parent = controller.parent {
            print("🟡 [Introspect] Checking parent's children for UINavigationController...")
            print("🟡 [Introspect] Parent: \(type(of: parent)) with \(parent.children.count) children")
            
            for child in parent.children {
                print("🟡 [Introspect]   Child: \(type(of: child))")
                if let navController = child as? UINavigationController {
                    print("🟡 [Introspect] ✅ Found sibling UINavigationController: \(navController)")
                    return navController
                }
            }
            
            // Try grandparent if immediate parent doesn't have it
            if let grandparent = parent.parent {
                print("🟡 [Introspect] Checking grandparent's children...")
                print("🟡 [Introspect] Grandparent: \(type(of: grandparent)) with \(grandparent.children.count) children")
                
                for child in grandparent.children {
                    if let navController = child as? UINavigationController {
                        print("🟡 [Introspect] ✅ Found UINavigationController in grandparent's children: \(navController)")
                        return navController
                    }
                    // Also check child's children
                    for grandchild in child.children {
                        if let navController = grandchild as? UINavigationController {
                            print("🟡 [Introspect] ✅ Found UINavigationController in grandchild: \(navController)")
                            return navController
                        }
                    }
                }
            }
        }
        
        // Method 3: Traverse the view hierarchy looking for a navigation controller's view
        print("🟡 [Introspect] Searching view hierarchy...")
        if let view = controller.view {
            var currentView: UIView? = view
            while let v = currentView {
                // Check if the view's next responder is a view controller with a nav controller
                if let vc = v.next as? UIViewController {
                    // Check siblings
                    if let parent = vc.parent {
                        for sibling in parent.children {
                            if let navController = sibling as? UINavigationController {
                                print("🟡 [Introspect] ✅ Found via view hierarchy sibling search: \(navController)")
                                return navController
                            }
                        }
                    }
                }
                currentView = v.superview
            }
        }
        
        print("🔴 [Introspect] ❌ Could not find UINavigationController")
        return nil
    }
}
