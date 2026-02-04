import SwiftUI
import UIKit

// MARK: - Introspection View ID

typealias IntrospectionViewID = UUID

// MARK: - Introspection Store

/// Storage for matching anchor and introspection view pairs
@MainActor
enum IntrospectionStore {
    nonisolated(unsafe) static var shared: [IntrospectionViewID: Pair] = [:]
    
    struct Pair {
        weak var controller: IntrospectionPlatformViewController?
        weak var anchor: IntrospectionAnchorPlatformViewController?
    }
}

// MARK: - Associated Object Keys

private nonisolated(unsafe) var introspectionControllerKey: UInt8 = 0
private nonisolated(unsafe) var isIntrospectionEntityKey: UInt8 = 0

extension UIView {
    var introspectionController: IntrospectionPlatformViewController? {
        get { objc_getAssociatedObject(self, &introspectionControllerKey) as? IntrospectionPlatformViewController }
        set { objc_setAssociatedObject(self, &introspectionControllerKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    var isIntrospectionEntity: Bool {
        get { objc_getAssociatedObject(self, &isIntrospectionEntityKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &isIntrospectionEntityKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

extension UIViewController {
    var isIntrospectionEntity: Bool {
        get { objc_getAssociatedObject(self, &isIntrospectionEntityKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &isIntrospectionEntityKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

// MARK: - Anchor View

/// Invisible anchor view placed in background to establish a reference point
struct IntrospectionAnchorView: UIViewControllerRepresentable {
    let id: IntrospectionViewID
    
    @MainActor
    func makeUIViewController(context: Context) -> IntrospectionAnchorPlatformViewController {
        print("🔵 [Introspect] IntrospectionAnchorView.makeUIViewController - id: \(id)")
        return IntrospectionAnchorPlatformViewController(id: id)
    }
    
    func updateUIViewController(_ uiViewController: IntrospectionAnchorPlatformViewController, context: Context) {
        print("🔵 [Introspect] IntrospectionAnchorView.updateUIViewController - id: \(id)")
    }
}

final class IntrospectionAnchorPlatformViewController: UIViewController {
    private let introspectionId: IntrospectionViewID
    
    init(id: IntrospectionViewID) {
        self.introspectionId = id
        super.init(nibName: nil, bundle: nil)
        self.isIntrospectionEntity = true
        IntrospectionStore.shared[id, default: .init()].anchor = self
        print("🔵 [Introspect] IntrospectionAnchorPlatformViewController.init - id: \(id)")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isIntrospectionEntity = true
        print("🔵 [Introspect] IntrospectionAnchorPlatformViewController.viewDidLoad - id: \(introspectionId)")
    }
}

// MARK: - Introspection View

/// Overlay view that traverses hierarchy to find target
struct IntrospectionView<Target: AnyObject>: UIViewControllerRepresentable {
    final class TargetCache {
        weak var target: Target?
    }
    
    let id: IntrospectionViewID
    let selector: @MainActor (IntrospectionPlatformViewController) -> Target?
    let customize: @MainActor (Target) -> Void
    
    func makeCoordinator() -> TargetCache {
        print("🟢 [Introspect] IntrospectionView.makeCoordinator - id: \(id)")
        return TargetCache()
    }
    
    @MainActor
    func makeUIViewController(context: Context) -> IntrospectionPlatformViewController {
        print("🟢 [Introspect] IntrospectionView.makeUIViewController - id: \(id)")
        return IntrospectionPlatformViewController(id: id) { controller in
            print("🟢 [Introspect] IntrospectionView handler called - id: \(id)")
            guard let target = selector(controller) else {
                print("🔴 [Introspect] IntrospectionView handler - selector returned nil!")
                return
            }
            print("🟢 [Introspect] IntrospectionView handler - found target: \(type(of: target))")
            context.coordinator.target = target
            customize(target)
            controller.handler = nil
        }
    }
    
    @MainActor
    func updateUIViewController(_ controller: IntrospectionPlatformViewController, context: Context) {
        print("🟢 [Introspect] IntrospectionView.updateUIViewController - id: \(id)")
        guard let target = context.coordinator.target ?? selector(controller) else {
            print("🔴 [Introspect] IntrospectionView.updateUIViewController - no target found")
            return
        }
        print("🟢 [Introspect] IntrospectionView.updateUIViewController - calling customize on: \(type(of: target))")
        customize(target)
    }
}

final class IntrospectionPlatformViewController: UIViewController {
    private let introspectionId: IntrospectionViewID
    var handler: (@MainActor () -> Void)?
    
    init(id: IntrospectionViewID, handler: (@MainActor (IntrospectionPlatformViewController) -> Void)?) {
        self.introspectionId = id
        super.init(nibName: nil, bundle: nil)
        self.handler = { [weak self] in
            guard let self else { return }
            handler?(self)
        }
        self.isIntrospectionEntity = true
        IntrospectionStore.shared[id, default: .init()].controller = self
        print("🟢 [Introspect] IntrospectionPlatformViewController.init - id: \(id)")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.introspectionController = self
        view.isIntrospectionEntity = true
        print("🟢 [Introspect] IntrospectionPlatformViewController.viewDidLoad - id: \(introspectionId), calling handler")
        handler?()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        print("🟢 [Introspect] IntrospectionPlatformViewController.didMove(toParent:) - parent: \(String(describing: parent)), calling handler")
        handler?()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("🟢 [Introspect] IntrospectionPlatformViewController.viewDidLayoutSubviews - calling handler")
        handler?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("🟢 [Introspect] IntrospectionPlatformViewController.viewDidAppear - calling handler")
        handler?()
    }
}
