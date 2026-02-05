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
public struct NavigationStackX<Data, Root: View>: View {
    @State private var navigationController: UINavigationController?
    private let internalStack: AnyView
    
    // MARK: - Initializers
    
    /// Creates a navigation stack that manages its own navigation state.
    /// - Parameter root: The view to display in the stack.
    @MainActor @preconcurrency
    public init(@ViewBuilder root: () -> Root) where Data == NavigationPath {
        self.internalStack = AnyView(NavigationStack(root: root))
    }
    
    /// Creates a navigation stack that binds to a navigation path.
    /// - Parameters:
    ///   - path: A binding to the navigation state for this stack.
    ///   - root: The view to display in the stack.
    @MainActor @preconcurrency
    public init(path: Binding<NavigationPath>, @ViewBuilder root: () -> Root) where Data == NavigationPath {
        self.internalStack = AnyView(NavigationStack(path: path, root: root))
    }
    
    /// Creates a navigation stack that binds to a collection of data.
    /// - Parameters:
    ///   - path: A binding to the navigation state for this stack.
    ///   - root: The view to display in the stack.
    @MainActor @preconcurrency
    public init(path: Binding<Data>, @ViewBuilder root: () -> Root) where Data : MutableCollection, Data : RandomAccessCollection, Data : RangeReplaceableCollection, Data.Element : Hashable {
        self.internalStack = AnyView(NavigationStack(path: path, root: root))
    }
    
    // MARK: - Body
    
    public var body: some View {
        internalStack
            .environment(\.uiNavigationController, navigationController)
            .navigationIntrospect { nc in
                if self.navigationController !== nc {
                    self.navigationController = nc
                    // print("⚓️ [NavigationX] Captured NC")
                }
            }
    }
}

