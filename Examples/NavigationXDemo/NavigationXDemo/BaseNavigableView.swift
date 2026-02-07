import SwiftUI
import NavigationX

// MARK: - Stack Inspector View

/// Displays the current navigation stack with tap-to-pop functionality.
struct StackInspectorView: View {
    @Environment(\.uiNavigationController) var nc
    @State private var stackItems: [StackItem] = []
    
    struct StackItem: Identifiable {
        let id = UUID()
        let index: Int
        let name: String
        let isSwiftUI: Bool
        let viewController: UIViewController
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "square.stack.3d.up.fill")
                    .foregroundColor(AppTheme.StackInspector.headerColor)
                Text("Navigation Stack")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.StackInspector.headerColor)
                Spacer()
                Text("\(stackItems.count) items")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
            }
            
            // Stack Items
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(stackItems.enumerated()), id: \.element.id) { index, item in
                        StackItemButton(
                            item: item,
                            isCurrent: index == stackItems.count - 1
                        ) {
                            popToItem(item)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(AppTheme.StackInspector.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear { refreshStack() }
        .onChange(of: nc?.viewControllers.count) { _ in refreshStack() }
    }
    
    private func refreshStack() {
        guard let viewControllers = nc?.viewControllers else {
            stackItems = []
            return
        }
        
        stackItems = viewControllers.enumerated().map { index, vc in
            let vcType = String(describing: type(of: vc))
            let isHosting = vcType.contains("UIHostingController")
            let displayName = extractDisplayName(from: vcType, vc: vc)
            
            return StackItem(
                index: index,
                name: displayName,
                isSwiftUI: isHosting,
                viewController: vc
            )
        }
    }
    
    private func extractDisplayName(from typeString: String, vc: UIViewController) -> String {
        if let title = vc.title, !title.isEmpty {
            return title
        }
        
        // Extract view name from UIHostingController generic
        if typeString.contains("UIHostingController") {
            let patterns = ["HomeScreen", "ProfileScreen", "SettingsScreen"]
            for pattern in patterns {
                if typeString.contains(pattern) {
                    return pattern.replacingOccurrences(of: "Screen", with: "")
                }
            }
            return "SwiftUI"
        }
        
        // Clean up UIKit VC names
        return typeString
            .replacingOccurrences(of: "ViewController", with: "")
            .replacingOccurrences(of: "VC", with: "")
    }
    
    private func popToItem(_ item: StackItem) {
        guard item.index < (nc?.viewControllers.count ?? 0) - 1 else { return }
        nc?.popToViewController(item.viewController, animated: true)
    }
}

// MARK: - Stack Item Button

struct StackItemButton: View {
    let item: StackInspectorView.StackItem
    let isCurrent: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Platform Badge
                Image(systemName: item.isSwiftUI ? "swift" : "hammer.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(item.isSwiftUI ? AppTheme.StackInspector.swiftUIBadge : AppTheme.StackInspector.uiKitBadge)
                    )
                
                // Name
                Text(item.name)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Index
                Text("[\(item.index)]")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppTheme.StackInspector.itemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCurrent ? AppTheme.StackInspector.currentItemBorder : .clear, lineWidth: 2)
            )
        }
        .disabled(isCurrent)
        .opacity(isCurrent ? 0.7 : 1.0)
    }
}

// MARK: - Navigation Action Buttons

struct NavigationActionsView: View {
    @Environment(\.uiNavigationController) var nc
    
    let swiftUIOptions: [(String, String, () -> any View)]
    let uiKitOptions: [(String, String, () -> UIViewController)]
    
    var body: some View {
        VStack(spacing: 16) {
            // SwiftUI Navigation Section
            VStack(alignment: .leading, spacing: 10) {
                Label("Push SwiftUI Screen", systemImage: "swift")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
                
                HStack(spacing: 12) {
                    ForEach(Array(swiftUIOptions.enumerated()), id: \.offset) { _, option in
                        NavigationButton(
                            title: option.0,
                            icon: option.1,
                            color: AppTheme.swiftUIAccent
                        ) {
                            let view = option.2()
                            nc?.push(view: AnyView(view), title: option.0)
                        }
                    }
                }
            }
            
            // UIKit Navigation Section
            VStack(alignment: .leading, spacing: 10) {
                Label("Push UIKit VC", systemImage: "hammer.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
                
                HStack(spacing: 12) {
                    ForEach(Array(uiKitOptions.enumerated()), id: \.offset) { _, option in
                        NavigationButton(
                            title: option.0,
                            icon: option.1,
                            color: AppTheme.uiKitAccent
                        ) {
                            let vc = option.2()
                            nc?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        }
    }
}

struct NavigationButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Base Navigable View

/// Base screen layout for all SwiftUI screens in the demo.
struct BaseNavigableView<Content: View>: View {
    let config: ScreenConfig
    let content: Content
    
    @Environment(\.uiNavigationController) var nc
    
    init(config: ScreenConfig, @ViewBuilder content: () -> Content) {
        self.config = config
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Gradient Background
            config.gradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    screenHeader
                    
                    // Stack Inspector
                    StackInspectorView()
                    
                    // Custom Content
                    content
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationTitle(config.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                toolbarButtons
            }
        }
    }
    
    private var screenHeader: some View {
        HStack(spacing: 16) {
            Image(systemName: config.icon)
                .font(.system(size: 40))
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(config.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack(spacing: 6) {
                    Image(systemName: "swift")
                        .font(.caption)
                    Text("SwiftUI Screen")
                        .font(.subheadline)
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.3))
                .clipShape(Capsule())
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    @ViewBuilder
    private var toolbarButtons: some View {
        Menu {
            Section("Push SwiftUI") {
                Button { nc?.push(view: ProfileScreen(), title: "Profile") } label: {
                    Label("Profile", systemImage: "person.fill")
                }
                Button { nc?.push(view: SettingsScreen(), title: "Settings") } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }
            Section("Push UIKit") {
                Button { nc?.pushViewController(DashboardVC(), animated: true) } label: {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                Button { nc?.pushViewController(MessagesVC(), animated: true) } label: {
                    Label("Messages", systemImage: "bubble.left.fill")
                }
                Button { nc?.pushViewController(AccountVC(), animated: true) } label: {
                    Label("Account", systemImage: "creditcard.fill")
                }
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
        }
        
        if nc?.viewControllers.count ?? 0 > 1 {
            Button {
                nc?.popToRootViewController(animated: true)
            } label: {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
            }
        }
    }
}
