import SwiftUI
import NavigationX

// MARK: - Home Screen

/// The root SwiftUI screen with a teal gradient theme.
struct HomeScreen: View {
    @Environment(\.uiNavigationController) var nc
    
    var body: some View {
        BaseNavigableView(config: .home) {
            NavigationActionsView(
                swiftUIOptions: [
                    ("Profile", "person.fill", { ProfileScreen() }),
                    ("Settings", "gearshape.fill", { SettingsScreen() })
                ],
                uiKitOptions: [
                    ("Dashboard", "chart.bar.fill", { DashboardVC() }),
                    ("Messages", "bubble.left.fill", { MessagesVC() })
                ]
            )
            
            // Welcome message
            VStack(spacing: 12) {
                Text("🎉 Welcome to NavigationX Demo")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Navigate between SwiftUI and UIKit screens seamlessly. Watch the stack inspector update in real-time!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    NavigationStackX {
        HomeScreen()
    }
}
