#if os(macOS)
    import AppKit
    import PockyFoundation
    import Testing

    struct PKYThemeMacOSTests {
        @Test(
            "S3-04/T01 The default theme uses the system control accent and fixed native typography"
        )
        func defaultThemeUsesSystemControlAccent() {
            let theme = PKYThemeFallback.system
            #expect(theme.color.accent(.primary).isEqual(NSColor.controlAccentColor))
            #expect(theme.color.accent(.secondary).isEqual(NSColor.controlAccentColor))
            #expect(theme.color.onAccent.isEqual(NSColor.white))
            guard case .fixed = theme.typography.scaling else {
                Issue.record("The macOS default theme must use fixed typography")
                return
            }
        }

        @Test("S3-04/T02 Every native semantic getter maps to the same macOS default-theme role")
        func semanticGettersUseDefaultThemeRoles() {
            let color = PKYThemeFallback.system.color
            for role in [
                PKYColorTheme.Content.Role.primary,
                .secondary,
                .tertiary,
                .quaternary,
                .placeholder,
            ] {
                #expect(NSColor.pkyContent(role).isEqual(color.content(role)))
            }
            for level in [PKYColorTheme.Background.Level.primary, .secondary, .tertiary] {
                #expect(
                    NSColor.pkyBackground(.standard(
                        level
                    )).isEqual(color.background.standard(level))
                )
                #expect(
                    NSColor.pkyBackground(.grouped(level)).isEqual(color.background.grouped(level))
                )
            }
            for level in [PKYColorTheme.Accent.Level.primary, .secondary] {
                #expect(NSColor.pkyAccent(level).isEqual(color.accent(level)))
            }
            for style in [PKYColorTheme.Separator.Style.standard, .opaque] {
                #expect(NSColor.pkySeparator(style).isEqual(color.separator(style)))
            }
            #expect(NSColor.pkyOnAccent.isEqual(color.onAccent))
            for role in [PKYColorTheme.Status.Role.destructive, .warning, .success] {
                #expect(NSColor.pkyStatus(role).isEqual(color.status(role)))
                #expect(NSColor.pkyOnStatus(role).isEqual(color.onStatus(role)))
            }
        }
    }
#endif
