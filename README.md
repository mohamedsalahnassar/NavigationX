# NavigationBridge

A robust, lightweight Swift library for seamless hybrid navigation between **UIKit ViewControllers** and **SwiftUI Views**. 

Built for iOS 16+ and **Swift 6.2 Strict Concurrency**.

## 🚀 Features

- **Bridged Navigation**: Push `UIViewController` from SwiftUI and `View` from UIKit effortlessly.
- **Unified State**: Single `Navigator` source of truth, shared across both worlds.
- **Isolation**: Each `UINavigationController` maintains its own independent state (supports `TabView`).
- **Observation**: SwiftUI views can react to stack changes (e.g., stack depth, top controller).
- **Concurrency Safe**: Fully compatible with Swift 6.2 strict concurrency (MainActor isolated).
- **Zero Boilerplate**: Designed to drop into existing projects with minimal setup.

---

## 📦 Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-repo/NavigationBridge.git", from: "1.0.0")
]
```

Or add via Xcode:
1. File > Add Packages...
2. Enter repository URL.
3. Select version.

---

## 🛠 Usage

### 1. Setup the Stack
Replace `NavigationStack` with `BridgedNavigationStack` at your root:

```swift
import NavigationBridge

struct ContentView: View {
    var body: some View {
        BridgedNavigationStack {
            HomeView()
        }
    }
}
```

### 2. Navigating from SwiftUI
Access the `Navigator` via the environment:

```swift
struct HomeView: View {
    // 1. Get navigator from environment
    @Environment(\.navigator) var navigator
    
    var body: some View {
        VStack {
            // Push a SwiftUI View
            Button("Detail View") {
                navigator?.push(DetailView())
            }
            
            // Push a UIKit ViewController
            Button("Settings (UIKit)") {
                navigator?.push(SettingsViewController())
            }
            
            // Pop
            Button("Go Back") {
                navigator?.pop()
            }
        }
        .navigationTitle("Home")
    }
}
```

### 3. Navigating from UIKit
Use the provided `Navigator` instance (or pass it reference):

```swift
class SettingsViewController: UIViewController {
    let navigator: Navigator? // Inject this or retrieve via context
    
    // Push SwiftUI
    func openProfile() {
        let profileView = ProfileView()
        navigator?.push(profileView)
    }
    
    // Push UIKit
    func openAbout() {
        let aboutVC = AboutViewController()
        navigator?.push(aboutVC)
    }
}
```

---

## ⚡️ Advanced Features

### Stack Inspection
You can inspect and manipulate the stack programmatically.

```swift
// Get stack depth
let count = navigator.viewControllers.count

// Pop to root
navigator.popToRoot()

// Pop to specific controller
if let secondVC = navigator.viewControllers.first(where: { $0.title == "Details" }) {
    navigator.pop(to: secondVC)
}
```

### Concurrency
All UI operations are strictly isolated to the `@MainActor`:

```swift
Task { @MainActor in
    // Safe to call from async contexts
    navigator.push(NewView())
}
```

---

## 📱 Example App
Check out `Examples/NavigationBridgeDemo` for a full application demonstrating:
- **Stack Inspector**: A real-time visualizer of the navigation stack.
- **Mixed Flows**: Recursive navigation between SwiftUI and UIKit.
- **Tab Isolation**: Two tabs with completely independent navigation histories.
- **Stress Tests**: Deep linking and complex pop interactions.

---

## 📄 License
MIT License. See [LICENSE](LICENSE) for details.
