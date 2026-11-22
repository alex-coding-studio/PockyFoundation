#if os(iOS)
    import UIKit

    public extension UIAccessibilityIdentification {
        @MainActor
        @discardableResult
        func pkyA11y(_ id: some PKYAccessibilityIdentifier) -> Self {
            accessibilityIdentifier = id.identifier
            return self
        }
    }

    public extension UIAccessibilityIdentification where Self: NSObject {
        @MainActor
        @discardableResult
        func pkyA11y(_ a11y: some PKYAccessibility) -> Self {
            let content = a11y.accessibility
            accessibilityIdentifier = a11y.identifier
            accessibilityLabel = content.label
            accessibilityHint = content.hint
            accessibilityValue = content.value
            if let traits = content.traits {
                accessibilityTraits = traits
            }
            return self
        }
    }
#endif
