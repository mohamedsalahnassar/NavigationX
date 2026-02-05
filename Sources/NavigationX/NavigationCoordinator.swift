import SwiftUI
import Combine

/// Coordiator managing the navigation state and synchronization
@MainActor
public class NavigationCoordinator: ObservableObject {
    
    /// The source of truth for the navigation path
    @Published public var path: [ScreenIdentifier] = []
    
    /// Trigger for UI updates after sync (e.g. for Inspector)
    @Published public var lastSyncId: UUID = UUID()
    
    /// The underlying UINavigationController
    public weak var navigationController: UINavigationController?
    
    /// Registry of destination builders (Name -> Builder)
    /// We use a dictionary where key is the `name` of the screen.
    private var destinations: [String: (ScreenIdentifier) -> AnyView] = [:]
    
    public init() {}
    
    // MARK: - Registry
    
    /// Register a destination builder for a specific screen name
    public func registerDestination(name: String, builder: @escaping (ScreenIdentifier) -> AnyView) {
        destinations[name] = builder
        // If we were waiting for this destination during a sync, we might want to trigger a check
        // For now, simpler to just let the sync loop handle re-checks if we implement retry logic
        print("🗺️ [Coordinator] Registered destination for '\(name)'")
    }
    
    public func resolve(identifier: ScreenIdentifier) -> AnyView? {
        if let builder = destinations[identifier.name] {
            return builder(identifier)
        }
        return nil
    }
    
    // MARK: - Navigation Actions
    
    public func push(_ identifier: ScreenIdentifier, triggeredBy: String? = nil) {
        let currentIndex = path.count
        let triggerInfo = triggeredBy != nil ? " [Trigger: \(triggeredBy!)]" : ""
        print("🚀 [Coordinator] Request push: \(identifier.name) (ID: \(identifier.id)) [Index: \(currentIndex + 1)]\(triggerInfo)")
        path.append(identifier)
    }
    
    public func pop(triggeredBy: String? = nil) {
        let currentIndex = path.count
        let triggerInfo = triggeredBy != nil ? " [Trigger: \(triggeredBy!)]" : ""
        print("🔙 [Coordinator] Request pop [From Index: \(currentIndex)]\(triggerInfo)")
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    public func popToRoot(triggeredBy: String? = nil) {
        let currentIndex = path.count
        let triggerInfo = triggeredBy != nil ? " [Trigger: \(triggeredBy!)]" : ""
        print("⏮️ [Coordinator] Request pop to root [From Index: \(currentIndex)]\(triggerInfo)")
        path.removeAll()
    }
    
    public func pop(to identifier: ScreenIdentifier, triggeredBy: String? = nil) {
        let triggerInfo = triggeredBy != nil ? " [Trigger: \(triggeredBy!)]" : ""
        print("🔙 [Coordinator] Pop to \(identifier.name)\(triggerInfo)")
        if let index = path.firstIndex(of: identifier) {
            path = Array(path.prefix(upTo: index + 1))
        }
    }
    
    // MARK: - Internal Sync Logic
    
    public func sync() {
        // With NavigationStack(path:), SwiftUI manages the stack.
        // We just verify or log debug info here.
        
        guard let navigationController else { return }
        let stackCount = navigationController.viewControllers.count
        let pathCount = path.count
        print("🔄 [Coordinator] Stack Check: Path=\(pathCount), UIKit=\(stackCount)")
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(10))
            lastSyncId = UUID()
        }
    }
}

// MARK: - VC Tagging
nonisolated(unsafe) var screenIdentifierKey: UInt8 = 0
nonisolated(unsafe) var coordinatorKey: UInt8 = 0

public extension UIViewController {
    var screenIdentifier: ScreenIdentifier? {
        get { objc_getAssociatedObject(self, &screenIdentifierKey) as? ScreenIdentifier }
        set { objc_setAssociatedObject(self, &screenIdentifierKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var coordinator: NavigationCoordinator? {
         get { objc_getAssociatedObject(self, &coordinatorKey) as? NavigationCoordinator }
        set { objc_setAssociatedObject(self, &coordinatorKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }       
    }
}

// Custom Hosting Controller to inject environment
class NavigationXHostingController<Content: View>: UIHostingController<Content> {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure environment is set? UIHostingController does this via rootView usually.
    }
}
