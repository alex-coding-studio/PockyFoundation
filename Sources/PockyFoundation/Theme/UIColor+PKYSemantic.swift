#if os(iOS)
    import UIKit

    public extension UIColor {
        static func pkyContent(_ role: PKYColorTheme.Content.Role) -> UIColor {
            .pkyTheme { theme, _ in theme.color.content(role) }
        }

        static func pkyBackground(_ role: PKYBackgroundRole) -> UIColor {
            .pkyTheme { theme, _ in
                switch role {
                case let .standard(level): theme.color.background.standard(level)
                case let .grouped(level): theme.color.background.grouped(level)
                }
            }
        }

        static func pkyAccent(_ level: PKYColorTheme.Accent.Level) -> UIColor {
            .pkyTheme { theme, _ in theme.color.accent(level) }
        }

        static func pkySeparator(_ style: PKYColorTheme.Separator.Style) -> UIColor {
            .pkyTheme { theme, _ in theme.color.separator(style) }
        }

        static var pkyOnAccent: UIColor {
            .pkyTheme { theme, _ in theme.color.onAccent }
        }

        static func pkyStatus(_ role: PKYColorTheme.Status.Role) -> UIColor {
            .pkyTheme { theme, _ in theme.color.status(role) }
        }

        static func pkyOnStatus(_ role: PKYColorTheme.Status.Role) -> UIColor {
            .pkyTheme { theme, _ in theme.color.onStatus(role) }
        }
    }
#endif
