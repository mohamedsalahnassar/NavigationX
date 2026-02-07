import UIKit
import SwiftUI
import NavigationX

// MARK: - Dashboard VC

/// UIKit dashboard ViewController with orange gradient theme.
final class DashboardVC: BaseNavigableViewController {
    
    override var screenConfig: ScreenConfig { .dashboard }
    override var gradientColors: [CGColor] { AppTheme.UIKitGradient.dashboard }
    
    override func createCustomContentView() -> UIView? {
        let container = UIView()
        
        // Stats Cards
        let cardsStack = UIStackView()
        cardsStack.axis = .horizontal
        cardsStack.spacing = 12
        cardsStack.distribution = .fillEqually
        cardsStack.translatesAutoresizingMaskIntoConstraints = false
        
        cardsStack.addArrangedSubview(createStatCard(value: "1,234", label: "Users", icon: "person.3.fill", color: .systemBlue))
        cardsStack.addArrangedSubview(createStatCard(value: "$45.2K", label: "Revenue", icon: "dollarsign.circle.fill", color: .systemGreen))
        
        // Chart placeholder
        let chartView = createChartPlaceholder()
        
        let mainStack = UIStackView(arrangedSubviews: [cardsStack, chartView])
        mainStack.axis = .vertical
        mainStack.spacing = 16
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
    
    private func createStatCard(value: String, label: String, icon: String, color: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        card.layer.cornerRadius = 16
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = .white
        
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 12)
        labelView.textColor = .white.withAlphaComponent(0.7)
        
        let textStack = UIStackView(arrangedSubviews: [valueLabel, labelView])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let mainStack = UIStackView(arrangedSubviews: [iconView, textStack])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.alignment = .leading
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -16)
        ])
        
        return card
    }
    
    private func createChartPlaceholder() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        container.layer.cornerRadius = 16
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView(image: UIImage(systemName: "chart.line.uptrend.xyaxis"))
        icon.tintColor = .white.withAlphaComponent(0.6)
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Analytics View"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.7)
        
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(label)
        
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 48),
            icon.heightAnchor.constraint(equalToConstant: 48),
            
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            container.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return container
    }
}
