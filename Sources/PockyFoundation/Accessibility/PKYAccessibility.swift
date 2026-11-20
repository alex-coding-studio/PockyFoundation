#if os(iOS)
    import UIKit

    /// The content VoiceOver speaks for an element.
    ///
    /// The label describes the element, the value describes its state, and the hint describes an action
    /// result that the label does not explain. Omit fields that do not apply: `pkyA11y(_:)` writes a nil
    /// label, hint, or value as cleared text so reused cells do not retain stale content, and UIKit then
    /// falls back to the element's defaults, such as a button title.
    public struct PKYAccessibilityDescription: Hashable, Sendable {
        /// Localized text describing the element.
        public var label: String?

        /// Localized text describing the result of activating the element.
        public var hint: String?

        /// Localized text describing the element's current state.
        public var value: String?

        /// Traits that replace the element's existing traits, for example `[.button, .selected]`.
        ///
        /// Nil preserves existing traits such as a button's `.button`. Elements whose traits change with
        /// state should supply traits for every state to replace the previous configuration.
        public var traits: UIAccessibilityTraits?

        /// Creates a description; omitted fields are nil.
        ///
        /// - Parameters:
        ///   - label: Localized text describing the element.
        ///   - hint: Localized text describing the result of activating the element.
        ///   - value: Localized text describing the element's current state.
        ///   - traits: Traits replacing the element's existing traits, or nil to preserve them.
        public init(
            label: String? = nil,
            hint: String? = nil,
            value: String? = nil,
            traits: UIAccessibilityTraits? = nil
        ) {
            self.label = label
            self.hint = hint
            self.value = value
            self.traits = traits
        }
    }

    /// An automation identifier and the VoiceOver description of the element that uses it.
    ///
    /// Conform from a type that already owns the element's data, such as a feature enum or list-item
    /// structure, and apply it with `pkyA11y(_:)`. Use its ``PKYAccessibilityIdentifier`` so the app and
    /// UI tests share one definition.
    public protocol PKYAccessibility: PKYAccessibilityIdentifier {
        /// The VoiceOver content written together with the identifier.
        var accessibility: PKYAccessibilityDescription { get }
    }
#endif
