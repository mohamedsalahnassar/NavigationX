<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2016+-blue?style=for-the-badge&logo=apple" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-6.2-orange?style=for-the-badge&logo=swift" alt="Swift">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</p>

<h1 align="center">🧭 NavigationX</h1>

<p align="center">
  <strong>Seamless hybrid navigation for SwiftUI + UIKit</strong><br>
  <em>One line. Zero coordinators. Full control.</em>
</p>

---

## ✨ Why NavigationX?

SwiftUI's `NavigationStack` is great, but sometimes you need the raw power of `UINavigationController`:

- 🔄 **Hybrid Apps** — Push UIKit view controllers from SwiftUI
- 🎯 **Precise Control** — Pop to specific views, inspect the stack
- ⚡ **Async Navigation** — Use `await` with push/pop animations
- 🧵 **Swift 6 Ready** — Full concurrency support with `@Observable`

```swift
// Access UINavigationController from any SwiftUI view
@Environment(\.uiNavigationController) var nc

// Push anything
nc?.push(view: DetailView())           // SwiftUI view
nc?.pushViewController(legacyVC)       // UIKit controller

// Pop with precision
nc?.popTo(viewType: HomeView.self)     // Pop to specific view type
await nc?.popToRootAsync()             // Await animation completion
```

---

## 📦 Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mohamedsalahnassar/NavigationX.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → paste the URL.

---

## 🚀 Quick Start

### 1. Wrap Your Root View

Replace `NavigationStack` with `NavigationStackX`:

```swift
import NavigationX

struct ContentView: View {
    var body: some View {
        NavigationStackX {
            HomeView()
        }
    }
}
```

### 2. Access the Navigation Controller

```swift
struct HomeView: View {
    @Environment(\.uiNavigationController) var nc
    
    var body: some View {
        VStack {
            Button("Push SwiftUI View") {
                nc?.push(view: ProfileView(), title: "Profile")
            }
            
            Button("Push UIKit Controller") {
                let vc = LegacyViewController()
                nc?.pushViewController(vc, animated: true)
            }
        }
    }
}
```

### 3. Pop Back from UIKit

```swift
class LegacyViewController: UIViewController {
    @objc func goBack() {
        // Pop to a specific SwiftUI view type
        navigationController?.popTo(viewType: HomeView.self)
    }
}
```

---

## 🔥 Features

### Async Navigation

Navigate with structured concurrency:

```swift
// Wait for animations to complete
await nc?.pushAsync(view: DetailView())
await nc?.popViewControllerAsync(animated: true)
await nc?.popToRootViewControllerAsync(animated: true)

// Chain navigation operations
Task {
    await nc?.pushAsync(view: Step1View())
    try await Task.sleep(for: .seconds(2))
    await nc?.pushAsync(view: Step2View())
}
```

### Navigator Observable Class

Use the modern `@Observable` Navigator for reactive state:

```swift
@Environment(\.navigator) var navigator

var body: some View {
    VStack {
        Text("Stack depth: \(navigator?.stackDepth ?? 0)")
        
        Button("Pop") {
            navigator?.pop()
        }
        .disabled(!(navigator?.canPop ?? false))
    }
}
```

### Stack Inspection

Query the navigation stack:

```swift
// Check if a view exists
if nc?.contains(viewType: SettingsView.self) == true {
    nc?.popTo(viewType: SettingsView.self)
}

// Find view index
if let index = nc?.indexOf(viewType: ProfileView.self) {
    print("Profile is at index \(index)")
}
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                    NavigationStackX                  │
│  ┌───────────────────────────────────────────────┐  │
│  │              NavigationStack                   │  │
│  │  ┌─────────────────────────────────────────┐  │  │
│  │  │           Your SwiftUI View              │  │  │
│  │  │  @Environment(\.uiNavigationController)  │  │  │
│  │  └─────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────┘  │
│                        │                             │
│              NavigationIntrospect                    │
│                        │                             │
│                        ▼                             │
│              UINavigationController                  │
│               (injected via Environment)             │
└─────────────────────────────────────────────────────┘
```

**How it works:**
1. `NavigationStackX` wraps the standard `NavigationStack`
2. `NavigationIntrospect` finds the underlying `UINavigationController`
3. The controller is injected into the SwiftUI `Environment`
4. All child views can access it via `@Environment(\.uiNavigationController)`

---

## 📊 Comparison

| Feature | NavigationX | Coordinators | SwiftUI Only |
|---------|:-----------:|:------------:|:------------:|
| Push UIKit VCs from SwiftUI | ✅ | ✅ | ❌ |
| Pop to specific view type | ✅ | ✅ | ❌ |
| Async navigation | ✅ | ⚠️ | ❌ |
| Zero boilerplate | ✅ | ❌ | ✅ |
| Stack inspection | ✅ | ✅ | ❌ |
| Learning curve | Low | High | Low |
| Lines of setup code | 1 | 50+ | 0 |

---

## 🧪 Testing

```bash
swift test
```

---

## 📋 Requirements

- iOS 16.0+
- Swift 6.2+
- Xcode 16+

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">
  <strong>Made with ❤️ for the SwiftUI community</strong>
</p>
