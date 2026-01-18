# NavigationX SOP (Version 1 LLD + Version 4 Roadmap)

## Purpose
Design a Swift Package (iOS 16+) that enables mixed SwiftUI and UIKit navigation flows with a single, shared navigation model. This SOP is scoped to **Version 1 (LLD + MVP implementation)** and **Version 4 (advanced capabilities roadmap)** as requested. Version 4 is documented **separately** from Version 1 to avoid mixing scope or requirements.

## Guiding Principles
- **No private APIs** (avoid `NavigationStackHostingController`).
- **No singletons**; use dependency injection and explicit wiring.
- **SwiftUI-first declarative API**, but works equally from UIKit.
- **Swift 6 concurrency**: MainActor isolation for UI state, Sendable where needed.
- **Minimal re-rendering**: keep navigation state small and stable; separate view state.
- **iOS 16+ only**.

## Version 1 (MVP) — Core Mixed Navigation (LLD)
### Goals
- One shared navigation state driving both SwiftUI `NavigationStack` and UIKit `UINavigationController`.
- Push/pop between SwiftUI Views and UIKit VCs in a single stack.
- Pop to root / pop to route from any screen (SwiftUI or VC).
- Basic deeplink support for a *single* destination or linear stack (no complex flow branching yet).

### Architecture (V1)
**Modules**
- `NavigationCore`
  - `Route` protocol: `id`, `kind`, `payload` (Hashable; minimal for path).
  - `AnyRoute`: type erasure to allow mixed routes.
  - `NavigationState`: value type containing `[AnyRoute]` stack + presentation info.
  - `NavigationStore`: `@MainActor` observable store with push/pop API.
- `NavigationSwiftUI`
  - `NavigationStackBridge`: binds `NavigationPath` to `NavigationStore`.
  - `RouteViewFactory`: maps `Route` → SwiftUI View.
- `NavigationUIKit`
  - `NavigationCoordinator`: bridges store to `UINavigationController` pushes.
  - `RouteViewControllerFactory`: maps `Route` → `UIViewController` or `UIHostingController`.

**Core Flow**
- SwiftUI pushes call `NavigationStore.push(route)`.
- UIKit pushes call the same store.
- Store changes are observed by both bridges, which reconcile stack state.

### Concurrency & State Rules
- `NavigationStore` is `@MainActor` only.
- Route payloads must be `Sendable` if captured in closures.
- No blocking operations in navigation updates.

### LLD: Data Models (V1)
- **RouteKind**
  - `.push`, `.present` (add `.sheet` if needed for SwiftUI parity).
- **RouteID**
  - Stable identifier: `enum RouteID: Hashable { case screen(String) }`
  - Must be deterministic for `popTo(id:)` and deep links.
- **Route**
  - `id: RouteID`
  - `kind: RouteKind`
  - `payload: AnyHashable?` (only if needed; avoid heavy models)
- **AnyRoute**
  - Wraps any `Route` with erased payload.
- **NavigationState**
  - `stack: [AnyRoute]`
  - `presented: AnyRoute?`
  - `path: NavigationPath` (derived; do not store if it can be derived)

### LLD: Store Behavior (V1)
- **push(route)**: append to `stack`, update SwiftUI path.
- **pop()**: remove last from `stack` if exists.
- **popToRoot()**: clear `stack`.
- **popTo(id)**: truncate stack to the first matching `RouteID`.
- **present(route)**: set `presented`.
- **dismiss()**: clear `presented`.
- **apply(routes)**: replace stack atomically (used by deep links).

### LLD: SwiftUI Bridge (V1)
- `NavigationStackBridge` owns a `Binding<NavigationPath>` sourced from store.
- Uses `.navigationDestination(for: AnyRoute.self)` to resolve SwiftUI views.
- Ensures `NavigationPath` updates are diffed (no re-render for unchanged stack).

### LLD: UIKit Bridge (V1)
- `NavigationCoordinator` listens to store and drives `UINavigationController`.
- Implements `UINavigationControllerDelegate` to detect interactive pops.
- Reconciles stack by pushing missing VCs or popping extra ones.

### LLD: View/VC Factories (V1)
- `RouteViewFactory` closure: `(AnyRoute) -> AnyView`
- `RouteViewControllerFactory` closure: `(AnyRoute) -> UIViewController`
- Provide defaults for SwiftUI route -> `UIHostingController`.

### LLD: Deep Links (V1)
- `DeepLinkRegistry` maps `URL` → `[AnyRoute]`.
- For V1, only linear sequences (no branching).
- `NavigationStore.apply(routes)` is the only entry for deep link.

### LLD: Breadcrumbs (V1)
- `BreadcrumbsView` (SwiftUI) displays stack route IDs and copy button.
- `BreadcrumbsViewController` embeds same data for UIKit.
- Copy action uses `UIPasteboard.general.string`.

### LLD: Screen Tagging (V1)
- Every screen renders a label: “SwiftUI View” or “UIViewController”.
- Navigation bar titles required for all VCs.
- Each screen adds a unique right bar button item to validate transitions.

### Minimal Public API (V1)
- `push(_:)`, `pop()`, `popToRoot()`, `popTo(id:)`, `present(_:)`, `dismiss()`
- `Route` protocol with `id` (stable for popTo/deeplink).
- `DeepLinkRegistry` (basic)
  - register path → single route
  - handle URL → push route

### V1 Example App (xcodegen)
- Two entry points:
  - UIKit root with NavigationController
  - SwiftUI root with NavigationStack
- Mixed flow: SwiftUI → VC → SwiftUI → VC
- Each screen:
  - Visible tag: **“SwiftUI View”** or **“UIViewController”**
  - Unique nav bar button items
  - Title set for VCs
- Breadcrumbs component (SwiftUI + VC) showing current stack and copy button

### LLD: Example App Structure (V1)
- `Apps/NavigationXExamples` generated by xcodegen.
- Targets:
  - `NavigationXExamplesSwiftUI` (SwiftUI @main)
  - `NavigationXExamplesUIKit` (UIKit @main)
- Shared demo routes + factories in a `ExamplesCore` module.
- Each screen includes:
  - push/present buttons
  - pop/popToRoot/popTo(id) buttons
  - deeplink trigger buttons

--- 

## Version 4 (Advanced Capabilities) — Separate Scope
> This section stands alone from Version 1 and must not be blended with V1 implementation details. It is a future extension plan that assumes V1 is complete and stable.
### Goals
- **Complex deep links**: multi-step flows and branching navigation.
- **Cross-stack presentation**: push/present in mixed order with predictable back behavior.
- **Flow definitions**: declare multi-screen flows as composable route sequences.
- **Breadcrumbs + analytics hooks**: observe navigation changes without mutating state.

### LLD: Advanced Deep Link System (V4)
- `DeepLinkRegistry` supports:
  - URL → `[Route]` sequence
  - Conditional branching (based on state, auth, feature flags)
  - Deferred resolution (async route builders) using Swift concurrency
- `Flow` abstraction:
  - `Flow` is a sequence of `Route` builders
  - `NavigationStore.apply(flow)` pushes the whole sequence atomically

### LLD: Navigation Observability (V4)
- `NavigationObserver` protocol:
  - Receives stack changes, presentation changes
  - Safe, read-only, non-blocking
- Optional analytics integration (user-provided)

### LLD: Stability Rules (V4)
- All flow applications are atomic to avoid intermediate re-renders.
- Breadcrumbs updates are derived from store state only.

## Risks & Mitigations
- **SwiftUI/UIViewController sync drift**: use a single store + strict reconciliation.
- **Interactive pop gestures**: UIKit delegate updates store on pop.
- **Excessive re-render**: store only route identifiers, keep view state outside navigation.

## Implementation Notes for Next Agent (V1)
1. Start with `NavigationCore` store and route abstractions.
2. Implement SwiftUI bridge first (pure SwiftUI tests easier).
3. Add UIKit coordinator and push sync.
4. Build Example App with xcodegen once core works.
5. Add breadcrumbs view + clipboard utility.
6. Add DeepLinkRegistry v1, then v4 extensions.

## Additional Feature (Optional)
**Route Debugger Panel**
- A lightweight overlay to inspect current stack, routes, and presentation state.
- Helps validate complex mixed navigation.

---
**Awaiting approval to proceed with implementation.**
