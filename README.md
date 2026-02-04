# NavigationX

NavigationX is a powerful declarative navigation library that bridges SwiftUI and UIKit. It allows you to manage your navigation stack using a simple array of identifiers, while maintaining full compatibility with UIKit's imperative navigation (push/pop).

## Features

- **Declarative Navigation**: Drive your stack with `NavStack` and a binding to `path`.
- **UIKit Bridge**: Seamlessly push/pop `UIViewController`s alongside SwiftUI Views.
- **Deep Linking**: Restore complex navigation states easily.
- **Interception (Swizzling)**: Automatically captures imperative pushes from UIKit and syncs them to your declarative path.
- **Distributed Destinations**: Define destination views anywhere in your hierarchy using `.navDestination(name: ...)`.

## Usage

### 1. Define Destinations
Use `.navDestination` to register view builders for specific screen names.
```swift
NavStack {
    VStack {
        // ...
    }
    .navDestination(name: "Profile") { id in
        ProfileView()
    }
}
```

### 2. Navigate
Inject `NavigationCoordinator` and push identifiers.
```swift
@EnvironmentObject var coordinator: NavigationCoordinator

func navigate() {
    coordinator.push(ScreenIdentifier(name: "Profile"))
}
```

### 3. Mixed Stack
Push UIKit controllers imperatively; NavigationX automatically syncs the state.
```swift
// In a UIViewController
navigationController?.pushViewController(detailsVC, animated: true)
// coordinator.path is updated automatically!
```

## Architecture

NavigationX uses a `NavigationCoordinator` to manage the source of truth (`path: [ScreenIdentifier]`). It observes changes and synchronizes them with the underlying `UINavigationController`.

- **ScreenIdentifier**: A universal ID for any screen (View or VC).
- **Swizzling**: We intercept `UINavigationController` methods to keep the declarative path in sync with imperative actions.
- **Lazy Registry**: Destinations are registered at runtime via view modifiers, allowing for decentralized navigation logic.
