#if os(iOS)
    import Foundation
    import UIKit

    /// Distributes an immutable theme through the view tree; missing injection stays nil and invalidates dynamic colors.
    public struct PKYThemeTrait: UITraitDefinition {
        /// No snapshot outside an injected hierarchy, so missing injection stays detectable.
        public static let defaultValue: PKYThemeTraitValue? = nil
        /// Theme changes re-resolve dynamic colors like other appearance traits.
        public static let affectsColorAppearance = true
    }

    /// An immutable theme activation snapshot whose copies retain identity without resolving colors or fonts.
    public struct PKYThemeTraitValue: Equatable, Sendable {
        /// The complete theme recipe for this activation.
        public let theme: PKYTheme

        private let identity = UUID()

        /// Creates a new theme activation snapshot.
        public init(theme: PKYTheme) {
            self.theme = theme
        }

        /// Compares activation identity rather than theme contents: copies of one snapshot are equal,
        /// while separate activations of the same theme are not.
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.identity == rhs.identity
        }
    }

    public extension UITraitCollection {
        /// The snapshot explicitly injected in this hierarchy, or nil when none is injected.
        var pkyTheme: PKYThemeTraitValue? {
            self[PKYThemeTrait.self]
        }

        /// Resolves the current theme: Debug diagnoses missing injection; Release logs a fault and uses the emergency recipe.
        ///
        /// Debug traps here because callers resolve synchronously, so the stack points at the uninjected
        /// hierarchy. Dynamic colors resolve later during rendering and show magenta instead. Previews and
        /// tests inject a theme like the app does; see ``PKYThemeTraitValue``.
        var pkyResolvedTheme: PKYTheme {
            if let pkyTheme {
                return pkyTheme.theme
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
        /// Injects or clears this hierarchy's theme snapshot without changing the app's selected theme.
        var pkyTheme: PKYThemeTraitValue? {
            get { self[PKYThemeTrait.self] }
            set { self[PKYThemeTrait.self] = newValue }
        }
    }
#endif
