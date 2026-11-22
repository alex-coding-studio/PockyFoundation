#if os(macOS)
    import AppKit

    public extension NSColor {
        static func pkyContent(_ role: PKYColorTheme.Content.Role) -> NSColor {
            PKYThemeFallback.system.color.content(role)
        }

        static func pkyBackground(_ role: PKYBackgroundRole) -> NSColor {
            let background = PKYThemeFallback.system.color.background
            switch role {
            case let .standard(level): return background.standard(level)
            case let .grouped(level): return background.grouped(level)
            }
        }

        static func pkyAccent(_ level: PKYColorTheme.Accent.Level) -> NSColor {
            PKYThemeFallback.system.color.accent(level)
        }

        static func pkySeparator(_ style: PKYColorTheme.Separator.Style) -> NSColor {
            PKYThemeFallback.system.color.separator(style)
        }

        static var pkyOnAccent: NSColor {
            PKYThemeFallback.system.color.onAccent
        }

        static func pkyStatus(_ role: PKYColorTheme.Status.Role) -> NSColor {
            PKYThemeFallback.system.color.status(role)
        }

        static func pkyOnStatus(_ role: PKYColorTheme.Status.Role) -> NSColor {
            PKYThemeFallback.system.color.onStatus(role)
        }
    }
#endif
