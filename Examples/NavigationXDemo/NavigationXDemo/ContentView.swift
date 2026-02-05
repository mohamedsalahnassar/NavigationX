import SwiftUI
import NavigationX

struct ContentView: View {
    var body: some View {
        NavigationStackX {
            DemoHomeView()
        }
    }
}

// MARK: - Screens

struct DemoHomeView: View {
    @Environment(\.uiNavigationController) var nc
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "safari")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("NavigationX")
                .font(.largeTitle)
                .bold()
            
            Text("Lightweight. Hybrid. Simple.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical)
            
            // Debug Info
            if let nc = nc {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Captured NC")
                        .font(.caption)
                        .bold()
                }
                Text(String(format: "%p", nc))
                    .font(.caption2)
                    .padding(5)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(5)
            } else {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("No NC Captured")
                }
            }
            
            // Actions
            VStack(spacing: 15) {
                Button("Push SwiftUI View (Standard)") {
                    // Standard NavigationLink usage is also supported by NavigationStack
                }
                .disabled(true)
                .overlay(Text("Use NavLink below").font(.caption).offset(y: 20))
                
                NavigationLink("Standard NavigationLink", value: "Standard")
                    .buttonStyle(.bordered)
                
                Button("Push SwiftUI View (via nc.push)") {
                    nc?.push(view: DetailView(), title: "Detail View")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationDestination(for: String.self) { val in
            Text("Standard Destination: \(val)")
        }
        .navigationTitle("Home")
    }
}

struct DetailView: View {
    @Environment(\.uiNavigationController) var nc
    
    var body: some View {
        VStack(spacing: 20) {
            Text("📄 Detail View")
                .font(.title)
            
            if let nc = nc {
                Text(String(format: "NC: %p", nc))
                    .font(.caption2)
                    .padding(4)
                    .background(Color.green.opacity(0.1))
            }
            
            Text("This view was pushed via `nc.push`.")
            
            Button("Push generic UIViewController") {
                let vc = GenericViewController()
                nc?.pushViewController(vc, animated: true)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
    }
}

class GenericViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Generic VC"
        
        let label = UILabel()
        label.text = "UIKit View Controller"
        label.font = .boldSystemFont(ofSize: 24)
        
        let popButton = UIButton(type: .system)
        popButton.setTitle("Pop to DetailView (SwiftUI)", for: .normal)
        popButton.setTitleColor(.white, for: .normal)
        popButton.backgroundColor = .systemBlue
        popButton.layer.cornerRadius = 10
        popButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        popButton.addTarget(self, action: #selector(popToDetail), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [label, popButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func popToDetail() {
        // Test popTo<Content: View>(viewType:)
        if let popped = navigationController?.popTo(viewType: DetailView.self) {
            print("✅ Popped to DetailView: \(popped)")
        } else {
            print("❌ Failed to pop to DetailView")
            // Fallback
            navigationController?.popViewController(animated: true)
        }
    }
}
