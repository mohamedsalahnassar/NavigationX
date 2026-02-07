import SwiftUI
import NavigationX

// MARK: - Screen Configuration

struct ScreenConfig {
    let title: String
    let subtitle: String
    let primaryColor: Color
    let gradientColors: [Color]
    let iconName: String
    
    static let home = ScreenConfig(
        title: "Home",
        subtitle: "Welcome back",
        primaryColor: Color(hex: "3B82F6"),
        gradientColors: [Color(hex: "1E40AF"), Color(hex: "3B82F6"), Color(hex: "60A5FA")],
        iconName: "house.fill"
    )
    
    static let profile = ScreenConfig(
        title: "Profile",
        subtitle: "Your account",
        primaryColor: Color(hex: "8B5CF6"),
        gradientColors: [Color(hex: "5B21B6"), Color(hex: "8B5CF6"), Color(hex: "A78BFA")],
        iconName: "person.fill"
    )
    
    static let settings = ScreenConfig(
        title: "Settings",
        subtitle: "Preferences",
        primaryColor: Color(hex: "F97316"),
        gradientColors: [Color(hex: "C2410C"), Color(hex: "F97316"), Color(hex: "FB923C")],
        iconName: "gearshape.fill"
    )
    
    static let search = ScreenConfig(
        title: "Search",
        subtitle: "Find anything",
        primaryColor: Color(hex: "10B981"),
        gradientColors: [Color(hex: "047857"), Color(hex: "10B981"), Color(hex: "34D399")],
        iconName: "magnifyingglass"
    )
}

// MARK: - Base SwiftUI Screen

struct BaseSwiftUIScreen: View {
    @Environment(\.uiNavigationController) private var navigationController
    
    let config: ScreenConfig
    let screenIndex: Int
    
    var body: some View {
        ZStack {
            // Rich gradient background
            LinearGradient(
                colors: config.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Decorative circles
            GeometryReader { geo in
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: 300, height: 300)
                    .offset(x: geo.size.width * 0.6, y: -50)
                
                Circle()
                    .fill(.white.opacity(0.03))
                    .frame(width: 200, height: 200)
                    .offset(x: -50, y: geo.size.height * 0.7)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Hero section
                    heroSection
                    
                    // Main content cards
                    VStack(spacing: 16) {
                        navigationCard
                        stackInspectorCard
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle(config.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                navigationMenu
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            // Platform badge
            HStack(spacing: 6) {
                Image(systemName: "swift")
                    .font(.system(size: 12, weight: .bold))
                Text("SwiftUI")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.white.opacity(0.2))
                    .overlay(
                        Capsule()
                            .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Icon
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: config.iconName)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            // Title & subtitle
            VStack(spacing: 4) {
                Text(config.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Stack Inspector Card
    
    private var stackInspectorCard: some View {
        StackInspectorView(navigationController: navigationController)
    }
    
    // MARK: - Navigation Card
    
    private var navigationCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Navigate")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Choose your next destination")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }
            
            // SwiftUI Section
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader(title: "SwiftUI Views", icon: "swift", color: Color(hex: "FF6B35"))
                
                NavigationTile(title: "Home", icon: "house.fill", color: Color(hex: "3B82F6")) {
                    pushSwiftUIScreen(.home)
                }
                NavigationTile(title: "Profile", icon: "person.fill", color: Color(hex: "8B5CF6")) {
                    pushSwiftUIScreen(.profile)
                }
                NavigationTile(title: "Settings", icon: "gearshape.fill", color: Color(hex: "F97316")) {
                    pushSwiftUIScreen(.settings)
                }
                NavigationTile(title: "Search", icon: "magnifyingglass", color: Color(hex: "10B981")) {
                    pushSwiftUIScreen(.search)
                }
            }
            
            Divider()
                .background(.white.opacity(0.2))
            
            // UIKit Section
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader(title: "UIKit Controllers", icon: "apple.logo", color: .white)
                
                NavigationTile(title: "Dashboard", icon: "chart.bar.fill", color: Color(hex: "14B8A6")) {
                    pushUIKitScreen(.dashboard)
                }
                NavigationTile(title: "Detail", icon: "doc.text.fill", color: Color(hex: "EC4899")) {
                    pushUIKitScreen(.detail)
                }
                NavigationTile(title: "Form", icon: "square.and.pencil", color: Color(hex: "6366F1")) {
                    pushUIKitScreen(.form)
                }
                NavigationTile(title: "List", icon: "list.bullet", color: Color(hex: "F59E0B")) {
                    pushUIKitScreen(.list)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        )
    }
    
    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.15), in: Capsule())
    }
    
    // MARK: - Navigation Menu
    
    private var navigationMenu: some View {
        Menu {
            Section("SwiftUI Screens") {
                Button(action: { pushSwiftUIScreen(.home) }) {
                    Label("Home", systemImage: "house.fill")
                }
                Button(action: { pushSwiftUIScreen(.profile) }) {
                    Label("Profile", systemImage: "person.fill")
                }
                Button(action: { pushSwiftUIScreen(.settings) }) {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                Button(action: { pushSwiftUIScreen(.search) }) {
                    Label("Search", systemImage: "magnifyingglass")
                }
            }
            
            Section("UIKit Screens") {
                Button(action: { pushUIKitScreen(.dashboard) }) {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                Button(action: { pushUIKitScreen(.detail) }) {
                    Label("Detail", systemImage: "doc.text.fill")
                }
                Button(action: { pushUIKitScreen(.form) }) {
                    Label("Form", systemImage: "square.and.pencil")
                }
                Button(action: { pushUIKitScreen(.list) }) {
                    Label("List", systemImage: "list.bullet")
                }
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
        }
    }
    
    // MARK: - Navigation Actions
    
    private func pushSwiftUIScreen(_ config: ScreenConfig) {
        guard let nc = navigationController else { return }
        let nextIndex = nc.viewControllers.count
        let screen = BaseSwiftUIScreen(config: config, screenIndex: nextIndex)
        nc.push(view: screen, title: config.title)
    }
    
    private func pushUIKitScreen(_ config: VCConfig) {
        guard let nc = navigationController else { return }
        let vc = BaseViewController(config: config)
        nc.pushViewController(vc, animated: true)
    }
}

// MARK: - Navigation Tile

struct NavigationTile: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.gradient)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                // Title
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Convenience Screen Views

struct HomeSwiftUIScreen: View {
    var body: some View {
        BaseSwiftUIScreen(config: .home, screenIndex: 0)
    }
}

struct ProfileSwiftUIScreen: View {
    var body: some View {
        BaseSwiftUIScreen(config: .profile, screenIndex: 0)
    }
}

struct SettingsSwiftUIScreen: View {
    var body: some View {
        BaseSwiftUIScreen(config: .settings, screenIndex: 0)
    }
}

struct SearchSwiftUIScreen: View {
    var body: some View {
        BaseSwiftUIScreen(config: .search, screenIndex: 0)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
