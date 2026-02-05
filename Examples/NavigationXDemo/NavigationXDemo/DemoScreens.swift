import SwiftUI
import NavigationX

// MARK: - Helper for Random Data

struct RandomScreenData {
    let color: Color
    let index: Int
    
    static func generate() -> RandomScreenData {
        let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .teal, .indigo, .mint, .cyan]
        return RandomScreenData(
            color: colors.randomElement() ?? .blue,
            index: Int.random(in: 100...999)
        )
    }
}

// MARK: - SwiftUI Demo Screen

struct SwiftUIDemoScreen: View {
    let title: String
    let id: ScreenIdentifier?
    @State private var color: Color = RandomScreenData.generate().color
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var index: Int {
        if let id = id {
            return (coordinator.path.firstIndex(of: id) ?? -1) + 1
        }
        return 0
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Stack Index: \(index)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.top, 40)
// ...
// (Rest of body is fine, except we need to match original context lines)
// I will trick it by targeting the top part only.

                
                Spacer()
                
                VStack(spacing: 16) {
                    NavigationButton(title: "Push SwiftUI", color: .blue) {
                        coordinator.push(ScreenIdentifier(name: "Detail"))
                    }
                    
                    NavigationButton(title: "Push UIKit", color: .orange) {
                        coordinator.push(ScreenIdentifier(name: "UIKit-Screen"))
                    }
                    
                    Divider().padding(.vertical, 8)
                    
                    NavigationButton(title: "Pop", color: .red.opacity(0.8)) {
                        coordinator.pop()
                    }
                    
                    NavigationButton(title: "Pop to Root", color: .red) {
                        coordinator.popToRoot()
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: randomIcon())
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.primary)
            }
        }
    }
    
    func randomIcon() -> String {
        ["star.fill", "heart.fill", "bell.fill", "flag.fill", "bookmark.fill"].randomElement() ?? "star.fill"
    }
}

struct NavigationButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color.gradient)
                .cornerRadius(14)
                .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}

// MARK: - UIKit Controller for Mixed Stack

class DeeplinkViewController: UIViewController {
    let titleText: String
    let subtitle: String
    let index: Int
    let color = RandomScreenData.generate().color
    
    init(title: String, subtitle: String, index: Int) {
        self.titleText = title
        self.subtitle = subtitle
        self.index = index
        super.init(nibName: nil, bundle: nil)
        self.title = "\(title)"
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(color).withAlphaComponent(0.1)
        
        setupUI()
        setupNavBar()
    }
    
    func setupNavBar() {
        let icons = ["tray", "archivebox", "folder", "paperplane", "doc"]
        let randomIcon = icons.randomElement() ?? "tray"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: randomIcon),
            style: .plain,
            target: self,
            action: #selector(randomAction)
        )
        
        // Add inspector internally for UIKit screens
        addInspector()
    }
    
    func addInspector() {
        // Only if not root?
        guard let coordinator = self.coordinator else { return }
        
        // Don't show if root? index 0?
        if index == 0 { return }
        
        let inspectorView = StackInspector(coordinator: coordinator)
            .padding(.bottom, 20)
            .background(Color.clear)
        
        let host = UIHostingController(rootView: inspectorView)
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(host)
        view.addSubview(host.view)
        
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            host.view.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])
        
        host.didMove(toParent: self)
    }
    
    @objc func randomAction() {
        print("🔔 Random UIKit Action Tapped")
    }
    
    func setupUI() {
        // Create ScrollView
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stack)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor), // Will be covered by Inspector, need padding
            
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -220), // Increased padding for inspector
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = .boldSystemFont(ofSize: 28)
        
        let subLabel = UILabel()
        subLabel.text = subtitle
        subLabel.font = .systemFont(ofSize: 17)
        subLabel.textColor = .secondaryLabel
        
        // Index Bubble
        let indexLabel = UILabel()
        indexLabel.text = "Stack Index: \(index)"
        indexLabel.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        indexLabel.textAlignment = .center
        indexLabel.backgroundColor = .systemFill
        indexLabel.layer.cornerRadius = 12
        indexLabel.layer.masksToBounds = true
        indexLabel.widthAnchor.constraint(equalToConstant: 140).isActive = true
        indexLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // Buttons
        let pushSwiftUIButton = createButton(title: "Push SwiftUI Screen", color: .systemBlue, action: #selector(pushSwiftUI))
        let pushUIKitButton = createButton(title: "Push UIKit Screen", color: .systemOrange, action: #selector(pushUIKit))
        
        // Divider
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        let popButton = createButton(title: "Pop", color: .systemRed, action: #selector(popSelf))
        let popRootButton = createButton(title: "Pop to Root", color: .systemRed, action: #selector(popRoot))
        
        [titleLabel, subLabel, indexLabel, pushSwiftUIButton, pushUIKitButton, divider, popButton, popRootButton].forEach { stack.addArrangedSubview($0) }
    }
    
     func createButton(title: String, color: UIColor, action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = color
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: action, for: .primaryActionTriggered)
        button.widthAnchor.constraint(equalToConstant: 280).isActive = true
        return button
    }
    
    // MARK: - Actions
    
    @objc func pushSwiftUI() {
        if let coordinator = self.coordinator {
            coordinator.push(ScreenIdentifier(name: "Detail"), triggeredBy: "UIKit VC (Idx:\(index))")
        } else {
            print("❌ No coordinator on UIKit VC!")
        }
    }
    
    @objc func pushUIKit() {
        // Imperative Push Test
        let nextIndex = (self.navigationController?.viewControllers.count ?? 0)
        let nextVC = DeeplinkViewController(title: "Imperative Depth", subtitle: "Pushed via native .pushViewController", index: nextIndex)
        // CRITICAL: Propagate coordinator
        nextVC.coordinator = self.coordinator
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func popSelf() {
        // We can use native pop, Swizzling should catch it.
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func popRoot() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

// Helper to bridge UIColor


// Wrapper to bridge UIKit
struct DeeplinkViewControllerWrapper: UIViewControllerRepresentable {
    let title: String
    let subtitle: String
    let id: ScreenIdentifier
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    func makeUIViewController(context: Context) -> UIViewController {
        let index = (coordinator.path.firstIndex(of: id) ?? -1) + 1
        let vc = DeeplinkViewController(title: title, subtitle: subtitle, index: index)
        vc.coordinator = coordinator
        return vc
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Ensure coordinator is kept up to date if view updates (though usually stable)
        if let vc = uiViewController as? DeeplinkViewController {
            vc.coordinator = coordinator
        }
    }
}

struct DeeplinkDemoView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        List {
            Section("Simulation") {
                Button("Simulate /profile") {
                    coordinator.push(ScreenIdentifier(name: "Profile"))
                }
                Button("Simulate /settings/account") {
                    coordinator.push(ScreenIdentifier(name: "Settings"))
                }
            }
        }
        .navigationTitle("Deep Linking")
    }
}
