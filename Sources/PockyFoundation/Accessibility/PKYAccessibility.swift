#if os(iOS)
    import UIKit

    /// A complete accessibility description: an automation identifier and content spoken by VoiceOver.
    ///
    /// Apply it with `pkyA11y(_:)`, which writes every field. A nil label, hint, or value clears previous
    /// text so reused cells do not retain stale content; UIKit then falls back to the element's defaults,
    /// such as a button title. The label describes the element, the value describes its state, and the
    /// hint describes an action result that the label does not explain.
    ///
    /// Conform from a type that already owns the element's data, such as a feature enum or list-item
    /// structure. Use its ``PKYAccessibilityIdentifier`` so the app and UI tests share one definition.
    ///
    /// Declare these properties with optional types. A nonoptional `label: String` or
    /// `traits: UIAccessibilityTraits` does not satisfy the requirement; the compiler silently uses
    /// the default nil implementation instead.
    public protocol PKYAccessibility: PKYAccessibilityIdentifier {
        /// Localized text describing the element. Defaults to nil.
        var label: String? { get }

        /// Localized text describing the result of activating the element. Defaults to nil.
        var hint: String? { get }

        /// Localized text describing the element's current state. Defaults to nil.
        var value: String? { get }

        /// Replaces existing traits, for example with `[.button, .selected]`.
        ///
        /// Defaults to nil, preserving UIKit traits such as a button's `.button`. Elements whose traits
        /// change with state should supply a value for every state to replace the previous configuration.
        var traits: UIAccessibilityTraits? { get }
    }

    public extension PKYAccessibility {
        var label: String? {
            nil
        }

        var hint: String? {
            nil
        }

        var value: String? {
            nil
        }

        var traits: UIAccessibilityTraits? {
            nil
        }
    }
#endif
