import SwiftUI
import NavigationIntrospect
import Combine

public struct NavStack<Root: View>: View {
    @StateObject private var coordinator = NavigationCoordinator()
    private let root: Root
    
    public init(@ViewBuilder root: () -> Root) {
        self.root = root()
    }
    
    // We use a State to hold the NC to avoid multiple introspection callbacks resetting it?
    // Actually coordinator.navigationController is weak.
    
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            root
                .navigationDestination(for: ScreenIdentifier.self) { identifier in
                    // Transform ScreenIdentifier to View
                    coordinator.resolve(identifier: identifier)
                        .environmentObject(coordinator)
                }
                .environmentObject(coordinator)
                .navigationIntrospect { nc in
                    print("🔬 [NavStack] Introspected NC: \(nc)")
                    if coordinator.navigationController != nc {
                        coordinator.navigationController = nc
                        nc.screenIdentifier = ScreenIdentifier(name: "ROOT_NC", id: "ROOT")
                    }
                }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

