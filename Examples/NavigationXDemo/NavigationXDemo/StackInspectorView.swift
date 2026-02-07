import SwiftUI
import UIKit

// MARK: - Stack Item Model

struct StackItem: Identifiable {
    let id = UUID()
    let index: Int
    let name: String
    let isSwiftUI: Bool
    let viewController: UIViewController
}

// MARK: - Stack Inspector View

struct StackInspectorView: View {
    
    weak var navigationController: UINavigationController?
    
    @State private var stackItems: [StackItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Navigation Stack")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                    
                    Text("\(stackItems.count) screen\(stackItems.count == 1 ? "" : "s") in stack")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Refresh button
                Button {
                    refreshStack()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.1), in: Circle())
                }
                .buttonStyle(.plain)
            }
            
            if stackItems.isEmpty {
                emptyStateView
            } else {
                stackListView
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        )
        .onAppear { refreshStack() }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "tray")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.4))
                Text("No stack available")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }
    
    // MARK: - Stack List
    
    private var stackListView: some View {
        VStack(spacing: 8) {
            // Reversed order - current screen on top
            ForEach(Array(stackItems.reversed().enumerated()), id: \.element.id) { index, item in
                let isCurrentScreen = index == 0
                let isRootScreen = index == stackItems.count - 1
                StackItemRow(
                    item: item,
                    isFirst: isRootScreen,
                    isLast: isCurrentScreen,
                    totalCount: stackItems.count,
                    onPopTo: { popTo(item) }
                )
            }
        }
    }
    
    // MARK: - Actions
    
    private func refreshStack() {
        guard let nc = navigationController else {
            stackItems = []
            return
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            stackItems = nc.viewControllers.enumerated().map { index, vc in
                let name = extractScreenName(from: vc)
                let isSwiftUI = String(describing: type(of: vc)).contains("UIHostingController")
                return StackItem(index: index, name: name, isSwiftUI: isSwiftUI, viewController: vc)
            }
        }
    }
    
    private func extractScreenName(from vc: UIViewController) -> String {
        if let title = vc.title, !title.isEmpty {
            return title
        }
        
        let typeName = String(describing: type(of: vc))
        if typeName.contains("UIHostingController") {
            if let match = typeName.firstMatch(of: /UIHostingController<.*?(\w+)Screen/) {
                return String(match.1)
            }
            if let match = typeName.firstMatch(of: /UIHostingController<.*?(\w+)>/) {
                return String(match.1)
            }
        }
        
        let cleanName = typeName
            .replacingOccurrences(of: "ViewController", with: "")
            .replacingOccurrences(of: "Controller", with: "")
        
        return cleanName.isEmpty ? "Unknown" : cleanName
    }
    
    private func popTo(_ item: StackItem) {
        navigationController?.popToViewController(item.viewController, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            refreshStack()
        }
    }
}

// MARK: - Stack Item Row

struct StackItemRow: View {
    let item: StackItem
    let isFirst: Bool
    let isLast: Bool
    let totalCount: Int
    let onPopTo: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Position indicator with connecting line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isLast ? .white : .white.opacity(0.2))
                        .frame(width: 24, height: 24)
                    
                    if isLast {
                        Circle()
                            .fill(platformColor)
                            .frame(width: 8, height: 8)
                    } else {
                        Text("\(item.index + 1)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            
            // Platform icon with background
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(platformColor.opacity(0.2))
                    .frame(width: 28, height: 28)
                
                Image(systemName: item.isSwiftUI ? "swift" : "apple.logo")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(platformColor)
            }
            
            // Screen info
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                
                Text(item.isSwiftUI ? "SwiftUI View" : "UIKit ViewController")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Action button
            if !isLast {
                Button {
                    onPopTo()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.caption2.weight(.semibold))
                        Text("Pop")
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)
                    Text("Active")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isLast ? .white.opacity(0.1) : .clear)
        )
    }
    
    private var platformColor: Color {
        item.isSwiftUI ? Color(hex: "FF6B35") : .white
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "1E40AF"), Color(hex: "3B82F6")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        StackInspectorView(navigationController: nil)
            .padding()
    }
}
