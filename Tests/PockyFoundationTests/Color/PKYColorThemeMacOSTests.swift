#if os(macOS)
    import AppKit
    import PockyFoundation
    import Testing

    @MainActor
    struct PKYColorThemeMacOSTests {
        private let accent = PKYColorTheme.Accent(
            primary: .systemRed,
            secondary: .systemBlue,
            onAccent: .white
        )

        @Test("S1-03/T01 System color roles map to their native AppKit semantics")
        func systemRolesMapToAppKit() {
            let theme = PKYColorTheme.system(accent: accent)
            let backgrounds: [(PKYColorTheme.Background.Level, NSColor)] = [
                (.primary, .windowBackgroundColor),
                (.secondary, .controlBackgroundColor),
                (.tertiary, .underPageBackgroundColor),
            ]
            for (level, native) in backgrounds {
                #expect(theme.background.standard(level).isEqual(native))
                #expect(theme.background.grouped(level).isEqual(theme.background.standard(level)))
            }
            let content: [(PKYColorTheme.Content.Role, NSColor)] = [
                (.primary, .labelColor),
                (.secondary, .secondaryLabelColor),
                (.tertiary, .tertiaryLabelColor),
                (.quaternary, .quaternaryLabelColor),
                (.placeholder, .placeholderTextColor),
            ]
            for (role, native) in content {
                #expect(theme.content(role).isEqual(native))
            }
            let quiet: [(PKYColorTheme.Filled.QuietLevel, NSColor)] = [
                (.primary, .systemFill),
                (.secondary, .secondarySystemFill),
                (.tertiary, .tertiarySystemFill),
                (.quaternary, .quaternarySystemFill),
            ]
            for (level, native) in quiet {
                #expect(theme.filled.quiet(level).isEqual(native))
            }
            #expect(theme.filled.prominent(.primary).isEqual(NSColor.labelColor))
            #expect(theme.filled.prominent(.secondary).isEqual(NSColor.secondaryLabelColor))
            for level in [PKYColorTheme.Filled.ProminentLevel.primary, .secondary] {
                #expect(theme.filled.onProminent(level).isEqual(NSColor.windowBackgroundColor))
            }
            #expect(theme.separator(.standard).isEqual(NSColor.separatorColor))
            #expect(theme.separator(.opaque).isEqual(NSColor.gridColor))
            let status: [(PKYColorTheme.Status.Role, NSColor)] = [
                (.destructive, .systemRed),
                (.warning, .systemOrange),
                (.success, .systemGreen),
            ]
            for (role, native) in status {
                #expect(theme.status(role).isEqual(native))
                #expect(theme.onStatus(role).isEqual(NSColor.white))
            }
            #expect(theme.media.placeholder.isEqual(NSColor.quaternarySystemFill))
            #expect(theme.media.content.isEqual(NSColor.white))
            #expect(theme.media.contentShadow.isEqual(NSColor.black))
            #expect(theme.media.scrim.isEqual(NSColor.black))
            #expect(
                theme.media.focusScrim.isEqual(
                    NSColor.black.withAlphaComponent(PKYOpacity.focusScrim)
                )
            )
            #expect(theme.shadow.isEqual(NSColor.black))
        }

        @Test("S1-03/T02 System themes retain each caller-supplied accent color")
        func systemThemeKeepsSuppliedAccent() {
            let theme = PKYColorTheme.system(accent: accent)
            let primary = PKYColor.systemRed
            let secondary = NSColor.systemBlue
            #expect(theme.accent(.primary).isEqual(primary))
            #expect(theme.accent(.secondary).isEqual(secondary))
            #expect(theme.onAccent.isEqual(NSColor.white))
        }

        @Test("S1-03/T03 Content levels remain distinct and backgrounds follow native appearance")
        func contentAndBackgroundResolveAppearanceRelationships() throws {
            let theme = PKYColorTheme.system(accent: accent)
            for name in [NSAppearance.Name.aqua, .darkAqua] {
                let appearance = try #require(NSAppearance(named: name))
                let primary = try resolved(theme.content(.primary), in: appearance)
                let secondary = try resolved(theme.content(.secondary), in: appearance)
                let tertiary = try resolved(theme.content(.tertiary), in: appearance)
                #expect(!primary.isEqual(secondary))
                #expect(!primary.isEqual(tertiary))
                #expect(!secondary.isEqual(tertiary))
                for level in [PKYColorTheme.Background.Level.primary, .secondary, .tertiary] {
                    #expect(try resolved(theme.background.standard(level), in: appearance)
                        .isEqual(resolved(theme.background.grouped(level), in: appearance)))
                }
            }
            let light = try #require(NSAppearance(named: .aqua))
            let dark = try #require(NSAppearance(named: .darkAqua))
            #expect(try !resolved(theme.background.standard(.primary), in: light)
                .isEqual(resolved(theme.background.standard(.primary), in: dark)))
        }

        @Test("S1-04/T01 Inverse and on-inverse reverse luminance between aqua and darkAqua")
        func inversePairReversesWithAppearance() throws {
            let light = try #require(NSAppearance(named: .aqua))
            let dark = try #require(NSAppearance(named: .darkAqua))
            let lightFill = try resolved(PKYStandardInverse.inverse, in: light)
            let lightContent = try resolved(PKYStandardInverse.onInverse, in: light)
            let darkFill = try resolved(PKYStandardInverse.inverse, in: dark)
            let darkContent = try resolved(PKYStandardInverse.onInverse, in: dark)
            #expect(luminance(lightFill) < luminance(lightContent))
            #expect(luminance(darkFill) > luminance(darkContent))
            #expect(!lightFill.isEqual(darkFill))
            #expect(!lightContent.isEqual(darkContent))
            #expect(lightFill.isEqual(darkContent))
            #expect(lightContent.isEqual(darkFill))
            let theme = PKYColorTheme.system(accent: accent)
            #expect(try resolved(theme.inverse, in: light).isEqual(lightFill))
            #expect(try resolved(theme.onInverse, in: dark).isEqual(darkContent))
        }

        private func resolved(_ color: NSColor, in appearance: NSAppearance) throws -> NSColor {
            var result: NSColor?
            appearance.performAsCurrentDrawingAppearance {
                result = color.usingColorSpace(.sRGB)
            }
            return try #require(result)
        }

        private func luminance(_ color: NSColor) -> CGFloat {
            let linear = [color.redComponent, color.greenComponent, color.blueComponent].map { channel in
                channel <= 0.04045 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]
        }
    }
#endif
