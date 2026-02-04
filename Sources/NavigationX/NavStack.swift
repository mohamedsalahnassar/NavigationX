import SwiftUI
import Combine

public struct NavStack<Root: View>: View {
    @StateObject private var coordinator = NavigationCoordinator()
    private let root: Root
    
    public init(@ViewBuilder root: () -> Root) {
        self.root = root()
    }
    
    public var body: some View {
        NavigationControllerHost(rootView: root, coordinator: coordinator)
            .environmentObject(coordinator)
            .edgesIgnoringSafeArea(.all)
    }
}

// Internal Host
struct NavigationControllerHost<Root: View>: UIViewControllerRepresentable {
    let rootView: Root
    let coordinator: NavigationCoordinator
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let rootHost = NavigationXHostingController(rootView: rootView.environmentObject(coordinator))
        rootHost.screenIdentifier = ScreenIdentifier(name: "ROOT", id: UUID().uuidString)
        rootHost.coordinator = coordinator
        
        let nc = UINavigationController(rootViewController: rootHost)
        nc.delegate = context.coordinator
        
        // Link coordinator
        coordinator.navigationController = nc
        
        print("🏛️ [NavStack] Created managed UINavigationController: \(nc)")
        return nc
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Trigger sync safely when SwiftUI state changes
        // This is crucial for reactive updates if needed, though mostly Coordinator drives it.
        // We defer to main actor to avoid view update cycle issues.
        Task { @MainActor in
            coordinator.sync()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate {
        let parent: NavigationControllerHost
        
        init(parent: NavigationControllerHost) {
            self.parent = parent
        }
        
        func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
            // Sync Path to Stack (Handle Native Swipe Back)
            let stackCount = navigationController.viewControllers.count
            let pathCount = parent.coordinator.path.count
            
            // Expected: Stack = Path + 1 (Root)
            if stackCount < (pathCount + 1) {
                print("🔙 [NCDelegate] Detected native pop. Adjusting path.")
                let newPathCount = max(0, stackCount - 1)
                
                // Avoid Sync Loop by dispatching
                DispatchQueue.main.async {
                    if self.parent.coordinator.path.count > newPathCount {
                        self.parent.coordinator.path = Array(self.parent.coordinator.path.prefix(newPathCount))
                        // Also trigger update? path change triggers sync via updateUIViewController?
                        // Yes, via StateObject change -> Body -> updateUIViewController -> sync.
                    }
                }
            }
        }
    }
}

