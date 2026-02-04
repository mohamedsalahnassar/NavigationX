import SwiftUI
import UIKit
import NavigationX

// MARK: - Reusable SwiftUI Destination
struct DeeplinkSwiftUIView: View {
    @Environment(\.navigator) var navigator
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 0) {
            if let navigator {
                StackInspector(navigator: navigator)
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    Text(title)
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 40)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if let navigator {
                         Text("Stack Depth: \(navigator.stackDepth)")
                            .font(.caption)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reusable UIKit Destination

class DeeplinkViewController: UIViewController {
    
    private let screenTitle: String
    private let subtitle: String
    
    // We need to keep a reference to the navigator if it was passed during creation,
    // although for the StackInspector we ideally want it to be picked up from context if possible.
    // However, since UIViewController doesn't have Environment, we usually pass it or
    // rely on the wrapper to inject it.
    // For this demo, let's assume we might pass it or just find it.
    private var navigator: Navigator?
    
    init(title: String, subtitle: String) {
        self.screenTitle = title
        self.subtitle = subtitle
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Attempt to find navigator from navigation controller if not set
        if navigator == nil, let nav = navigationController {
            // In a real app we might have a cleaner way to get this, e.g. from the bridge
            // But here we can create a temporary one just for inspection if needed,
            // OR ideally we rely on the implementation detail that the Navigator binds to the NC.
            navigator = Navigator(navigationController: nav)
        }
        
        setupContent()
    }
    
    private func setupContent() {
        // We use a hosting controller to render the SwiftUI content (StackInspector + Info)
        // inside this UIKit view controller.
        
        let content = DeeplinkUIKitContent(
            title: screenTitle,
            subtitle: subtitle,
            navigator: navigator
        )
        
        let hostingHelper = UIHostingController(rootView: content)
        hostingHelper.view.translatesAutoresizingMaskIntoConstraints = false
        hostingHelper.view.backgroundColor = .clear
        
        addChild(hostingHelper)
        view.addSubview(hostingHelper.view)
        hostingHelper.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            hostingHelper.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingHelper.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingHelper.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingHelper.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

struct DeeplinkUIKitContent: View {
    let title: String
    let subtitle: String
    // We pass it explicitly because this view is rooted in a VC that is not part of a bridged stack hierarchy directly yet
    let navigator: Navigator?
    
    var body: some View {
        VStack(spacing: 0) {
            if let navigator {
                StackInspector(navigator: navigator)
            } else {
                 Text("Navigator not available")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding()
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    Text(title)
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 40)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Implemented as UIViewController")
                        .font(.caption)
                        .padding(6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)

                    Spacer()
                }
            }
        }
    }
}
