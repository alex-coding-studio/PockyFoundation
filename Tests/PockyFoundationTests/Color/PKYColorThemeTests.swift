#if os(iOS)
    import PockyFoundation
    import Testing
    import UIKit

    @MainActor
    struct PKYColorThemeTests {
        static let accent = PKYColorTheme.Accent(
            primary: .systemMint,
            secondary: .systemTeal,
            onAccent: .white
        )

        static let appearanceEnvironments: [UITraitCollection] = [
            UIUserInterfaceStyle.light,
            .dark,
        ].flatMap { style in
            [UIAccessibilityContrast.normal, .high].map { contrast in
                UITraitCollection { traits in
                    traits.userInterfaceStyle = style
                    traits.accessibilityContrast = contrast
                }
            }
        }

        static func makeColorTheme(
            contentPrimary: UIColor = .black,
            accent: PKYColorTheme.Accent = accent
        ) -> PKYColorTheme {
            PKYColorTheme(
                background: .init(
                    standard: .init(primary: .red, secondary: .orange, tertiary: .yellow),
                    grouped: .init(primary: .green, secondary: .blue, tertiary: .purple)
                ),
                content: .init(
                    primary: contentPrimary,
                    secondary: .darkGray,
                    tertiary: .gray,
                    quaternary: .lightGray,
                    placeholder: .brown
                ),
                filled: .init(
                    quiet: .init(
                        primary: .cyan,
                        secondary: .magenta,
                        tertiary: .systemPink,
                        quaternary: .systemIndigo
                    ),
                    prominent: .init(
                        primary: .systemBrown,
                        onPrimary: .systemCyan,
                        secondary: .systemGreen,
                        onSecondary: .systemPurple
                    )
                ),
                separator: .init(standard: .systemGray, opaque: .white),
                accent: accent,
                status: .init(
                    destructive: .systemRed,
                    onDestructive: .systemYellow,
                    warning: .systemOrange,
                    onWarning: .systemTeal,
                    success: .systemMint,
                    onSuccess: .darkText
                ),
                media: .init(
                    placeholder: .lightText,
                    content: .white,
                    contentShadow: .black,
                    scrim: .clear,
                    focusScrim: .systemGray2
                ),
                shadow: .systemGray4
            )
        }

        static func contrastRatio(_ first: UIColor, _ second: UIColor) -> CGFloat {
            let luminances = [first, second].map(relativeLuminance).sorted(by: >)
            return (luminances[0] + 0.05) / (luminances[1] + 0.05)
        }

        static func relativeLuminance(_ color: UIColor) -> CGFloat {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let linear = [red, green, blue].map { channel in
                channel <= 0.04045 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]
        }

        @Test("Explicit color families resolve their independently supplied roles")
        func explicitRolesResolveIndependentColors() {
            let theme = Self.makeColorTheme()

            #expect(theme.background.standard(.primary).isEqual(UIColor.red))
            #expect(theme.background.standard(.secondary).isEqual(UIColor.orange))
            #expect(theme.background.standard(.tertiary).isEqual(UIColor.yellow))
            #expect(theme.background.grouped(.primary).isEqual(UIColor.green))
            #expect(theme.background.grouped(.secondary).isEqual(UIColor.blue))
            #expect(theme.background.grouped(.tertiary).isEqual(UIColor.purple))

            #expect(theme.content(.primary).isEqual(UIColor.black))
            #expect(theme.content(.secondary).isEqual(UIColor.darkGray))
            #expect(theme.content(.tertiary).isEqual(UIColor.gray))
            #expect(theme.content(.quaternary).isEqual(UIColor.lightGray))
            #expect(theme.content(.placeholder).isEqual(UIColor.brown))

            #expect(theme.filled.quiet(.primary).isEqual(UIColor.cyan))
            #expect(theme.filled.quiet(.secondary).isEqual(UIColor.magenta))
            #expect(theme.filled.quiet(.tertiary).isEqual(UIColor.systemPink))
            #expect(theme.filled.quiet(.quaternary).isEqual(UIColor.systemIndigo))
            #expect(theme.filled.prominent(.primary).isEqual(UIColor.systemBrown))
            #expect(theme.filled.onProminent(.primary).isEqual(UIColor.systemCyan))
            #expect(theme.filled.prominent(.secondary).isEqual(UIColor.systemGreen))
            #expect(theme.filled.onProminent(.secondary).isEqual(UIColor.systemPurple))

            #expect(theme.separator(.standard).isEqual(UIColor.systemGray))
            #expect(theme.separator(.opaque).isEqual(UIColor.white))
        }

        @Test("System themes preserve UIKit dynamic semantic colors")
        func systemThemeMapsUIKitSemanticColors() {
            let theme = PKYColorTheme.system(accent: Self.accent)

            #expect(theme.background.standard(.primary).isEqual(UIColor.systemBackground))
            #expect(
                theme.background.standard(.secondary).isEqual(UIColor.secondarySystemBackground)
            )
            #expect(theme.background.standard(.tertiary).isEqual(UIColor.tertiarySystemBackground))
            #expect(theme.background.grouped(.primary).isEqual(UIColor.systemGroupedBackground))
            #expect(
                theme.background.grouped(.secondary).isEqual(
                    UIColor.secondarySystemGroupedBackground
                )
            )
            #expect(
                theme.background.grouped(.tertiary).isEqual(UIColor.tertiarySystemGroupedBackground)
            )

            #expect(theme.content(.primary).isEqual(UIColor.label))
            #expect(theme.content(.secondary).isEqual(UIColor.secondaryLabel))
            #expect(theme.content(.tertiary).isEqual(UIColor.tertiaryLabel))
            #expect(theme.content(.quaternary).isEqual(UIColor.quaternaryLabel))
            #expect(theme.content(.placeholder).isEqual(UIColor.placeholderText))

            #expect(theme.filled.quiet(.primary).isEqual(UIColor.systemFill))
            #expect(theme.filled.quiet(.secondary).isEqual(UIColor.secondarySystemFill))
            #expect(theme.filled.quiet(.tertiary).isEqual(UIColor.tertiarySystemFill))
            #expect(theme.filled.quiet(.quaternary).isEqual(UIColor.quaternarySystemFill))
            #expect(theme.filled.prominent(.primary).isEqual(UIColor.label))
            #expect(theme.filled.onProminent(.primary).isEqual(UIColor.systemBackground))
            #expect(theme.filled.onProminent(.secondary).isEqual(UIColor.systemBackground))

            #expect(theme.separator(.standard).isEqual(UIColor.separator))
            #expect(theme.separator(.opaque).isEqual(UIColor.opaqueSeparator))
        }

        @Test("Themes retain independent primary, secondary, and on-accent identity colors")
        func accentResolvesIndependentIdentityColors() {
            let accent = PKYColorTheme.Accent(
                primary: .systemRed,
                secondary: .systemOrange,
                onAccent: .systemYellow
            )
            let theme = Self.makeColorTheme(accent: accent)

            #expect(theme.accent(.primary).isEqual(UIColor.systemRed))
            #expect(theme.accent(.secondary).isEqual(UIColor.systemOrange))
            #expect(theme.onAccent.isEqual(UIColor.systemYellow))
        }

        @Test("System themes use all three app-supplied identity colors")
        func systemThemeUsesSuppliedIdentityColors() {
            let theme = PKYColorTheme.system(accent: Self.accent)

            #expect(theme.accent(.primary).isEqual(UIColor.systemMint))
            #expect(theme.accent(.secondary).isEqual(UIColor.systemTeal))
            #expect(theme.onAccent.isEqual(UIColor.white))
        }

        @Test("Secondary prominent fill uses systemGray3 from the opposite appearance")
        func systemProminentSecondaryUsesOppositeStyleGray() {
            let secondary = PKYColorTheme.system(accent: Self.accent).filled.prominent(.secondary)

            for traits in Self.appearanceEnvironments {
                let opposite: UIUserInterfaceStyle = traits.userInterfaceStyle == .dark ? .light : .dark
                let expected = UIColor.systemGray3.resolvedColor(
                    with: traits.modifyingTraits { $0.userInterfaceStyle = opposite }
                )
                #expect(secondary.resolvedColor(with: traits).isEqual(expected))
            }
        }

        @Test("System prominent pairs are opaque with at least 4.5:1 contrast")
        func systemProminentPairsAreOpaqueAndLegible() {
            let filled = PKYColorTheme.system(accent: Self.accent).filled

            for traits in Self.appearanceEnvironments {
                for level in [PKYColorTheme.Filled.ProminentLevel.primary, .secondary] {
                    let fill = filled.prominent(level).resolvedColor(with: traits)
                    let content = filled.onProminent(level).resolvedColor(with: traits)

                    #expect(fill.cgColor.alpha == 1)
                    #expect(Self.contrastRatio(fill, content) >= 4.5)
                }
            }
        }

        @Test("Default inverse pairs are opaque with at least 7:1 contrast in both appearances")
        func defaultInversePairIsOpaqueWithStrongContrast() {
            let theme = PKYColorTheme.system(accent: Self.accent)
            for traits in Self.appearanceEnvironments {
                let fill = theme.inverse.resolvedColor(with: traits)
                let content = theme.onInverse.resolvedColor(with: traits)

                #expect(fill.cgColor.alpha == 1)
                #expect(Self.contrastRatio(fill, content) >= 7)
            }
        }

        @Test("Status, media, and shadows resolve their independently supplied colors")
        func statusMediaAndShadowResolveIndependentColors() {
            let theme = Self.makeColorTheme()

            #expect(theme.status(.destructive).isEqual(UIColor.systemRed))
            #expect(theme.onStatus(.destructive).isEqual(UIColor.systemYellow))
            #expect(theme.status(.warning).isEqual(UIColor.systemOrange))
            #expect(theme.onStatus(.warning).isEqual(UIColor.systemTeal))
            #expect(theme.status(.success).isEqual(UIColor.systemMint))
            #expect(theme.onStatus(.success).isEqual(UIColor.darkText))

            #expect(theme.media.placeholder.isEqual(UIColor.lightText))
            #expect(theme.media.content.isEqual(UIColor.white))
            #expect(theme.media.contentShadow.isEqual(UIColor.black))
            #expect(theme.media.scrim.isEqual(UIColor.clear))
            #expect(theme.media.focusScrim.isEqual(UIColor.systemGray2))

            #expect(theme.shadow.isEqual(UIColor.systemGray4))
        }

        @Test(
            "System status, media, and shadows map to Apple colors and the shared focus scrim role"
        )
        func systemThemeMapsStatusMediaAndShadow() {
            let theme = PKYColorTheme.system(accent: Self.accent)

            #expect(theme.status(.destructive).isEqual(UIColor.systemRed))
            #expect(theme.status(.warning).isEqual(UIColor.systemOrange))
            #expect(theme.status(.success).isEqual(UIColor.systemGreen))
            for role in [PKYColorTheme.Status.Role.destructive, .warning, .success] {
                #expect(theme.onStatus(role).isEqual(UIColor.white))
            }

            #expect(theme.media.placeholder.isEqual(UIColor.systemGray5))
            #expect(theme.media.content.isEqual(UIColor.white))
            #expect(theme.media.contentShadow.isEqual(UIColor.black))
            #expect(theme.media.scrim.isEqual(UIColor.black))
            #expect(
                theme.media.focusScrim.isEqual(
                    UIColor.black.withAlphaComponent(PKYOpacity.focusScrim)
                )
            )
            #expect(theme.shadow.isEqual(UIColor.black))
        }
    }
#endif
