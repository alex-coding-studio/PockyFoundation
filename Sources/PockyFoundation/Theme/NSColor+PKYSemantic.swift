#if os(macOS)
    import AppKit

    public extension NSColor {
        /// Resolves an ordinary foreground role from the macOS default theme.
        static func pkyContent(_ role: PKYColorTheme.Content.Role) -> NSColor {
            PKYThemeFallback.system.color.content(role)
        }

        /// Resolves a background context and nesting level from the macOS default theme.
        static func pkyBackground(_ role: PKYBackgroundRole) -> NSColor {
            let background = PKYThemeFallback.system.color.background
            switch role {
            case let .standard(level): return background.standard(level)
            case let .grouped(level): return background.grouped(level)
            }
        }

        /// Resolves a brand emphasis level from the macOS default theme's system control accent.
        static func pkyAccent(_ level: PKYColorTheme.Accent.Level) -> NSColor {
            PKYThemeFallback.system.color.accent(level)
        }

        /// Resolves a separator role from the macOS default theme.
        static func pkySeparator(_ style: PKYColorTheme.Separator.Style) -> NSColor {
            PKYThemeFallback.system.color.separator(style)
        }

        /// The foreground paired with the macOS default theme's primary accent.
        static var pkyOnAccent: NSColor {
            PKYThemeFallback.system.color.onAccent
        }

        /// Resolves a destructive, warning, or success color from the macOS default theme.
        static func pkyStatus(_ role: PKYColorTheme.Status.Role) -> NSColor {
            PKYThemeFallback.system.color.status(role)
        }

        /// The foreground paired with a solid status surface in the macOS default theme.
        static func pkyOnStatus(_ role: PKYColorTheme.Status.Role) -> NSColor {
            PKYThemeFallback.system.color.onStatus(role)
        }
    }
#endif
