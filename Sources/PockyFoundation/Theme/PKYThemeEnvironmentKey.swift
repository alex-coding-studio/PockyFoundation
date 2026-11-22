#if os(iOS)
    import SwiftUI
    import UIKit

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
        var pkyTheme: PKYThemeTraitValue? {
            get { self[PKYThemeEnvironmentKey.self] }
            set { self[PKYThemeEnvironmentKey.self] = newValue }
        }

        @available(
            *,
            deprecated,
            message: "Read @Environment(\\.pkyTheme) and resolve it in body with pkyResolvedTheme."
        )
        var pkyResolvedTheme: PKYTheme {
            pkyTheme.pkyResolvedTheme
        }
    }
#endif
