import SwiftUI
import UIKit
import NavigationX

// MARK: - SwiftUI Views

struct ShopHomeView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("🛍️ Shop Home")
                    .font(.largeTitle)
                    .bold()
                
                ForEach(1...3, id: \.self) { i in
                    Button {
                        coordinator.push(ScreenIdentifier(name: "ProductDetail", id: "PROD-\(i)"))
                    } label: {
                        HStack {
                            Text("Product \(i)")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Shop")
    }
}

struct ProductDetailView: View {
    let productId: String
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "cube.box.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
                .foregroundColor(.blue)
            
            Text("Details for \(productId)")
                .font(.title2)
            
            Text("This is a SwiftUI View. Next step is a UIKit Login Screen.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Proceed to Checkout (Login Required)") {
                // Defines a distinct screen type for the identifier
                coordinator.push(ScreenIdentifier(name: "LoginVC", id: "LOGIN"))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Product")
    }
}

struct CartView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🛒 Your Cart")
                .font(.title)
            
            List {
                Text("Product 1 - $99")
                Text("Product 2 - $49")
            }
            .frame(height: 200)
            
            Button("Pay Now (Secure UIKit VC)") {
                coordinator.push(ScreenIdentifier(name: "PaymentVC", id: "PAYMENT"))
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .navigationTitle("Checkout")
    }
}

struct OrderSuccessView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Order Placed!")
                .font(.title)
                .bold()
            
            Button("Back to Shop") {
                coordinator.popToRoot()
            }
            .padding()
        }
        .navigationTitle("Success")
    }
}

// MARK: - UIKit ViewControllers

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Login (UIKit)"
        
        let label = UILabel()
        label.text = "🔐 Legacy Login Controller"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        
        let button = UIButton(type: .system)
        button.setTitle("Login & Continue", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.axis = .vertical
        stack.spacing = 30
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func didTapLogin() {
        // Demonstrate accessing coordinator from UIKit
        // IMPERATIVE PUSH
        // But we want to use the coordinator if possible for cleanliness,
        // or just rely on Swizzling + standard push.
        
        // Let's use standard push to prove Swizzling works!
        // But wait, the standard push requires a VC instance.
        // And we want to push a SwiftUI view (CartView).
        // Mixing directions:
        // 1. Coordinator.push("CartView") -> Resolves to Host(CartView) -> Push.
        // 2. self.navigationController?.push(...) -> Needs a VC.
        
        // Since the next screen is SwiftUI (CartView), we SHOULD use the Coordinator.
        // Accessing coordinator via the extension property
        print("👤 [LoginVC] Tapping Login, requesting push to Cart")
        self.coordinator?.push(ScreenIdentifier(name: "CartView", id: "CART"))
    }
}

class PaymentViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        title = "Payment (UIKit)"
        
        let label = UILabel()
        label.text = "💳 Payment Gateway"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        
        // Simulate loading
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        
        let button = UIButton(type: .system)
        button.setTitle("Complete Payment", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.addTarget(self, action: #selector(completePayment), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [label, indicator, button])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 30
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func completePayment() {
        // Navigate to Success (SwiftUI)
        self.coordinator?.push(ScreenIdentifier(name: "OrderSuccess", id: "SUCCESS"))
    }
}
// MARK: - Generic Wrapper for Demo

struct NavigationXViewController<T: UIViewController>: UIViewControllerRepresentable {
    let title: String
    let id: ScreenIdentifier
    let builder: () -> T
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    func makeUIViewController(context: Context) -> T {
        let vc = builder()
        // Inject coordinator manually since we are bridging
        vc.coordinator = coordinator
        vc.screenIdentifier = id
        vc.title = title
        return vc
    }
    
    func updateUIViewController(_ uiViewController: T, context: Context) {
        // No-op for demo
    }
}
