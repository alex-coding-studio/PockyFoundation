public protocol PKYAccessibilityIdentifier {
    var identifier: String { get }
}

public extension PKYAccessibilityIdentifier where Self: RawRepresentable, RawValue == String {
    var identifier: String {
        rawValue
    }
}
