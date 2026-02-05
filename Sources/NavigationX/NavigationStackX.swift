import SwiftUI
import UIKit
import NavigationIntrospect

// MARK: - Environment Key

private struct NavigationControllerKey: EnvironmentKey {
    static let defaultValue: UINavigationController? = nil
}

public extension EnvironmentValues {
    /// Access the underlying UINavigationController if available.
    var uiNavigationController: UINavigationController? {
        get { self[NavigationControllerKey.self] }
        set { self[NavigationControllerKey.self] = newValue }
    }
}

// MARK: - NavigationStackX

/// A lightweight wrapper around `NavigationStack` that exposes the underlying `UINavigationController`.
///
/// Use `NavigationStackX` to enable hybrid navigation scenarios where you need direct access
/// to the UIKit navigation controller from within your SwiftUI views.
///
/// **Usage:**
/// ```swift
/// NavigationStackX {
///     MyView()
/// }
/// ```
///
/// **Accessing the Navigation Controller:**
/// Inside your view:
/// ```swift
/// @Environment(\.uiNavigationController) var nc
/// ```
public struct NavigationStackX<Root: View>: View {
    private let root: Root
    @State private var navigationController: UINavigationController?
    
    public init(@ViewBuilder root: () -> Root) {
        self.root = root()
    }
    
    public var body: some View {
        NavigationStack {
            root
                .environment(\.uiNavigationController, navigationController)
                .navigationIntrospect { nc in
                    if self.navigationController !== nc {
                        self.navigationController = nc
                        // print("⚓️ [NavigationX] Captured NC")
                    }
                }
        }
    }
}

// MARK: - Helper View Modifier

public extension View {
    /// A convenience modifier to access the navigation controller in a closure style.
    /// Usage:
    /// ```
    /// Button("Push") { ... }
    /// .useNavigationController { nc in
    ///     nc.pushViewController(...)
    /// }
    /// ```
    /// Note: This is less efficient than @Environment but useful for one-offs. 
    /// Actually, a closure-based modifier is tricky because the action needs to happen inside the closure.
    /// Better to just expose the Environment value.
}
