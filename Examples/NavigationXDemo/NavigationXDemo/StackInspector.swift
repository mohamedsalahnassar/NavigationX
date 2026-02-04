import SwiftUI
import NavigationX

struct StackInspector: View {
    @ObservedObject var coordinator: NavigationCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Stack Inspector")
                .font(.caption)
                .bold()
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            if let stacks = coordinator.navigationController?.viewControllers {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(stacks.enumerated()), id: \.element) { index, vc in
                            StackItemView(index: index, viewController: vc, isLast: index == stacks.count - 1)
                                .onTapGesture {
                                    if let id = vc.screenIdentifier {
                                        coordinator.pop(to: id, triggeredBy: "Stack Inspector")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("No Navigation Controller")
                    .font(.caption)
                    .padding()
            }
        }
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
        .frame(maxHeight: 120)
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
                Text(identifierName)
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
    
    private var identifierName: String {
        viewController.screenIdentifier?.name ?? "Unknown (Imperative)"
    }
    
    private var className: String {
        String(describing: type(of: viewController))
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
