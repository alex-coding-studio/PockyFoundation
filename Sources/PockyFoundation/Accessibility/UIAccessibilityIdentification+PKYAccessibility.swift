#if os(iOS)
    import UIKit

    public extension UIAccessibilityIdentification {
        /// Sets an automation identifier and returns the same object with its concrete type for chaining.
        ///
        /// Supports views, bar button items, actions, menus, and alert actions. Use this when the control
        /// provides its own VoiceOver text, such as a titled `UIAction`; use the ``PKYAccessibility``
        /// overload when the element also needs a description.
        @MainActor
        @discardableResult
        func pkyA11y(_ id: some PKYAccessibilityIdentifier) -> Self {
            accessibilityIdentifier = id.identifier
            return self
        }
    }

    public extension UIAccessibilityIdentification where Self: NSObject {
        /// Writes the identifier and description, returning the same object for chaining.
        ///
        /// Nil label, hint, or value clears text from an earlier call or cell configuration. Nil traits
        /// preserve the element's existing traits; see ``PKYAccessibilityDescription/traits``.
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
