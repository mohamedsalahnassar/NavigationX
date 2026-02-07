import SwiftUI
import NavigationX

// MARK: - Profile Screen

/// SwiftUI profile screen with a purple gradient theme.
struct ProfileScreen: View {
    @Environment(\.uiNavigationController) var nc
    
    var body: some View {
        BaseNavigableView(config: .profile) {
            NavigationActionsView(
                swiftUIOptions: [
                    ("Settings", "gearshape.fill", { SettingsScreen() }),
                    ("Home", "house.fill", { HomeScreen() })
                ],
                uiKitOptions: [
                    ("Account", "creditcard.fill", { AccountVC() }),
                    ("Dashboard", "chart.bar.fill", { DashboardVC() })
                ]
            )
            
            // Profile Card
            VStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                
                Text("John Appleseed")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("iOS Developer")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                // Stats Row
                HStack(spacing: 40) {
                    StatView(value: "142", label: "Commits")
                    StatView(value: "38", label: "PRs")
                    StatView(value: "12", label: "Projects")
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

struct StatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#Preview {
    NavigationStackX {
        ProfileScreen()
    }
}
