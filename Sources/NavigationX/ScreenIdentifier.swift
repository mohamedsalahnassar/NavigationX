import Foundation

/// A universal identifier for any screen in the navigation stack.
public struct ScreenIdentifier: Hashable, Identifiable, Codable {
    public let id: String
    public let name: String
    
    public init(name: String, id: String = UUID().uuidString) {
        self.name = name
        self.id = id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: ScreenIdentifier, rhs: ScreenIdentifier) -> Bool {
        lhs.id == rhs.id
    }
}
