/// An automation identifier owned by the view or feature that uses it.
///
/// UI tests locate elements through this type, keeping identifier definitions beside each feature
/// instead of in a central catalogue. Identifiers serve automation; VoiceOver speaks the label,
/// value, and traits described by ``PKYAccessibility``. Identifiers must be unique among visible
/// elements, so list-item identifiers should include the item's own ID.
///
/// String-backed enums conform without additional code: their raw value is the identifier.
public protocol PKYAccessibilityIdentifier {
    /// The value written to `accessibilityIdentifier` for UI-test matching.
    var identifier: String { get }
}

public extension PKYAccessibilityIdentifier where Self: RawRepresentable, RawValue == String {
    var identifier: String {
        rawValue
    }
}
