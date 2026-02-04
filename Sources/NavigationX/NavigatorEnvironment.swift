import SwiftUI

// MARK: - Navigator Environment Key

private struct NavigatorKey: EnvironmentKey {
    static let defaultValue: Navigator? = nil
}

public extension EnvironmentValues {
    /// Access the Navigator for the current navigation stack
    var navigator: Navigator? {
        get { self[NavigatorKey.self] }
        set { self[NavigatorKey.self] = newValue }
    }
}

// MARK: - View Extension

public extension View {
    /// Provides a navigator to child views through the environment
    func navigator(_ navigator: Navigator) -> some View {
        environment(\.navigator, navigator)
    }
}
