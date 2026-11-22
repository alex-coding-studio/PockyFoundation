#if os(iOS)
    import UIKit

    public struct PKYAccessibilityDescription: Hashable, Sendable {
        public var label: String?

        public var hint: String?

        public var value: String?

        public var traits: UIAccessibilityTraits?

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

    public protocol PKYAccessibility: PKYAccessibilityIdentifier {
        var accessibility: PKYAccessibilityDescription { get }
    }
#endif
