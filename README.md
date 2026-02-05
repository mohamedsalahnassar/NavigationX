# NavigationX

**Lightweight. Hybrid. Simple.**

NavigationX is a lightweight wrapper around SwiftUI's `NavigationStack` that exposes the underlying `UINavigationController` via the Environment. This enables seamless hybrid navigation scenarios (pushing generic `UIViewControllers` from SwiftUI, popping to SUI views from UIKit, etc.) without complex coordinators or swizzling.

## Features

- **Direct Access**: Get the `UINavigationController` in any SwiftUI view using `@Environment(\.uiNavigationController)`.
- **Hybrid Pushing**: Push any `UIViewController` or SwiftUI `View` from your code.
- **Hybrid Popping**: Pop from a UIKit view controller back to a specific SwiftUI View type in the stack.
- **Zero Config**: No `SceneDelegate` changes, no complex `Coordinator` setup.

## Usage

### 1. Setup

Wrap your root view in `NavigationStackX`. usage is identical to `NavigationStack`:

```swift
import NavigationX

struct ContentView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        // Standard init
        NavigationStackX {
            HomeView()
        }
        
        // OR with path binding
        // NavigationStackX(path: $path) { ... }
    }
}
```

### 2. Accessing Navigation Controller

```swift
struct HomeView: View {
    @Environment(\.uiNavigationController) var nc
    
    var body: some View {
        Button("Push VC") {
            let vc = UIViewController()
            vc.view.backgroundColor = .red
            nc?.pushViewController(vc, animated: true)
        }
    }
}
```

### 3. Pushing SwiftUI Views (Hybrid)

Use the `push(view:)` extension to push a SwiftUI view programmatically. This ensures the environment is propagated correctly.

```swift
nc?.push(view: DetailView(), title: "Detail")
```

### 4. Popping to SwiftUI View (Hybrid)

From a UIKit View Controller, you can pop back to a specific SwiftUI View type in the stack:

```swift
// Inside your UIViewController
navigationController?.popTo(viewType: HomeView.self)
```

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mohamedsalahnassar/NavigationX.git", from: "1.0.0")
]
```

## Requirements

- iOS 16.0+
- Swift 5.7+

## Architecture

`NavigationX` uses `NavigationIntrospect` to locate the `UINavigationController` hosting the `NavigationStack` and injects it into the SwiftUI `Environment`. It adds no other state management or side effects.
