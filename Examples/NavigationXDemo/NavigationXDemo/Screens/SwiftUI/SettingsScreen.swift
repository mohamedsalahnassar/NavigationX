import SwiftUI
import NavigationX

// MARK: - Settings Screen

/// SwiftUI settings screen with a green gradient theme.
struct SettingsScreen: View {
    @Environment(\.uiNavigationController) var nc
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var hapticFeedback = true
    
    var body: some View {
        BaseNavigableView(config: .settings) {
            NavigationActionsView(
                swiftUIOptions: [
                    ("Profile", "person.fill", { ProfileScreen() }),
                    ("Home", "house.fill", { HomeScreen() })
                ],
                uiKitOptions: [
                    ("Account", "creditcard.fill", { AccountVC() }),
                    ("Messages", "bubble.left.fill", { MessagesVC() })
                ]
            )
            
            // Settings List
            VStack(spacing: 0) {
                SettingsToggleRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    isOn: $notificationsEnabled
                )
                
                Divider().background(Color.white.opacity(0.2))
                
                SettingsToggleRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    isOn: $darkModeEnabled
                )
                
                Divider().background(Color.white.opacity(0.2))
                
                SettingsToggleRow(
                    icon: "hand.tap.fill",
                    title: "Haptic Feedback",
                    isOn: $hapticFeedback
                )
            }
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Info Card
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("This demo showcases seamless navigation between SwiftUI Views and UIKit ViewControllers using NavigationX.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 32)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.white)
        }
        .padding()
    }
}

#Preview {
    NavigationStackX {
        SettingsScreen()
    }
}
