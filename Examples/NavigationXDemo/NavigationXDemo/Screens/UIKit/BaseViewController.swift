import UIKit
import SwiftUI
import NavigationX

// MARK: - VC Configuration

struct VCConfig {
    let title: String
    let subtitle: String
    let primaryColor: UIColor
    let gradientColors: [UIColor]
    let iconName: String
    
    static let dashboard = VCConfig(
        title: "Dashboard",
        subtitle: "Analytics overview",
        primaryColor: UIColor(hex: "14B8A6"),
        gradientColors: [UIColor(hex: "0D9488"), UIColor(hex: "14B8A6"), UIColor(hex: "2DD4BF")],
        iconName: "chart.bar.fill"
    )
    
    static let detail = VCConfig(
        title: "Detail",
        subtitle: "Item information",
        primaryColor: UIColor(hex: "EC4899"),
        gradientColors: [UIColor(hex: "BE185D"), UIColor(hex: "EC4899"), UIColor(hex: "F472B6")],
        iconName: "doc.text.fill"
    )
    
    static let form = VCConfig(
        title: "Form",
        subtitle: "Data entry",
        primaryColor: UIColor(hex: "6366F1"),
        gradientColors: [UIColor(hex: "4338CA"), UIColor(hex: "6366F1"), UIColor(hex: "818CF8")],
        iconName: "square.and.pencil"
    )
    
    static let list = VCConfig(
        title: "List",
        subtitle: "Browse items",
        primaryColor: UIColor(hex: "F59E0B"),
        gradientColors: [UIColor(hex: "D97706"), UIColor(hex: "F59E0B"), UIColor(hex: "FBBF24")],
        iconName: "list.bullet"
    )
}

// MARK: - Base View Controller

class BaseViewController: UIViewController {
    
    private let config: VCConfig
    private let gradientLayer = CAGradientLayer()
    private var stackInspectorHostingController: UIHostingController<StackInspectorView>?
    
    // MARK: - Initialization
    
    init(config: VCConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        self.title = config.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupDecorativeCircles()
        setupNavigationBar()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    // MARK: - Setup
    
    private func setupGradientBackground() {
        gradientLayer.colors = config.gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupDecorativeCircles() {
        // Large decorative circle
        let circle1 = UIView()
        circle1.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        circle1.layer.cornerRadius = 150
        circle1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(circle1)
        
        // Smaller decorative circle
        let circle2 = UIView()
        circle2.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        circle2.layer.cornerRadius = 100
        circle2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(circle2)
        
        NSLayoutConstraint.activate([
            circle1.widthAnchor.constraint(equalToConstant: 300),
            circle1.heightAnchor.constraint(equalToConstant: 300),
            circle1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 50),
            circle1.topAnchor.constraint(equalTo: view.topAnchor, constant: -50),
            
            circle2.widthAnchor.constraint(equalToConstant: 200),
            circle2.heightAnchor.constraint(equalToConstant: 200),
            circle2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -50),
            circle2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            menu: createNavigationMenu()
        )
        menuButton.tintColor = .white
        navigationItem.rightBarButtonItem = menuButton
    }
    
    private func createNavigationMenu() -> UIMenu {
        let swiftUISection = UIMenu(title: "SwiftUI Screens", options: .displayInline, children: [
            UIAction(title: "Home", image: UIImage(systemName: "house.fill")) { [weak self] _ in
                self?.pushSwiftUIScreen(.home)
            },
            UIAction(title: "Profile", image: UIImage(systemName: "person.fill")) { [weak self] _ in
                self?.pushSwiftUIScreen(.profile)
            },
            UIAction(title: "Settings", image: UIImage(systemName: "gearshape.fill")) { [weak self] _ in
                self?.pushSwiftUIScreen(.settings)
            },
            UIAction(title: "Search", image: UIImage(systemName: "magnifyingglass")) { [weak self] _ in
                self?.pushSwiftUIScreen(.search)
            }
        ])
        
        let uikitSection = UIMenu(title: "UIKit Screens", options: .displayInline, children: [
            UIAction(title: "Dashboard", image: UIImage(systemName: "chart.bar.fill")) { [weak self] _ in
                self?.pushUIKitScreen(.dashboard)
            },
            UIAction(title: "Detail", image: UIImage(systemName: "doc.text.fill")) { [weak self] _ in
                self?.pushUIKitScreen(.detail)
            },
            UIAction(title: "Form", image: UIImage(systemName: "square.and.pencil")) { [weak self] _ in
                self?.pushUIKitScreen(.form)
            },
            UIAction(title: "List", image: UIImage(systemName: "list.bullet")) { [weak self] _ in
                self?.pushUIKitScreen(.list)
            }
        ])
        
        return UIMenu(children: [swiftUISection, uikitSection])
    }
    
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Hero section
        let heroView = createHeroView()
        heroView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(heroView)
        
        // Stack Inspector
        let inspectorView = StackInspectorView(navigationController: navigationController)
        let hostingController = UIHostingController(rootView: inspectorView)
        hostingController.sizingOptions = .intrinsicContentSize
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(hostingController)
        contentView.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        stackInspectorHostingController = hostingController
        
        // Navigation card (now before stack inspector)
        let navCard = createNavigationCard()
        navCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(navCard)
        
        NSLayoutConstraint.activate([
            heroView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            heroView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            heroView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Navigation card comes first (after hero)
            navCard.topAnchor.constraint(equalTo: heroView.bottomAnchor, constant: 24),
            navCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            navCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Stack inspector at the bottom
            hostingController.view.topAnchor.constraint(equalTo: navCard.bottomAnchor, constant: 16),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func createHeroView() -> UIView {
        let container = UIView()
        
        // Platform badge
        let badge = createPlatformBadge()
        badge.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(badge)
        
        // Icon container
        let iconOuter = UIView()
        iconOuter.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        iconOuter.layer.cornerRadius = 50
        iconOuter.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iconOuter)
        
        let iconInner = UIView()
        iconInner.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        iconInner.layer.cornerRadius = 40
        iconInner.translatesAutoresizingMaskIntoConstraints = false
        iconOuter.addSubview(iconInner)
        
        let iconView = UIImageView(image: UIImage(systemName: config.iconName))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconInner.addSubview(iconView)
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = config.subtitle
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = .white.withAlphaComponent(0.8)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            badge.topAnchor.constraint(equalTo: container.topAnchor),
            badge.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            iconOuter.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 16),
            iconOuter.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconOuter.widthAnchor.constraint(equalToConstant: 100),
            iconOuter.heightAnchor.constraint(equalToConstant: 100),
            
            iconInner.centerXAnchor.constraint(equalTo: iconOuter.centerXAnchor),
            iconInner.centerYAnchor.constraint(equalTo: iconOuter.centerYAnchor),
            iconInner.widthAnchor.constraint(equalToConstant: 80),
            iconInner.heightAnchor.constraint(equalToConstant: 80),
            
            iconView.centerXAnchor.constraint(equalTo: iconInner.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconInner.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            
            subtitleLabel.topAnchor.constraint(equalTo: iconOuter.bottomAnchor, constant: 12),
            subtitleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func createPlatformBadge() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        container.layer.cornerRadius = 14
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        
        let iconView = UIImageView(image: UIImage(systemName: "apple.logo"))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 12),
            iconView.heightAnchor.constraint(equalToConstant: 12)
        ])
        stack.addArrangedSubview(iconView)
        
        let label = UILabel()
        label.text = "UIKit"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        stack.addArrangedSubview(label)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        
        return container
    }
    
    private func createNavigationCard() -> UIView {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        blur.layer.cornerRadius = 24
        blur.clipsToBounds = true
        blur.layer.shadowColor = UIColor.black.cgColor
        blur.layer.shadowOpacity = 0.1
        blur.layer.shadowOffset = CGSize(width: 0, height: 10)
        blur.layer.shadowRadius = 20
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        blur.contentView.addSubview(contentStack)
        
        // Header
        let headerStack = UIStackView()
        headerStack.axis = .vertical
        headerStack.spacing = 2
        
        let titleLabel = UILabel()
        titleLabel.text = "Navigate"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        headerStack.addArrangedSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Choose your next destination"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .white.withAlphaComponent(0.7)
        headerStack.addArrangedSubview(subtitleLabel)
        
        contentStack.addArrangedSubview(headerStack)
        
        // SwiftUI Section
        let swiftUISection = createNavigationSection(
            title: "SwiftUI Views",
            icon: "swift",
            iconColor: UIColor(hex: "FF6B35"),
            buttons: [
                ("Home", "house.fill", UIColor(hex: "3B82F6"), { [weak self] in self?.pushSwiftUIScreen(.home) }),
                ("Profile", "person.fill", UIColor(hex: "8B5CF6"), { [weak self] in self?.pushSwiftUIScreen(.profile) }),
                ("Settings", "gearshape.fill", UIColor(hex: "F97316"), { [weak self] in self?.pushSwiftUIScreen(.settings) }),
                ("Search", "magnifyingglass", UIColor(hex: "10B981"), { [weak self] in self?.pushSwiftUIScreen(.search) })
            ]
        )
        contentStack.addArrangedSubview(swiftUISection)
        
        // Divider
        let divider = UIView()
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        contentStack.addArrangedSubview(divider)
        
        // UIKit Section
        let uikitSection = createNavigationSection(
            title: "UIKit Controllers",
            icon: "apple.logo",
            iconColor: .white,
            buttons: [
                ("Dashboard", "chart.bar.fill", UIColor(hex: "14B8A6"), { [weak self] in self?.pushUIKitScreen(.dashboard) }),
                ("Detail", "doc.text.fill", UIColor(hex: "EC4899"), { [weak self] in self?.pushUIKitScreen(.detail) }),
                ("Form", "square.and.pencil", UIColor(hex: "6366F1"), { [weak self] in self?.pushUIKitScreen(.form) }),
                ("List", "list.bullet", UIColor(hex: "F59E0B"), { [weak self] in self?.pushUIKitScreen(.list) })
            ]
        )
        contentStack.addArrangedSubview(uikitSection)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: blur.contentView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor, constant: -20)
        ])
        
        return blur
    }
    
    private func createNavigationSection(title: String, icon: String, iconColor: UIColor, buttons: [(String, String, UIColor, () -> Void)]) -> UIStackView {
        let section = UIStackView()
        section.axis = .vertical
        section.spacing = 12
        
        // Section header
        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.spacing = 6
        headerStack.alignment = .center
        
        let badge = UIView()
        badge.backgroundColor = iconColor.withAlphaComponent(0.15)
        badge.layer.cornerRadius = 10
        badge.translatesAutoresizingMaskIntoConstraints = false
        
        let badgeStack = UIStackView()
        badgeStack.axis = .horizontal
        badgeStack.spacing = 4
        badgeStack.alignment = .center
        badgeStack.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(badgeStack)
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        badgeStack.addArrangedSubview(iconView)
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = iconColor
        badgeStack.addArrangedSubview(label)
        
        NSLayoutConstraint.activate([
            badgeStack.topAnchor.constraint(equalTo: badge.topAnchor, constant: 5),
            badgeStack.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -5),
            badgeStack.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 10),
            badgeStack.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -10)
        ])
        
        headerStack.addArrangedSubview(badge)
        headerStack.addArrangedSubview(UIView()) // Spacer
        section.addArrangedSubview(headerStack)
        
        // Buttons in vertical list (single column for better readability)
        for button in buttons {
            section.addArrangedSubview(createNavTile(title: button.0, icon: button.1, color: button.2, action: button.3))
        }
        
        return section
    }
    
    private func createNavTile(title: String, icon: String, color: UIColor, action: @escaping () -> Void) -> UIView {
        let tile = NavigationTileView(title: title, icon: icon, color: color, action: action)
        return tile
    }
    
    // MARK: - Navigation
    
    private func pushSwiftUIScreen(_ config: ScreenConfig) {
        guard let nc = navigationController else { return }
        let nextIndex = nc.viewControllers.count
        let screen = BaseSwiftUIScreen(config: config, screenIndex: nextIndex)
        nc.push(view: screen, title: config.title)
    }
    
    private func pushUIKitScreen(_ config: VCConfig) {
        let vc = BaseViewController(config: config)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Navigation Tile View

class NavigationTileView: UIView {
    
    private let action: () -> Void
    
    init(title: String, icon: String, color: UIColor, action: @escaping () -> Void) {
        self.action = action
        super.init(frame: .zero)
        setupView(title: title, icon: icon, color: color)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView(title: String, icon: String, color: UIColor) {
        backgroundColor = UIColor.white.withAlphaComponent(0.9)
        layer.cornerRadius = 14
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.04
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        // Icon container
        let iconContainer = UIView()
        iconContainer.backgroundColor = color
        iconContainer.layer.cornerRadius = 10
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)
        
        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            iconContainer.heightAnchor.constraint(equalToConstant: 36),
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        stack.addArrangedSubview(iconContainer)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .label
        stack.addArrangedSubview(titleLabel)
        
        // Spacer
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stack.addArrangedSubview(spacer)
        
        // Chevron
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .secondaryLabel
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.widthAnchor.constraint(equalToConstant: 12).isActive = true
        stack.addArrangedSubview(chevron)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    @objc private func handleTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            self.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.transform = .identity
                self.alpha = 1
            }
        }
        action()
    }
}

// MARK: - Convenience VCs

class DashboardViewController: BaseViewController {
    init() { super.init(config: .dashboard) }
    required init?(coder: NSCoder) { fatalError() }
}

class DetailViewController: BaseViewController {
    init() { super.init(config: .detail) }
    required init?(coder: NSCoder) { fatalError() }
}

class FormViewController: BaseViewController {
    init() { super.init(config: .form) }
    required init?(coder: NSCoder) { fatalError() }
}

class ListViewController: BaseViewController {
    init() { super.init(config: .list) }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - UIColor Extension

extension UIColor {
    convenience init(hex: String) {
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
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
