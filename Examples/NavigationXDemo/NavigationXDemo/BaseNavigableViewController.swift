import UIKit
import SwiftUI
import NavigationX

// MARK: - Base Navigable View Controller

/// Base UIKit ViewController for all UIKit screens in the demo.
/// Features a gradient background, stack inspector, and navigation actions.
class BaseNavigableViewController: UIViewController {
    
    // MARK: - Properties
    
    /// The screen configuration (title, icon, colors)
    var screenConfig: ScreenConfig { fatalError("Subclass must override screenConfig") }
    
    /// The gradient colors for this screen
    var gradientColors: [CGColor] { AppTheme.UIKitGradient.dashboard }
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = gradientColors
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStackInspector()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        // Add header
        contentStack.addArrangedSubview(createHeaderView())
        
        // Add stack inspector
        contentStack.addArrangedSubview(createStackInspectorView())
        
        // Add navigation actions
        contentStack.addArrangedSubview(createNavigationActionsView())
        
        // Add custom content
        if let customContent = createCustomContentView() {
            contentStack.addArrangedSubview(customContent)
        }
    }
    
    private func setupNavigationBar() {
        title = screenConfig.title
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Create menu button
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            menu: createNavigationMenu()
        )
        
        // Create pop to root button
        let popButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.uturn.backward.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(popToRoot)
        )
        
        if (navigationController?.viewControllers.count ?? 0) > 1 {
            navigationItem.rightBarButtonItems = [menuButton, popButton]
        } else {
            navigationItem.rightBarButtonItem = menuButton
        }
    }
    
    // MARK: - View Creation
    
    private func createHeaderView() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        container.layer.cornerRadius = 20
        
        // Icon
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 20
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImage = UIImageView(image: UIImage(systemName: screenConfig.icon))
        iconImage.tintColor = .white
        iconImage.contentMode = .scaleAspectFit
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImage)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = screenConfig.title
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        
        // Badge
        let badgeContainer = UIView()
        badgeContainer.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
        badgeContainer.layer.cornerRadius = 12
        
        let badgeStack = UIStackView()
        badgeStack.axis = .horizontal
        badgeStack.spacing = 4
        badgeStack.alignment = .center
        badgeStack.translatesAutoresizingMaskIntoConstraints = false
        
        let hammerIcon = UIImageView(image: UIImage(systemName: "hammer.fill"))
        hammerIcon.tintColor = .white.withAlphaComponent(0.8)
        hammerIcon.contentMode = .scaleAspectFit
        
        let badgeLabel = UILabel()
        badgeLabel.text = "UIKit ViewController"
        badgeLabel.font = .systemFont(ofSize: 13)
        badgeLabel.textColor = .white.withAlphaComponent(0.8)
        
        badgeStack.addArrangedSubview(hammerIcon)
        badgeStack.addArrangedSubview(badgeLabel)
        badgeContainer.addSubview(badgeStack)
        
        // Layout
        let textStack = UIStackView(arrangedSubviews: [titleLabel, badgeContainer])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.alignment = .leading
        
        let mainStack = UIStackView(arrangedSubviews: [iconContainer, textStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 16
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 70),
            iconContainer.heightAnchor.constraint(equalToConstant: 70),
            iconImage.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 32),
            iconImage.heightAnchor.constraint(equalToConstant: 32),
            
            hammerIcon.widthAnchor.constraint(equalToConstant: 14),
            hammerIcon.heightAnchor.constraint(equalToConstant: 14),
            
            badgeStack.topAnchor.constraint(equalTo: badgeContainer.topAnchor, constant: 4),
            badgeStack.bottomAnchor.constraint(equalTo: badgeContainer.bottomAnchor, constant: -4),
            badgeStack.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor, constant: 10),
            badgeStack.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: -10),
            
            mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16)
        ])
        
        return container
    }
    
    // Stack inspector stored reference
    private var stackInspectorScrollView: UIScrollView?
    private var stackInspectorStackView: UIStackView?
    private var stackCountLabel: UILabel?
    
    private func createStackInspectorView() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        container.layer.cornerRadius = 16
        
        // Header
        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        
        let stackIcon = UIImageView(image: UIImage(systemName: "square.stack.3d.up.fill"))
        stackIcon.tintColor = .white.withAlphaComponent(0.9)
        stackIcon.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = "Navigation Stack"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white.withAlphaComponent(0.9)
        
        let countLabel = UILabel()
        countLabel.font = .systemFont(ofSize: 12)
        countLabel.textColor = .white
        countLabel.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        countLabel.layer.cornerRadius = 10
        countLabel.clipsToBounds = true
        countLabel.textAlignment = .center
        self.stackCountLabel = countLabel
        
        headerStack.addArrangedSubview(stackIcon)
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(UIView()) // Spacer
        headerStack.addArrangedSubview(countLabel)
        
        // Items scroll view
        let itemsScrollView = UIScrollView()
        itemsScrollView.showsHorizontalScrollIndicator = false
        itemsScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.stackInspectorScrollView = itemsScrollView
        
        let itemsStack = UIStackView()
        itemsStack.axis = .horizontal
        itemsStack.spacing = 10
        itemsStack.translatesAutoresizingMaskIntoConstraints = false
        itemsScrollView.addSubview(itemsStack)
        self.stackInspectorStackView = itemsStack
        
        container.addSubview(headerStack)
        container.addSubview(itemsScrollView)
        
        NSLayoutConstraint.activate([
            stackIcon.widthAnchor.constraint(equalToConstant: 20),
            stackIcon.heightAnchor.constraint(equalToConstant: 20),
            
            countLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            countLabel.heightAnchor.constraint(equalToConstant: 22),
            
            headerStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            itemsScrollView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 12),
            itemsScrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            itemsScrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            itemsScrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            itemsScrollView.heightAnchor.constraint(equalToConstant: 90),
            
            itemsStack.topAnchor.constraint(equalTo: itemsScrollView.topAnchor),
            itemsStack.leadingAnchor.constraint(equalTo: itemsScrollView.leadingAnchor),
            itemsStack.trailingAnchor.constraint(equalTo: itemsScrollView.trailingAnchor),
            itemsStack.bottomAnchor.constraint(equalTo: itemsScrollView.bottomAnchor),
            itemsStack.heightAnchor.constraint(equalTo: itemsScrollView.heightAnchor)
        ])
        
        return container
    }
    
    private func refreshStackInspector() {
        guard let stackView = stackInspectorStackView else { return }
        
        // Clear existing items
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let viewControllers = navigationController?.viewControllers else { return }
        
        stackCountLabel?.text = " \(viewControllers.count) items "
        
        for (index, vc) in viewControllers.enumerated() {
            let isCurrent = index == viewControllers.count - 1
            let isSwiftUI = String(describing: type(of: vc)).contains("UIHostingController")
            let displayName = extractDisplayName(for: vc)
            
            let itemView = createStackItemView(
                index: index,
                name: displayName,
                isSwiftUI: isSwiftUI,
                isCurrent: isCurrent,
                vc: vc
            )
            stackView.addArrangedSubview(itemView)
        }
    }
    
    private func extractDisplayName(for vc: UIViewController) -> String {
        if let title = vc.title, !title.isEmpty { return title }
        
        let typeString = String(describing: type(of: vc))
        if typeString.contains("UIHostingController") {
            for pattern in ["Home", "Profile", "Settings"] {
                if typeString.contains(pattern) { return pattern }
            }
            return "SwiftUI"
        }
        
        return typeString
            .replacingOccurrences(of: "ViewController", with: "")
            .replacingOccurrences(of: "VC", with: "")
    }
    
    private func createStackItemView(index: Int, name: String, isSwiftUI: Bool, isCurrent: Bool, vc: UIViewController) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        container.layer.cornerRadius = 12
        if isCurrent {
            container.layer.borderWidth = 2
            container.layer.borderColor = UIColor.yellow.cgColor
        }
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon
        let iconBg = UIView()
        iconBg.backgroundColor = isSwiftUI ? .systemBlue : .systemOrange
        iconBg.layer.cornerRadius = 16
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImage = UIImageView(image: UIImage(systemName: isSwiftUI ? "swift" : "hammer.fill"))
        iconImage.tintColor = .white
        iconImage.contentMode = .scaleAspectFit
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconImage)
        
        // Name
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 11, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        
        // Index
        let indexLabel = UILabel()
        indexLabel.text = "[\(index)]"
        indexLabel.font = .monospacedSystemFont(ofSize: 9, weight: .bold)
        indexLabel.textColor = .white.withAlphaComponent(0.6)
        indexLabel.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [iconBg, nameLabel, indexLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 80),
            
            iconBg.widthAnchor.constraint(equalToConstant: 32),
            iconBg.heightAnchor.constraint(equalToConstant: 32),
            iconImage.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 16),
            iconImage.heightAnchor.constraint(equalToConstant: 16),
            
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])
        
        // Tap gesture
        if !isCurrent {
            let tap = UITapGestureRecognizer(target: self, action: #selector(stackItemTapped(_:)))
            container.addGestureRecognizer(tap)
            container.tag = index
            container.isUserInteractionEnabled = true
        } else {
            container.alpha = 0.7
        }
        
        return container
    }
    
    @objc private func stackItemTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag,
              let vcs = navigationController?.viewControllers,
              index < vcs.count else { return }
        
        navigationController?.popToViewController(vcs[index], animated: true)
    }
    
    private func createNavigationActionsView() -> UIView {
        let container = UIView()
        
        // SwiftUI Section
        let swiftUIHeader = createSectionHeader(title: "Push SwiftUI Screen", icon: "swift")
        let swiftUIButtons = createButtonsRow([
            ("Profile", "person.fill", { [weak self] in
                self?.navigationController?.push(view: ProfileScreen(), title: "Profile")
            }),
            ("Settings", "gearshape.fill", { [weak self] in
                self?.navigationController?.push(view: SettingsScreen(), title: "Settings")
            }),
            ("Home", "house.fill", { [weak self] in
                self?.navigationController?.push(view: HomeScreen(), title: "Home")
            })
        ], color: .systemBlue)
        
        // UIKit Section
        let uiKitHeader = createSectionHeader(title: "Push UIKit VC", icon: "hammer.fill")
        let uiKitButtons = createButtonsRow([
            ("Dashboard", "chart.bar.fill", { [weak self] in
                self?.navigationController?.pushViewController(DashboardVC(), animated: true)
            }),
            ("Messages", "bubble.left.fill", { [weak self] in
                self?.navigationController?.pushViewController(MessagesVC(), animated: true)
            }),
            ("Account", "creditcard.fill", { [weak self] in
                self?.navigationController?.pushViewController(AccountVC(), animated: true)
            })
        ], color: .systemOrange)
        
        let mainStack = UIStackView(arrangedSubviews: [swiftUIHeader, swiftUIButtons, uiKitHeader, uiKitButtons])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: container.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    private func createSectionHeader(title: String, icon: String) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .white.withAlphaComponent(0.9)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white.withAlphaComponent(0.9)
        
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(UIView())
        
        return stack
    }
    
    private func createButtonsRow(_ buttons: [(String, String, () -> Void)], color: UIColor) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        
        for (title, icon, action) in buttons {
            let button = ActionButton(title: title, icon: icon, color: color, action: action)
            stack.addArrangedSubview(button)
        }
        
        return stack
    }
    
    private func createNavigationMenu() -> UIMenu {
        let swiftUIActions = [
            UIAction(title: "Profile", image: UIImage(systemName: "person.fill")) { [weak self] _ in
                self?.navigationController?.push(view: ProfileScreen(), title: "Profile")
            },
            UIAction(title: "Settings", image: UIImage(systemName: "gearshape.fill")) { [weak self] _ in
                self?.navigationController?.push(view: SettingsScreen(), title: "Settings")
            },
            UIAction(title: "Home", image: UIImage(systemName: "house.fill")) { [weak self] _ in
                self?.navigationController?.push(view: HomeScreen(), title: "Home")
            }
        ]
        
        let uiKitActions = [
            UIAction(title: "Dashboard", image: UIImage(systemName: "chart.bar.fill")) { [weak self] _ in
                self?.navigationController?.pushViewController(DashboardVC(), animated: true)
            },
            UIAction(title: "Messages", image: UIImage(systemName: "bubble.left.fill")) { [weak self] _ in
                self?.navigationController?.pushViewController(MessagesVC(), animated: true)
            },
            UIAction(title: "Account", image: UIImage(systemName: "creditcard.fill")) { [weak self] _ in
                self?.navigationController?.pushViewController(AccountVC(), animated: true)
            }
        ]
        
        return UIMenu(children: [
            UIMenu(title: "Push SwiftUI", options: .displayInline, children: swiftUIActions),
            UIMenu(title: "Push UIKit", options: .displayInline, children: uiKitActions)
        ])
    }
    
    @objc private func popToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    /// Override point for subclasses to add custom content
    func createCustomContentView() -> UIView? {
        return nil
    }
}

// MARK: - Action Button

private class ActionButton: UIView {
    private let action: () -> Void
    
    init(title: String, icon: String, color: UIColor, action: @escaping () -> Void) {
        self.action = action
        super.init(frame: .zero)
        
        backgroundColor = color.withAlphaComponent(0.8)
        layer.cornerRadius = 14
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            heightAnchor.constraint(equalToConstant: 70)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func tapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
            self.action()
        }
    }
}
