#if os(iOS)
    import SwiftUI
    import UIKit

    /// Bridges the same immutable snapshot between UIKit traits and a SwiftUI environment.
    public struct PKYThemeEnvironmentKey: UITraitBridgedEnvironmentKey {
        /// No snapshot outside an injected hierarchy, matching ``PKYThemeTrait/defaultValue``.
        public static let defaultValue: PKYThemeTraitValue? = nil

        /// Reads the snapshot injected into the hosting UIKit traits.
        public static func read(from traitCollection: UITraitCollection) -> PKYThemeTraitValue? {
            traitCollection.pkyTheme
        }

        /// Writes a SwiftUI environment override into the bridged UIKit traits.
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
