#if os(iOS)
    import UIKit

    public extension UIAccessibilityIdentification {
        /// Sets or clears an automation identifier and returns the same concrete object for chaining.
        ///
        /// Prefer `pkyA11y(_:)` with a ``PKYAccessibilityIdentifier`` to avoid string literals.
        @MainActor
        func pkyA11yID(_ identifier: String?) -> Self {
            guard let identifier else {
                accessibilityIdentifier = nil
                return self
            }
            return pkyA11y(RawIdentifier(identifier: identifier))
        }
    }

    private struct RawIdentifier: PKYAccessibilityIdentifier {
        let identifier: String
    }
#endif
