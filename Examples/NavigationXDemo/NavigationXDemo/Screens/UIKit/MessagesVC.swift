import UIKit
import SwiftUI
import NavigationX

// MARK: - Messages VC

/// UIKit messages ViewController with pink gradient theme.
final class MessagesVC: BaseNavigableViewController {
    
    override var screenConfig: ScreenConfig { .messages }
    override var gradientColors: [CGColor] { AppTheme.UIKitGradient.messages }
    
    override func createCustomContentView() -> UIView? {
        let container = UIView()
        
        let messagesStack = UIStackView()
        messagesStack.axis = .vertical
        messagesStack.spacing = 12
        messagesStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Sample messages
        let messages = [
            ("Alice", "Hey! Check out the new navigation demo 🚀", "2m ago"),
            ("Bob", "The stack inspector is really cool!", "15m ago"),
            ("Carol", "SwiftUI + UIKit = ❤️", "1h ago")
        ]
        
        for (name, text, time) in messages {
            messagesStack.addArrangedSubview(createMessageRow(name: name, message: text, time: time))
        }
        
        container.addSubview(messagesStack)
        
        NSLayoutConstraint.activate([
            messagesStack.topAnchor.constraint(equalTo: container.topAnchor),
            messagesStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            messagesStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            messagesStack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    private func createMessageRow(name: String, message: String, time: String) -> UIView {
        let row = UIView()
        row.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        row.layer.cornerRadius = 16
        
        // Avatar
        let avatar = UIView()
        avatar.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        avatar.layer.cornerRadius = 22
        avatar.translatesAutoresizingMaskIntoConstraints = false
        
        let initial = UILabel()
        initial.text = String(name.prefix(1))
        initial.font = .systemFont(ofSize: 18, weight: .bold)
        initial.textColor = .white
        initial.textAlignment = .center
        initial.translatesAutoresizingMaskIntoConstraints = false
        avatar.addSubview(initial)
        
        // Text
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = .white
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 13)
        messageLabel.textColor = .white.withAlphaComponent(0.8)
        messageLabel.numberOfLines = 1
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, messageLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        // Time
        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = .white.withAlphaComponent(0.5)
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let mainStack = UIStackView(arrangedSubviews: [avatar, textStack, timeLabel])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 44),
            avatar.heightAnchor.constraint(equalToConstant: 44),
            
            initial.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            initial.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            
            mainStack.topAnchor.constraint(equalTo: row.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -12),
            mainStack.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12)
        ])
        
        return row
    }
}
