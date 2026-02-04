import SwiftUI
import NavigationX

struct DeeplinkDemoView: View {
    @Environment(\.navigator) var navigator
    @State private var deeplinkLog: String = "Ready"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Deeplink Router Demo")
                    .font(.title)
                
                Text(deeplinkLog)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .width(.infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                
                Group {
                    Text("SwiftUI Destinations")
                        .font(.headline)
                        .padding(.top)
                    
                    Button("Profile Settings (Push)") {
                        simulateDeeplink("explore-dashboard/profile-settings")
                    }
                    .buttonStyle(PrimaryButtonStyle(color: .blue))
                    
                    Button("Transaction History (Push)") {
                        simulateDeeplink("explore-dashboard/transaction-history")
                    }
                    .buttonStyle(PrimaryButtonStyle(color: .purple))
                }
                
                Group {
                    Text("UIKit Destinations")
                        .font(.headline)
                        .padding(.top)
                    
                    Button("Card Details (Push)") {
                        simulateDeeplink("explore-dashboard/card-details")
                    }
                    .buttonStyle(PrimaryButtonStyle(color: .orange))
                    
                    Button("Loan Calculator (Modal)") {
                        simulateDeeplink("explore-dashboard/loan-calculator")
                    }
                    .buttonStyle(PrimaryButtonStyle(color: .green))
                }
                
                Divider().padding()
                
                Text("Previously Implemented:")
                    .font(.caption)
                
                Button("Deposit Account (Simple Push)") {
                    simulateDeeplink("explore-dashboard/suffix-account-opening/deposit-account")
                }
                
                Button("Fixed Deposit (Simple Modal)") {
                    simulateDeeplink("explore-dashboard/suffix-account-opening/deposit-account/fixed-deposit-account")
                }
            }
            .padding()
        }
    }
    
    private func simulateDeeplink(_ path: String) {
        guard let url = URL(string: "myapp://\(path)") else { return }
        deeplinkLog = "Simulating: .../\(url.lastPathComponent)"
        navigator?.handleDeeplink(url)
    }
}

private extension View {
    func width(_ width: CGFloat) -> some View {
        frame(width: width)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.gradient)
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
