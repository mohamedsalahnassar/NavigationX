import SwiftUI
import UIKit

public extension View {
    func navigationIntrospect(completion: @escaping (UINavigationController) -> Void) -> some View {
        modifier(IntrospectModifier(completion: completion))
    }
}

private struct IntrospectModifier: ViewModifier {
    let completion: (UINavigationController) -> Void
    
    func body(content: Content) -> some View {
        content.background(
            IntrospectionHelper(completion: completion)
                .frame(width: 0, height: 0)
        )
    }
}

private struct IntrospectionHelper: UIViewControllerRepresentable {
    let completion: (UINavigationController) -> Void
    
    func makeUIViewController(context: Context) -> IntrospectionViewController {
        IntrospectionViewController(completion: completion)
    }
    
    func updateUIViewController(_ uiViewController: IntrospectionViewController, context: Context) {}
}

private class IntrospectionViewController: UIViewController {
    let completion: (UINavigationController) -> Void
    
    init(completion: @escaping (UINavigationController) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        findNavigationController(from: parent)
    }
    
    func findNavigationController(from viewController: UIViewController?) {
        guard let viewController else { return }
        
        if let nav = viewController as? UINavigationController {
            completion(nav)
            return
        }
        
        // Traverse up
        findNavigationController(from: viewController.parent)
        
        // Also check children if we are embedded? But usually we are INSIDE a nav controller, so PARENT traversal is correct.
        // However, standard Introspect libraries look for navigationController property or parent hierarchy.
        
        if let nav = viewController.navigationController {
             completion(nav)
             return
        }
    }
}
