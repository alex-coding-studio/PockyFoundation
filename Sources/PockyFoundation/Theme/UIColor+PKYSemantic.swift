#if os(iOS)
    import UIKit

    public extension UIColor {
        /// Dynamically resolves an ordinary foreground role from the effective theme.
        static func pkyContent(_ role: PKYColorTheme.Content.Role) -> UIColor {
            .pkyTheme { theme, _ in theme.color.content(role) }
        }

        /// Dynamically resolves a background context and nesting level from the effective theme.
        static func pkyBackground(_ role: PKYBackgroundRole) -> UIColor {
            .pkyTheme { theme, _ in
                switch role {
                case let .standard(level): theme.color.background.standard(level)
                case let .grouped(level): theme.color.background.grouped(level)
                }
            }
        }

        /// Dynamically resolves a brand emphasis level from the effective theme.
        static func pkyAccent(_ level: PKYColorTheme.Accent.Level) -> UIColor {
            .pkyTheme { theme, _ in theme.color.accent(level) }
        }

        /// Dynamically resolves a separator role from the effective theme.
        static func pkySeparator(_ style: PKYColorTheme.Separator.Style) -> UIColor {
            .pkyTheme { theme, _ in theme.color.separator(style) }
        }

        /// The dynamic foreground paired with the solid primary accent in the effective theme.
        static var pkyOnAccent: UIColor {
            .pkyTheme { theme, _ in theme.color.onAccent }
        }

        /// Dynamically resolves destructive, warning, or success status colors from the effective theme.
        static func pkyStatus(_ role: PKYColorTheme.Status.Role) -> UIColor {
            .pkyTheme { theme, _ in theme.color.status(role) }
        }

        /// The foreground paired with a solid status surface of the same role in the effective theme.
        static func pkyOnStatus(_ role: PKYColorTheme.Status.Role) -> UIColor {
            .pkyTheme { theme, _ in theme.color.onStatus(role) }
        }
    }
#endif
