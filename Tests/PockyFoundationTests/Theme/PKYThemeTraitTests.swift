#if os(iOS)
    import Testing
    import UIKit
    @testable import PockyFoundation

    @MainActor
    struct PKYThemeTraitTests {
        @Test("Snapshot copies retain identity while activation replaces only the current snapshot")
        func activationPublishesImmutableSnapshot() {
            let initial = PKYThemeContextTests.makeTheme(contentPrimary: .red)
            let replacement = PKYThemeContextTests.makeTheme(contentPrimary: .blue)
            let context = PKYThemeContext(theme: initial)
            let previous = context.themeTraitValue
            #expect(previous == context.themeTraitValue)
            context.activate(theme: replacement)
            #expect(previous != context.themeTraitValue)
            #expect(previous.theme.color.content(.primary).isEqual(initial.color.content(.primary)))
            #expect(
                context.theme.color.content(.primary).isEqual(replacement.color.content(.primary))
            )
        }

        @Test("Dynamic colors resolve from supplied traits without freezing derived colors")
        func dynamicColorUsesSuppliedTraits() {
            let first = PKYThemeTraitValue(
                theme: PKYThemeContextTests.makeTheme(contentPrimary: .red)
            )
            let second = PKYThemeTraitValue(
                theme: PKYThemeContextTests.makeTheme(contentPrimary: .blue)
            )
            let color = UIColor.pkyTheme { theme, traits in
                theme.color.content(.primary).resolvedColor(with: traits).withAlphaComponent(
                    PKYOpacity.tint
                )
            }
            let firstTraits = UITraitCollection { $0.pkyTheme = first }
            let secondTraits = UITraitCollection { $0.pkyTheme = second }
            #expect(
                color.resolvedColor(with: firstTraits).isEqual(
                    first.theme.color.content(.primary).resolvedColor(
                        with: firstTraits
                    ).withAlphaComponent(PKYOpacity.tint)
                )
            )
            #expect(
                color.resolvedColor(with: secondTraits).isEqual(
                    second.theme.color.content(.primary).resolvedColor(
                        with: secondTraits
                    ).withAlphaComponent(PKYOpacity.tint)
                )
            )
            #expect(UITraitCollection().pkyTheme == nil)

            let adaptive = UIColor { traits in traits.userInterfaceStyle == .dark ? .white : .black }
            let adaptiveSnapshot = PKYThemeTraitValue(
                theme: PKYThemeContextTests.makeTheme(contentPrimary: adaptive)
            )
            let light = UITraitCollection { traits in
                traits.pkyTheme = adaptiveSnapshot
                traits.userInterfaceStyle = .light
            }
            let dark = light.modifyingTraits { $0.userInterfaceStyle = .dark }
            #expect(
                color.resolvedColor(with: light).isEqual(
                    adaptive.resolvedColor(with: light).withAlphaComponent(PKYOpacity.tint)
                )
            )
            #expect(
                color.resolvedColor(with: dark).isEqual(
                    adaptive.resolvedColor(with: dark).withAlphaComponent(PKYOpacity.tint)
                )
            )
            #if DEBUG
                let diagnostic = UIColor.pkyTheme { _, _ in
                    Issue.record(
                        "Missing injection must not execute the actual theme color resolver"
                    )
                    return .clear
                }
                _ = diagnostic.resolvedColor(with: UITraitCollection())
            #endif
        }

        @Test("Semantic color shorthands resolve each role from the theme in the supplied traits")
        func semanticShorthandsResolveSuppliedThemeRoles() {
            let themes = [
                PKYThemeContextTests.makeTheme(contentPrimary: .red),
                PKYThemeFallback.system,
            ]
            for theme in themes {
                let traits = UITraitCollection { $0.pkyTheme = PKYThemeTraitValue(theme: theme) }
                let color = theme.color
                let pairs: [(UIColor, UIColor)] = [
                    (.pkyContent(.primary), color.content(.primary)),
                    (.pkyContent(.placeholder), color.content(.placeholder)),
                    (.pkyBackground(.standard(.tertiary)), color.background.standard(.tertiary)),
                    (.pkyBackground(.grouped(.secondary)), color.background.grouped(.secondary)),
                    (.pkyAccent(.primary), color.accent(.primary)),
                    (.pkyAccent(.secondary), color.accent(.secondary)),
                    (.pkySeparator(.standard), color.separator(.standard)),
                    (.pkySeparator(.opaque), color.separator(.opaque)),
                    (.pkyOnAccent, color.onAccent),
                    (.pkyStatus(.destructive), color.status(.destructive)),
                    (.pkyOnStatus(.destructive), color.onStatus(.destructive)),
                ]
                for (shorthand, role) in pairs {
                    let expected = role.resolvedColor(with: traits)
                    #expect(shorthand.resolvedColor(with: traits).isEqual(expected))
                }
            }
        }

        @Test("Typography roles remain unresolved until the current theme supplies their policy")
        func typographyRoleRemainsUnresolved() {
            let role = PKYTypographyRole.heading.bold.rounded.monospacedDigits
            let fixed = PKYThemeFallback.system
            let dynamic = PKYTheme(
                color: fixed.color,
                typography: .system(scaling: .dynamic(maximum: .xxxLarge))
            )
            let traits = UITraitCollection(preferredContentSizeCategory: .extraExtraExtraLarge)
            let fixedFont = role.uiFont(in: fixed, compatibleWith: traits)
            let dynamicFont = role.uiFont(in: dynamic, compatibleWith: traits)
            #expect(dynamicFont.pointSize > fixedFont.pointSize)
            #expect(role == .heading.bold.rounded.monospacedDigits)
        }

        @Test("An environment snapshot resolves the same theme as traits carrying it")
        func environmentSnapshotResolvesItsTheme() {
            let theme = PKYThemeContextTests.makeTheme(contentPrimary: .red)
            let snapshot: PKYThemeTraitValue? = PKYThemeTraitValue(theme: theme)
            let resolved = snapshot.pkyResolvedTheme
            #expect(resolved.color.content(.primary) === theme.color.content(.primary))
            let traits = UITraitCollection { $0.pkyTheme = snapshot }
            #expect(
                traits.pkyResolvedTheme.color.content(.primary) === resolved.color.content(.primary)
            )
        }

        #if !DEBUG
            @Test(
                "Release resolves a missing environment snapshot with the emergency theme and reports it"
            )
            func releaseMissingSnapshotUsesEmergencyTheme() {
                let snapshot: PKYThemeTraitValue? = nil
                let before = PKYThemeDiagnostics.reportCount
                let resolved = snapshot.pkyResolvedTheme
                #expect(PKYThemeDiagnostics.reportCount > before)
                let fallback = PKYThemeFallback.system.color.content(.primary)
                #expect(resolved.color.content(.primary).isEqual(fallback))
            }

            @Test(
                "Release missing injection keeps the raw value nil and resolves the explicit emergency theme"
            )
            func releaseMissingInjectionUsesEmergencyTheme() {
                let traits = UITraitCollection()
                #expect(traits.pkyTheme == nil)
                let resolved = traits.pkyResolvedTheme
                #expect(
                    resolved.color.content(.primary).isEqual(
                        PKYThemeFallback.system.color.content(.primary)
                    )
                )
                let color = UIColor.pkyTheme { theme, _ in theme.color.content(.primary) }
                #expect(color.resolvedColor(with: traits).isEqual(
                    PKYThemeFallback.system.color.content(.primary).resolvedColor(with: traits)
                ))
                #expect(PKYTypographyRole.body.uiFont(
                    in: resolved,
                    compatibleWith: traits
                ).familyName
                    == PKYTypographyRole.body.uiFont(
                        in: PKYThemeFallback.system,
                        compatibleWith: traits
                    ).familyName)
                #expect(traits.pkyTheme == nil)
            }

            @Test(
                "Release theme bindings report a missing injection before updating with the emergency theme"
            )
            func releaseThemeBindingsReportMissingInjection() {
                let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                window.traitOverrides.preferredContentSizeCategory = .extraExtraExtraLarge
                window.isHidden = false
                defer { window.isHidden = true }
                let callback = UIView()
                var reports = [Int]()
                callback.pkyOnThemeChange { (_: UIView) in
                    reports.append(PKYThemeDiagnostics.reportCount)
                }
                let before = PKYThemeDiagnostics.reportCount
                window.addSubview(callback)
                window.updateTraitsIfNeeded()
                #expect(callback.traitCollection.pkyTheme == nil)
                #expect(!reports.isEmpty)
                #expect(reports.allSatisfy { $0 > before })
                let layered = UIView()
                layered.pkyLayerBorderColor = .pkySeparator(.standard)
                window.addSubview(layered)
                window.updateTraitsIfNeeded()
                let fallback = PKYThemeFallback.system.color.separator(.standard)
                let expected = fallback.resolvedColor(with: layered.traitCollection).cgColor
                #expect(layered.layer.borderColor == expected)
            }
        #endif
    }
#endif
