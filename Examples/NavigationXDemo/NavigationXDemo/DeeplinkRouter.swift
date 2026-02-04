import UIKit
import SwiftUI
import NavigationX

/// Singleton router that parses URLs and navigates to the appropriate screen
@MainActor
public final class DeeplinkRouter {
    
    public static let shared = DeeplinkRouter()
    
    private init() {}
    
    /// Enum defining all supported deeplink destinations
    public enum DeeplinkDestination: String {
        case depositAccount = "deposit-account"
        case fixedDepositAccount = "fixed-deposit-account"
        
        // Expanded expanded cases
        case profileSettings = "profile-settings"
        case transactionHistory = "transaction-history"
        case cardDetails = "card-details"
        case loanCalculator = "loan-calculator"
        
        // Helper to match the last component
        static func match(url: URL) -> DeeplinkDestination? {
            guard let lastComponent = url.pathComponents.filter({ $0 != "/" }).last else { return nil }
            return DeeplinkDestination(rawValue: lastComponent)
        }
    }
    
    /// Handle an incoming deeplink URL
    /// - Parameters:
    ///   - url: The deeplink URL
    ///   - source: The view controller to navigate from
    public func handle(url: URL, from source: UIViewController) {
        print("🔗 [DeeplinkRouter] Handling URL: \(url.absoluteString)")
        guard let customPath = DeeplinkDestination.match(url: url) else { return }
        print("🔗 [DeeplinkRouter] Matched destination: \(customPath)")
        
        switch customPath {
        case .depositAccount: navigateToDepositAccount(from: source)
        case .fixedDepositAccount: navigateToFixedDepositAccount(from: source)
        case .profileSettings: navigateToProfileSettings(from: source)
        case .transactionHistory: navigateToTransactionHistory(from: source)
        case .cardDetails: navigateToCardDetails(from: source)
        case .loanCalculator: navigateToLoanCalculator(from: source)
        }
    }
    
    // MARK: - Navigation Logic
    
    private func navigateToDepositAccount(from source: UIViewController) {
        let view = Text("Deposit Account Screen").font(.largeTitle).navigationTitle("Deposit Account")
        source.pushBridgedSwiftUIView(view)
    }
    
    private func navigateToFixedDepositAccount(from source: UIViewController) {
        let view = Text("Fixed Deposit (Presented)").font(.largeTitle).padding()
        let hostingController = UIHostingController(rootView: view)
        source.present(hostingController, animated: true)
    }
    
    private func navigateToProfileSettings(from source: UIViewController) {
        // Since we are now in the Demo App target, we can use our nice reusable views!
        let view = DeeplinkSwiftUIView(title: "Profile Settings", subtitle: "SwiftUI Push Destination")
        source.pushBridgedSwiftUIView(view)
    }
    
    private func navigateToTransactionHistory(from source: UIViewController) {
        let view = DeeplinkSwiftUIView(title: "Transaction History", subtitle: "SwiftUI Push Destination")
        source.pushBridgedSwiftUIView(view)
    }
    
    private func navigateToCardDetails(from source: UIViewController) {
        let vc = DeeplinkViewController(title: "Card Details", subtitle: "UIKit Push Destination")
        source.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToLoanCalculator(from source: UIViewController) {
        let vc = DeeplinkViewController(title: "Loan Calculator", subtitle: "UIKit Modal Destination")
        source.present(vc, animated: true)
    }
}
