import XCTest
import SwiftUI
@testable import NavigationX

// MARK: - Navigator Tests

@available(iOS 17.0, *)
@MainActor
final class NavigatorTests: XCTestCase {
    
    func testInitialization() {
        let navigator = Navigator()
        XCTAssertNil(navigator.navigationController)
        XCTAssertEqual(navigator.stackDepth, 0)
        XCTAssertFalse(navigator.canPop)
    }
    
    func testInitializationWithNavigationController() {
        let navController = UINavigationController()
        let navigator = Navigator(navigationController: navController)
        
        XCTAssertNotNil(navigator.navigationController)
        XCTAssertTrue(navigator.navigationController === navController)
    }
    
    func testBinding() {
        let navigator = Navigator()
        let navController = UINavigationController()
        
        navigator.bind(to: navController)
        
        XCTAssertNotNil(navigator.navigationController)
        XCTAssertTrue(navigator.navigationController === navController)
    }
    
    func testStackDepth() {
        let navController = UINavigationController(rootViewController: UIViewController())
        let navigator = Navigator(navigationController: navController)
        
        XCTAssertEqual(navigator.stackDepth, 1)
        XCTAssertFalse(navigator.canPop)
        
        navController.pushViewController(UIViewController(), animated: false)
        XCTAssertEqual(navigator.stackDepth, 2)
        XCTAssertTrue(navigator.canPop)
    }
    
    func testViewControllers() {
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        let navController = UINavigationController(rootViewController: vc1)
        navController.pushViewController(vc2, animated: false)
        
        let navigator = Navigator(navigationController: navController)
        
        XCTAssertEqual(navigator.viewControllers.count, 2)
        XCTAssertTrue(navigator.viewControllers[0] === vc1)
        XCTAssertTrue(navigator.viewControllers[1] === vc2)
    }
    
    func testPushViewController() {
        let navController = UINavigationController(rootViewController: UIViewController())
        let navigator = Navigator(navigationController: navController)
        
        let newVC = UIViewController()
        navigator.push(newVC, animated: false)
        
        XCTAssertEqual(navigator.stackDepth, 2)
        XCTAssertTrue(navController.topViewController === newVC)
    }
    
    func testPop() {
        let navController = UINavigationController(rootViewController: UIViewController())
        navController.pushViewController(UIViewController(), animated: false)
        let navigator = Navigator(navigationController: navController)
        
        XCTAssertEqual(navigator.stackDepth, 2)
        
        _ = navigator.pop(animated: false)
        
        XCTAssertEqual(navigator.stackDepth, 1)
    }
    
    func testPopToRoot() {
        let navController = UINavigationController(rootViewController: UIViewController())
        navController.pushViewController(UIViewController(), animated: false)
        navController.pushViewController(UIViewController(), animated: false)
        let navigator = Navigator(navigationController: navController)
        
        XCTAssertEqual(navigator.stackDepth, 3)
        
        _ = navigator.popToRoot(animated: false)
        
        XCTAssertEqual(navigator.stackDepth, 1)
    }
}

// MARK: - UINavigationController Extension Tests

@MainActor
final class UINavigationControllerExtensionTests: XCTestCase {
    
    func testPushSwiftUIView() {
        let navController = UINavigationController(rootViewController: UIViewController())
        
        navController.push(view: Text("Test"), title: "Test Title", animated: false)
        
        XCTAssertEqual(navController.viewControllers.count, 2)
        XCTAssertTrue(navController.topViewController is UIHostingController<some View>)
        XCTAssertEqual(navController.topViewController?.title, "Test Title")
    }
    
    func testContainsViewType() {
        let navController = UINavigationController(rootViewController: UIViewController())
        
        // Push a known SwiftUI view
        navController.push(view: TestSwiftUIView(), animated: false)
        
        // The type name matching is string-based
        let typeString = String(describing: type(of: navController.topViewController!))
        XCTAssertTrue(typeString.contains("UIHostingController"))
    }
    
    func testIndexOf() {
        let navController = UINavigationController(rootViewController: UIViewController())
        navController.push(view: TestSwiftUIView(), animated: false)
        
        // Should find the SwiftUI view at index 1
        let index = navController.indexOf(viewType: TestSwiftUIView.self)
        XCTAssertEqual(index, 1)
    }
    
    func testIndexOfNotFound() {
        let navController = UINavigationController(rootViewController: UIViewController())
        
        let index = navController.indexOf(viewType: TestSwiftUIView.self)
        XCTAssertNil(index)
    }
}

// MARK: - Environment Tests

@MainActor
final class EnvironmentTests: XCTestCase {
    
    func testNavigationControllerEnvironmentKeyDefault() {
        var env = EnvironmentValues()
        XCTAssertNil(env.uiNavigationController)
    }
    
    func testNavigationControllerEnvironmentKeySetter() {
        var env = EnvironmentValues()
        let navController = UINavigationController()
        
        env.uiNavigationController = navController
        
        XCTAssertTrue(env.uiNavigationController === navController)
    }
    
    func testNavigatorEnvironmentKeyDefault() {
        var env = EnvironmentValues()
        XCTAssertNil(env.navigator)
    }
    
    func testNavigatorEnvironmentKeySetter() {
        var env = EnvironmentValues()
        let navigator = Navigator()
        
        env.navigator = navigator
        
        XCTAssertTrue(env.navigator === navigator)
    }
}

// MARK: - Test Helpers

private struct TestSwiftUIView: View {
    var body: some View {
        Text("Test View")
    }
}
