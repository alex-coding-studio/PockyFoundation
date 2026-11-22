#if os(iOS)
    import UIKit

    public extension UIColor {
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
