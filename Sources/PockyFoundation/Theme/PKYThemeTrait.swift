#if os(iOS)
    import Foundation
    import UIKit

    public struct PKYThemeTrait: UITraitDefinition {
        public static let defaultValue: PKYThemeTraitValue? = nil
        public static let affectsColorAppearance = true
    }

    public struct PKYThemeTraitValue: Equatable, Sendable {
        public let theme: PKYTheme

        private let identity = UUID()

        public init(theme: PKYTheme) {
            self.theme = theme
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.identity == rhs.identity
        }
    }

    public extension UITraitCollection {
        var pkyTheme: PKYThemeTraitValue? {
            self[PKYThemeTrait.self]
        }

        var pkyResolvedTheme: PKYTheme {
            pkyTheme.pkyResolvedTheme
        }
    }

    public extension PKYThemeTraitValue? {
        var pkyResolvedTheme: PKYTheme {
            if let snapshot = self {
                return snapshot.theme
            }
            #if DEBUG
                preconditionFailure("Missing PKYThemeTrait injection")
            #else
                PKYThemeDiagnostics.reportMissingInjection()
                return PKYThemeFallback.system
            #endif
        }
    }

    public extension UIMutableTraits {
        var pkyTheme: PKYThemeTraitValue? {
            get { self[PKYThemeTrait.self] }
            set { self[PKYThemeTrait.self] = newValue }
        }
    }
#endif
