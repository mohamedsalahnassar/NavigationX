import XCTest
@testable import NavigationBridge

final class NavigationBridgeTests: XCTestCase {
    
    @MainActor
    func testNavigatorInitialization() {
        let navigator = Navigator()
        XCTAssertNil(navigator.navigationController)
        XCTAssertEqual(navigator.stackDepth, 0)
    }
    
    @MainActor
    func testNavigatorBinding() {
        let navigator = Navigator()
        let navController = UINavigationController()
        
        navigator.bind(to: navController)
        
        XCTAssertNotNil(navigator.navigationController)
        XCTAssertTrue(navigator.navigationController === navController)
    }
    
    @MainActor
    func testBridgeStateIsolation() {
        let navController1 = UINavigationController()
        let navController2 = UINavigationController()
        
        let state1 = navController1.bridgeState
        let state2 = navController2.bridgeState
        
        // Each controller should have its own state
        XCTAssertTrue(state1 !== state2)
        XCTAssertTrue(state1.navigationController === navController1)
        XCTAssertTrue(state2.navigationController === navController2)
    }
}
