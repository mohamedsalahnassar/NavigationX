import SwiftUI
import UIKit
import NavigationX

// MARK: - SwiftUI Demo Screen

struct SwiftUIDemoScreen: View {
    @Environment(\.navigator) var navigator
    let title: String
    let color: Color
    
    init(title: String = "SwiftUI View", color: Color? = nil) {
        self.title = title
        self.color = color ?? Color.random()
    }
    
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
                    
                    Text("This is a native SwiftUI View")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer().frame(height: 20)
                    
                    if let navigator {
                        VStack(spacing: 12) {
                            Button(action: {
                                navigator.push(SwiftUIDemoScreen(title: "SwiftUI #\(navigator.stackDepth + 1)"))
                            }) {
                                Label("Push SwiftUI View", systemImage: "swift")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange.gradient)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {
                                let vc = UIKitDemoViewController(title: "UIKit #\(navigator.stackDepth + 1)", navigator: navigator)
                                navigator.push(vc)
                            }) {
                                Label("Push UIKit ViewController", systemImage: "applelogo")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.gradient)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            if navigator.stackDepth > 1 {
                                Button(action: {
                                    navigator.pop()
                                }) {
                                    Label("Pop", systemImage: "arrow.left")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red.opacity(0.1))
                                        .foregroundColor(.red)
                                        .cornerRadius(12)
                                }
                            }
                            
                            Button(action: {
                                navigator.popToRoot()
                            }) {
                                Text("Pop to Root")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top)
                        }
                        .padding(.horizontal, 30)
                    }
                }
            }
        }
        .background(color.opacity(0.1).ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - UIKit Demo ViewController

class UIKitDemoViewController: UIViewController {
    
    private let screenTitle: String
    private let color: UIColor
    private let navigator: Navigator? // Hold a reference if needed, or pass to wrapper
    
    init(title: String = "UIKit VC", color: UIColor? = nil, navigator: Navigator? = nil) {
        self.screenTitle = title
        self.navigator = navigator
        self.color = color ?? .random()
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = color
        
        setupContent()
    }
    
    private func setupContent() {
        // We will host the StackInspector and Buttons using SwiftUI for consistency in this demo,
        // but adding them as a child VC to this generic UIViewController.
        
        // Use the generic Navigator created in the Scene/Window or rely on the fact that
        // the SwiftUI components inside will read it from Environment if we inject it.
        // HOWEVER, a raw UIViewController doesn't have the EnvironmentObject by default unless hosted.
        
        // TRICKY PART: We need access to the `navigator` instance here to pass it to the helper view.
        // In a real app, you might use dependency injection.
        // For this demo, we'll find the navigator by traversing up or using a known reference.
        // Since we don't have a global, we will rely on the fact that `navigationController` is available.
        
        let content = UIKitContentWrapper(parentVC: self, navigator: navigator!)
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

// Helper to render the buttons inside the UIKit VC using existing SwiftUI styles
struct UIKitContentWrapper: View {
    weak var parentVC: UIViewController?
    let navigator: Navigator
    
    init(parentVC: UIViewController?, navigator: Navigator) {
        self.parentVC = parentVC
        self.navigator = navigator
    }
    
    var body: some View {
        VStack(spacing: 0) {
            StackInspector(navigator: navigator)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text(parentVC?.title ?? "UIKit")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 40)
                    
                    Text("This is a native UIViewController")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer().frame(height: 20)
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            let nextTitle = "SwiftUI #\(navigator.stackDepth + 1)"
                            navigator.push(SwiftUIDemoScreen(title: nextTitle))
                        }) {
                            Label("Push SwiftUI View", systemImage: "swift")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.gradient)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            let nextTitle = "UIKit #\(navigator.stackDepth + 1)"
                            navigator.push(UIKitDemoViewController(title: nextTitle, navigator: navigator))
                        }) {
                            Label("Push UIKit ViewController", systemImage: "applelogo")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.gradient)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            navigator.pop()
                        }) {
                            Label("Pop", systemImage: "arrow.left")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 30)
                }
            }
        }
    }
}

// MARK: - Extensions

extension Color {
    static func random() -> Color {
        Color(
            red: .random(in: 0.8...1),
            green: .random(in: 0.8...1),
            blue: .random(in: 0.8...1)
        )
    }
}

extension UIColor {
    static func random() -> UIColor {
        UIColor(
            red: .random(in: 0.9...1),
            green: .random(in: 0.9...1),
            blue: .random(in: 0.9...1),
            alpha: 1.0
        )
    }
}
