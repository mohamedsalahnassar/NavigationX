import SwiftUI

public struct NavDestinationModifier: ViewModifier {
    let name: String
    let destination: (ScreenIdentifier) -> AnyView
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                coordinator.registerDestination(name: name, builder: destination)
            }
    }
}

public extension View {
    /// Registers a destination for a specific screen name.
    /// - Parameters:
    ///   - name: The name of the screen (matches ScreenIdentifier.name)
    ///   - destination: A closure building the view for the identifier
    func navDestination<D: View>(name: String, @ViewBuilder destination: @escaping (ScreenIdentifier) -> D) -> some View {
        modifier(NavDestinationModifier(name: name, destination: { id in
            AnyView(destination(id))
        }))
    }
}
