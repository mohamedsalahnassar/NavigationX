import SwiftUI
import NavigationX

struct StackInspector: View {
    @ObservedObject var navigator: Navigator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stack Inspector")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(navigator.viewControllers.enumerated()), id: \.element) { index, vc in
                        StackItemView(index: index, viewController: vc, isLast: index == navigator.viewControllers.count - 1)
                            .onTapGesture {
                                if index < navigator.viewControllers.count - 1 {
                                    navigator.pop(to: vc)
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.secondarySystemBackground))
    }
}

struct StackItemView: View {
    let index: Int
    let viewController: UIViewController
    let isLast: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(index)")
                .font(.caption2)
                .fontWeight(.bold)
                .padding(6)
                .background(Circle().fill(Color.blue.opacity(0.1)))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(viewName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .fixedSize()
                Text(className)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fixedSize()
            }
            
            if !isLast {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isLast ? Color.blue : Color.clear, lineWidth: 1)
        )
    }
    
    private var viewName: String {
        viewController.title ?? "Untitled"
    }
    
    private var className: String {
        String(describing: type(of: viewController))
    }
}
