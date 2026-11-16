#if os(iOS)
    import SwiftUI
    import UIKit

    /// Bridges the same immutable snapshot between UIKit traits and a SwiftUI environment.
    public struct PKYThemeEnvironmentKey: UITraitBridgedEnvironmentKey {
        public static let defaultValue: PKYThemeTraitValue? = nil

        public static func read(from traitCollection: UITraitCollection) -> PKYThemeTraitValue? {
            traitCollection.pkyTheme
        }

        public static func write(
            to mutableTraits: inout any UIMutableTraits,
            value: PKYThemeTraitValue?
        ) {
            mutableTraits.pkyTheme = value
        }
    }

    public extension EnvironmentValues {
        /// The effective rendering snapshot; local overrides do not change the root context or user preferences.
        var pkyTheme: PKYThemeTraitValue? {
            get { self[PKYThemeEnvironmentKey.self] }
            set { self[PKYThemeEnvironmentKey.self] = newValue }
        }

        /// Resolves a theme with UIKit's missing-injection policy, without implicitly creating a context.
        var pkyResolvedTheme: PKYTheme {
            UITraitCollection { $0.pkyTheme = pkyTheme }.pkyResolvedTheme
        }
    }
#endif
