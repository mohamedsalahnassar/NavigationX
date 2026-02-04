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
        guard let navigationController else {
            print("❌ [Coordinator] Sync failed: No NavigationController attached.")
            return
        }
        
        let currentStack = navigationController.viewControllers
        let pathCount = path.count
        
        print("🔄 [Coordinator] Syncing. Path: \(pathCount), Stack: \(currentStack.count)")
        
        // 1. Tag Matching
        var matchCount = 0
        // Stack[0] is Root. path[0] is 1st pushed item.
        // Stack[1] should correspond to path[0].
        
        let maxMatch = min(pathCount, currentStack.count - 1)
        
        for i in 0..<maxMatch {
            let vc = currentStack[i + 1]
            let item = path[i]
            if let tag = vc.screenIdentifier, tag == item {
                // print("   [Index \(i+1)] Matched \(item.name)")
                matchCount += 1
            } else {
                print("⚠️ [Coordinator] Mismatch at path index \(i + 1). Path: \(item.name), Stack: \(vc.screenIdentifier?.name ?? "nil")")
                break
            }
        }
        
        print("✅ [Coordinator] Matched items: \(matchCount) / \(pathCount)")
        
        // 2. Pop
        if matchCount < (currentStack.count - 1) {
            print("✂️ [Coordinator] Popping from \(currentStack.count) to \(matchCount + 1)")
            let targetStack = Array(currentStack.prefix(1 + matchCount))
            navigationController.setViewControllers(targetStack, animated: true)
        }
        
        // 3. Push
        if matchCount < pathCount {
            var newVCs: [UIViewController] = []
            
            for i in matchCount..<pathCount {
                let item = path[i]
                
                if let view = resolve(identifier: item) {
                    print("🔨 [Coordinator] Building view for \(item.name)")
                    // Inject the coordinator into the environment of the new view
                    let host = NavigationXHostingController(rootView: AnyView(view.environmentObject(self)))
                    host.screenIdentifier = item
                    host.coordinator = self
                    newVCs.append(host)
                } else {
                    print("🚦 [Coordinator] Waiting for destination: \(item.name)")
                    break
                }
            }
            
            if !newVCs.isEmpty {
                print("🚀 [Coordinator] Pushing \(newVCs.count) new VCs")
                if newVCs.count == 1, let vc = newVCs.first {
                     print("👉 [Coordinator] Single push")
                     navigationController.pushViewController(vc, animated: true)
                } else {
                    print("📦 [Coordinator] Bulk push/set")
                    var finalStack = navigationController.viewControllers
                    finalStack.append(contentsOf: newVCs)
                }
            }
        }
        
        // Force view updates for inspectors observing the coordinator
        lastSyncId = UUID()
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
