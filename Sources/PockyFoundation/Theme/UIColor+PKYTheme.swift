#if os(iOS)
    import UIKit

    public extension UIColor {
        /// Resolves a color from the requesting traits and theme, without capturing the theme at creation.
        ///
        /// Compute derived colors inside the provider. Missing injection returns the Debug diagnostic
        /// color or logs a Release fault and uses the emergency theme. Debug shows magenta rather than
        /// trapping because UIKit resolves dynamic colors later during rendering, where a trap's stack
        /// would not point at the uninjected hierarchy.
        ///
        /// - Parameter resolve: A pure color calculation; do not access views, mutable contexts, storage, or services.
        static func pkyTheme(
            _ resolve: @escaping @Sendable (PKYTheme, UITraitCollection) -> UIColor
        ) -> UIColor {
            UIColor { traits in
                guard let snapshot = traits.pkyTheme else {
                    #if DEBUG
                        return .magenta
                    #else
                        PKYThemeDiagnostics.reportMissingInjection()
                        return resolve(PKYThemeFallback.system, traits).resolvedColor(with: traits)
                    #endif
                }
                return resolve(snapshot.theme, traits).resolvedColor(with: traits)
            }
        }
    }
#endif
