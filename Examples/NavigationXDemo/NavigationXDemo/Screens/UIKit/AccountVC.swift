import UIKit
import SwiftUI
import NavigationX

// MARK: - Account VC

/// UIKit account ViewController with indigo gradient theme.
final class AccountVC: BaseNavigableViewController {
    
    override var screenConfig: ScreenConfig { .account }
    override var gradientColors: [CGColor] { AppTheme.UIKitGradient.account }
    
    override func createCustomContentView() -> UIView? {
        let container = UIView()
        
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Account Info Card
        mainStack.addArrangedSubview(createAccountCard())
        
        // Action Buttons
        mainStack.addArrangedSubview(createActionButton(
            icon: "arrow.counterclockwise.circle.fill",
            title: "Reset to Root",
            subtitle: "Pop all the way back to the first screen",
            action: #selector(resetToRoot)
        ))
        
        mainStack.addArrangedSubview(createActionButton(
            icon: "arrow.left.circle.fill",
            title: "Pop One Screen",
            subtitle: "Go back to the previous screen",
            action: #selector(popOne)
        ))
        
        container.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: container.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    private func createAccountCard() -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        card.layer.cornerRadius = 20
        
        // Credit Card Visual
        let cardVisual = UIView()
        cardVisual.backgroundColor = UIColor(hex: "312E81")
        cardVisual.layer.cornerRadius = 12
        cardVisual.translatesAutoresizingMaskIntoConstraints = false
        
        let chipIcon = UIImageView(image: UIImage(systemName: "cpu.fill"))
        chipIcon.tintColor = UIColor.systemYellow.withAlphaComponent(0.8)
        chipIcon.contentMode = .scaleAspectFit
        chipIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let numberLabel = UILabel()
        numberLabel.text = "•••• •••• •••• 4242"
        numberLabel.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        numberLabel.textColor = .white.withAlphaComponent(0.9)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = "JOHN APPLESEED"
        nameLabel.font = .systemFont(ofSize: 11, weight: .medium)
        nameLabel.textColor = .white.withAlphaComponent(0.6)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let expiryLabel = UILabel()
        expiryLabel.text = "12/28"
        expiryLabel.font = .systemFont(ofSize: 11, weight: .medium)
        expiryLabel.textColor = .white.withAlphaComponent(0.6)
        expiryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardVisual.addSubview(chipIcon)
        cardVisual.addSubview(numberLabel)
        cardVisual.addSubview(nameLabel)
        cardVisual.addSubview(expiryLabel)
        
        // Balance
        let balanceStack = UIStackView()
        balanceStack.axis = .vertical
        balanceStack.spacing = 4
        balanceStack.alignment = .leading
        balanceStack.translatesAutoresizingMaskIntoConstraints = false
        
        let balanceTitle = UILabel()
        balanceTitle.text = "Available Balance"
        balanceTitle.font = .systemFont(ofSize: 12)
        balanceTitle.textColor = .white.withAlphaComponent(0.6)
        
        let balanceValue = UILabel()
        balanceValue.text = "$12,450.00"
        balanceValue.font = .systemFont(ofSize: 28, weight: .bold)
        balanceValue.textColor = .white
        
        balanceStack.addArrangedSubview(balanceTitle)
        balanceStack.addArrangedSubview(balanceValue)
        
        card.addSubview(cardVisual)
        card.addSubview(balanceStack)
        
        NSLayoutConstraint.activate([
            cardVisual.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            cardVisual.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            cardVisual.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            cardVisual.heightAnchor.constraint(equalToConstant: 100),
            
            chipIcon.topAnchor.constraint(equalTo: cardVisual.topAnchor, constant: 12),
            chipIcon.leadingAnchor.constraint(equalTo: cardVisual.leadingAnchor, constant: 12),
            chipIcon.widthAnchor.constraint(equalToConstant: 24),
            chipIcon.heightAnchor.constraint(equalToConstant: 24),
            
            numberLabel.centerYAnchor.constraint(equalTo: cardVisual.centerYAnchor, constant: 4),
            numberLabel.leadingAnchor.constraint(equalTo: cardVisual.leadingAnchor, constant: 12),
            
            nameLabel.bottomAnchor.constraint(equalTo: cardVisual.bottomAnchor, constant: -12),
            nameLabel.leadingAnchor.constraint(equalTo: cardVisual.leadingAnchor, constant: 12),
            
            expiryLabel.bottomAnchor.constraint(equalTo: cardVisual.bottomAnchor, constant: -12),
            expiryLabel.trailingAnchor.constraint(equalTo: cardVisual.trailingAnchor, constant: -12),
            
            balanceStack.topAnchor.constraint(equalTo: cardVisual.bottomAnchor, constant: 16),
            balanceStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            balanceStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return card
    }
    
    private func createActionButton(icon: String, title: String, subtitle: String, action: Selector) -> UIView {
        let button = UIView()
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.layer.cornerRadius = 14
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .white
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .white.withAlphaComponent(0.6)
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .white.withAlphaComponent(0.5)
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStack = UIStackView(arrangedSubviews: [iconView, textStack, chevron])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 16),
            
            mainStack.topAnchor.constraint(equalTo: button.topAnchor, constant: 14),
            mainStack.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -14),
            mainStack.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 14),
            mainStack.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -14)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: action)
        button.addGestureRecognizer(tap)
        button.isUserInteractionEnabled = true
        
        return button
    }
    
    @objc private func resetToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func popOne() {
        navigationController?.popViewController(animated: true)
    }
}
