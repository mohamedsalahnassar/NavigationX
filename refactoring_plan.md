# NavigationX Refactoring Plan: Declarative Hybrid Navigation

**Objective**: Refactor `NavigationX` to adopt a fully declarative, SwiftUI-native navigation pattern (using `NavigationPath` and `.navigationDestination`) while maintaining seamless support for mixed UIKit (`UIViewController`) and SwiftUI (`View`) stacks.

**Reference**: [SwiftUI Navigation with Coordinators](https://lukejones1.github.io/posts/swiftui-navigation/)
This plan adopts the "Coordinator" and "Flow" patterns discussed in the article but adapts them to drive a robust, hybrid `UINavigationController` engine.

## 1. The Core Problem
Currently, `NavigationX` relies on an imperative `Navigator` object (`navigator.push(view)`). This works, but it deviates from Modern SwiftUI's data-driven approach (`path.append(route)`). As we migrate the app screen-by-screen, we want to write "SwiftUI-first" code without creating technical debt, even if the destination happens to be a legacy `UIViewController`.


## 2. Article Analysis & Application
The article "SwiftUI Navigation with Coordinators" advocates for:
1.  **Removing Logic from Views**: Views shouldn't know *where* they go, just *that* they want to go somewhere (Intents).
2.  **Coordinator Object**: A generic object that holds the navigation state (Path).
3.  **Flow View**: A top-level view that renders the stack based on the Coordinator.

**We will adopt this by**:
- Creating a library-level `NavStack` that acts as the "Flow View".
- Encouraging users to create "Coordinators" that hold the state.
- Allowing users to mix `UIViewController` logic into this flow without breaking the pattern.


### 2.1. The Declarative Engine (`NavStack`)
We will rebuild `NavStack` to behave like SwiftUI's `NavigationStack`, but powered by UIKit.

```swift
// Target Usage
struct AppFlow: View {
    @StateObject var coordinator = AppCoordinator()

    var body: some View {
        NavStack(path: $coordinator.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .profile: ProfileViewController() // UIKit VC!
                    case .settings: SettingsView()       // SwiftUI View!
                    }
                }
        }
    }
}
```

### 2.2. Key Components

1.  **`NavPath` (or `NavigationPath`)**: The source of truth. An array of `Hashable` routes.
2.  **`NavStack`**: A `UIViewControllerRepresentable` that:
    *   Takes a `Binding<[Route]>` (or `NavigationPath`).
    *   Wraps a `UINavigationController`.
    *   **Observes** the path: When items are appended, it resolves the destination and pushes.
    *   **Syncs** back: When a user swipes back (pop), it removes the item from the path binding.
3.  **`DestinationBuilder`**: A mechanism to resolve a `Route` into a concrete `UIViewController`. This logic needs to handle:
    *   **SwiftUI Views**: Automatically wrapped in `UIHostingController`.
    *   **UIKit ViewControllers**: Pushed directly.

## 3. Implementation Steps

### Phase 1: Core Definitions
1.  **Define `AnyDestination`**: A type-erased wrapper that can hold either a `View` or a `UIViewController`.
2.  **Define `NavStack` Interface**: Update `NavStack` to accept a `path` binding.
    ```swift
    public struct NavStack<Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection, Root: View>: View {
        @Binding var path: Data
        @ViewBuilder var root: () -> Root
        // ...
    }
    ```

### Phase 2: The Synchronization Engine
This is the most critical part. We need a `Coordinator` (internal to `NavStack`) that keeps the `UINavigationController` and the `path` array in perfect sync.

1.  **Path -> UIKit (Push)**:
    *   Listen to `onChange(of: path)`.
    *   Calculate the difference (new items appended).
    *   For each new item, call the `destinationBuilder` logic.
    *   Push the resulting VC.
2.  **UIKit -> Path (Pop)**:
    *   Implement `UINavigationControllerDelegate`.
    *   Detect `didShow` notifications.
    *   If the stack count decreased (pop), remove the corresponding last item from the `path` binding.

### Phase 3: Handling `.navigationDestination`
SwiftUI's `.navigationDestination` is a modifier that registers a builder closure. We need to mimic this behavior or leverage it.
*   *Challenge*: Standard `.navigationDestination` is for pure SwiftUI.
*   *Solution*: We might need a custom modifier, e.g., `.navDestination(for: Type, destination: (Type) -> Result)`, where `Result` can be a View or a VC.
    *   Alternatively, we can define a `RouteResolver` protocol that the user passes to `NavStack`.

### Phase 4: Refactoring Example App (`NavigationXDemo`)
1.  Create `AppCoordinator` holding the path.
2.  Define `AppRoute` enum (e.g., `.detail(id: Int)`, `.legacyUIKitFeature`).
3.  Replace imperative `navigator.push` calls with declarative `coordinator.showDetail(...)` which simply does `path.append(...)`.
4.  Verify that pushing a `UIViewController` works seamlessly via this declarative state.

## 4. Migration Strategy
To avoid breaking existing usage immediately:
1.  Keep `Navigator` as an internal helper for now, or expose it strictly for legacy imperative calls if absolutely necessary.
2.  Mark direct `push/pop` on `Navigator` as deprecated in favor of modifying the `path`.

## 5. Artifacts to Deliver
- Updated `NavigationX` package with `NavStack(path: ...)` support.
- Updated `NavigationXDemo` showing the "Article-style" Coordinator pattern.
- A functional test ensuring Mixed Stacks (SwiftUI -> UIKit -> SwiftUI) work with a single declarative path.
