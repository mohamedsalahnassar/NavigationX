import SwiftUI
import UIKit

// MARK: - Navigator

/// A modern, observable navigation helper that wraps `UINavigationController`.
///
/// `Navigator` provides a clean, SwiftUI-friendly API for programmatic navigation
/// with full Swift Concurrency support.
///
/// **Usage:**
/// ```swift
/// struct MyView: View {
///     @Environment(\.navigator) var navigator
///
///     var body: some View {
///         Button("Push") {
///             navigator?.push(DetailView())
///         }
///     }
/// }
/// ```
@available(iOS 17.0, *)
@Observable
@MainActor
public final class Navigator: Sendable {
    
    // MARK: - Properties
    
    /// The underlying UINavigationController.
    public private(set) weak var navigationController: UINavigationController?
    
    /// The current number of view controllers in the navigation stack.
    public var stackDepth: Int {
        navigationController?.viewControllers.count ?? 0
    }
    
    /// Whether there are view controllers to pop (stack depth > 1).
    public var canPop: Bool {
        stackDepth > 1
    }
    
    /// The view controllers currently in the navigation stack.
    public var viewControllers: [UIViewController] {
        navigationController?.viewControllers ?? []
    }
    
    // MARK: - Initialization
    
    /// Creates a new Navigator instance.
    public init() {}
    
    /// Creates a Navigator bound to a specific navigation controller.
    public init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    // MARK: - Binding
    
    /// Binds this Navigator to a UINavigationController.
    public func bind(to navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    // MARK: - Push Operations
    
    /// Pushes a SwiftUI view onto the navigation stack.
    /// - Parameters:
    ///   - view: The SwiftUI view to push.
    ///   - title: Optional navigation title.
    ///   - animated: Whether to animate the transition (default: true).
    public func push<V: View>(_ view: V, title: String? = nil, animated: Bool = true) {
        navigationController?.push(view: view, title: title, animated: animated)
    }
    
    /// Pushes a SwiftUI view and waits for the animation to complete.
    /// - Parameters:
    ///   - view: The SwiftUI view to push.
    ///   - title: Optional navigation title.
    ///   - animated: Whether to animate the transition.
    public func pushAsync<V: View>(_ view: V, title: String? = nil, animated: Bool = true) async {
        await navigationController?.pushAsync(view: view, title: title, animated: animated)
    }
    
    /// Pushes a UIViewController onto the navigation stack.
    /// - Parameters:
    ///   - viewController: The view controller to push.
    ///   - animated: Whether to animate the transition.
    public func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// Pushes a UIViewController and waits for the animation to complete.
    public func pushAsync(_ viewController: UIViewController, animated: Bool = true) async {
        await navigationController?.pushViewControllerAsync(viewController, animated: animated)
    }
    
    // MARK: - Pop Operations
    
    /// Pops the top view controller from the navigation stack.
    /// - Parameter animated: Whether to animate the transition.
    /// - Returns: The popped view controller, or nil if pop failed.
    @discardableResult
    public func pop(animated: Bool = true) -> UIViewController? {
        navigationController?.popViewController(animated: animated)
    }
    
    /// Pops the top view controller and waits for the animation to complete.
    /// - Parameter animated: Whether to animate the transition.
    /// - Returns: The popped view controller, or nil if pop failed.
    @discardableResult
    public func popAsync(animated: Bool = true) async -> UIViewController? {
        await navigationController?.popViewControllerAsync(animated: animated)
    }
    
    /// Pops to the root view controller.
    /// - Parameter animated: Whether to animate the transition.
    /// - Returns: The array of popped view controllers.
    @discardableResult
    public func popToRoot(animated: Bool = true) -> [UIViewController]? {
        navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Pops to the root view controller and waits for the animation to complete.
    /// - Parameter animated: Whether to animate the transition.
    /// - Returns: The array of popped view controllers.
    @discardableResult
    public func popToRootAsync(animated: Bool = true) async -> [UIViewController]? {
        await navigationController?.popToRootViewControllerAsync(animated: animated)
    }
    
    /// Pops to a specific SwiftUI view type in the stack.
    /// - Parameters:
    ///   - viewType: The type of SwiftUI view to pop to.
    ///   - animated: Whether to animate the transition.
    /// - Returns: The array of popped view controllers, or nil if the view type was not found.
    @discardableResult
    public func popTo<V: View>(_ viewType: V.Type, animated: Bool = true) -> [UIViewController]? {
        navigationController?.popTo(viewType: viewType, animated: animated)
    }
    
    /// Pops to a specific SwiftUI view type and waits for the animation to complete.
    /// - Parameters:
    ///   - viewType: The type of SwiftUI view to pop to.
    ///   - animated: Whether to animate the transition.
    /// - Returns: True if the view was found and popped to, false otherwise.
    @discardableResult
    public func popToAsync<V: View>(_ viewType: V.Type, animated: Bool = true) async -> Bool {
        await navigationController?.popToAsync(viewType: viewType, animated: animated) ?? false
    }
    
    // MARK: - Query Operations
    
    /// Checks if a SwiftUI view of a specific type exists in the stack.
    public func contains<V: View>(_ viewType: V.Type) -> Bool {
        navigationController?.contains(viewType: viewType) ?? false
    }
}

// MARK: - Environment Key

@available(iOS 17.0, *)
private struct NavigatorKey: EnvironmentKey {
    static let defaultValue: Navigator? = nil
}

@available(iOS 17.0, *)
public extension EnvironmentValues {
    /// Access the Navigator for programmatic navigation.
    var navigator: Navigator? {
        get { self[NavigatorKey.self] }
        set { self[NavigatorKey.self] = newValue }
    }
}

