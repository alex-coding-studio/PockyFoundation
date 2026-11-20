#if os(iOS)
    import Foundation
    import Testing
    import UIKit
    @testable import PockyFoundation

    @MainActor
    struct PKYAppearanceContextTests {
        static func isolatedStore() throws -> UserDefaults {
            let suiteName = "PKYAppearanceContextTests.\(UUID().uuidString)"
            let store = try #require(UserDefaults(suiteName: suiteName))
            store.removePersistentDomain(forName: suiteName)
            return store
        }

        static func makeContext(appearance: PKYAppearance) -> PKYThemeContext {
            PKYThemeContext(
                theme: PKYThemeContextTests.makeTheme(contentPrimary: .label),
                appearance: appearance
            )
        }

        @Test("Context appearance defaults are configurable when no selection is stored")
        func missingValueUsesDefaultMode() throws {
            let store = try Self.isolatedStore()

            #expect(Self.makeContext(appearance: PKYAppearance(store: store)).appearance == .system)
            #expect(
                Self.makeContext(appearance: PKYAppearance(store: store, defaultMode: .dark))
                    .appearance == .dark
            )
        }

        @Test("Context restores a saved appearance from the injected store and key")
        func contextRestoresStoredModeFromCustomKey() throws {
            let store = try Self.isolatedStore()
            store.set("light", forKey: "pref.appearance")

            let context = Self.makeContext(
                appearance: PKYAppearance(store: store, key: "pref.appearance")
            )

            #expect(context.appearance == .light)
        }

        @Test("Unrecognized stored appearance falls back to the configured default")
        func unrecognizedStoredValueFallsBackToDefault() throws {
            let store = try Self.isolatedStore()
            store.set("sepia", forKey: "Pocky.appearance")

            let context = Self.makeContext(
                appearance: PKYAppearance(store: store, defaultMode: .light)
            )

            #expect(context.appearance == .light)
        }

        @Test("Appearance activation persists the selected mode itself for the next context")
        func activationPersistsSelection() throws {
            let store = try Self.isolatedStore()
            let appearance = PKYAppearance(store: store, key: "pref.appearance", defaultMode: .dark)
            let context = Self.makeContext(appearance: appearance)

            context.activate(appearance: .system)

            #expect(context.appearance == .system)
            #expect(store.string(forKey: "pref.appearance") == "system")
            #expect(Self.makeContext(appearance: appearance).appearance == .system)
        }

        @Test("Appearance activation posts only the appearance notification")
        func appearanceActivationPostsOnlyAppearanceMessage() async throws {
            let context = try Self.makeContext(
                appearance: PKYAppearance(store: Self.isolatedStore())
            )

            await confirmation(expectedCount: 1) { appearanceChanged in
                await confirmation(expectedCount: 0) { themeChanged in
                    let appearanceToken = NotificationCenter.default.addObserver(
                        of: context,
                        for: .pkyAppearanceDidChange
                    ) { _ in
                        #expect(context.appearance == .dark)
                        appearanceChanged()
                    }
                    let themeToken = NotificationCenter.default.addObserver(
                        of: context,
                        for: .pkyThemeDidChange
                    ) { _ in
                        themeChanged()
                    }

                    context.activate(appearance: .dark)
                    withExtendedLifetime((appearanceToken, themeToken)) {}
                }
            }
        }

        @Test("Theme activation posts only the theme notification")
        func themeActivationPostsOnlyThemeMessage() async throws {
            let context = try Self.makeContext(
                appearance: PKYAppearance(store: Self.isolatedStore())
            )

            await confirmation(expectedCount: 1) { themeChanged in
                await confirmation(expectedCount: 0) { appearanceChanged in
                    let themeToken = NotificationCenter.default.addObserver(
                        of: context,
                        for: .pkyThemeDidChange
                    ) { _ in
                        themeChanged()
                    }
                    let appearanceToken = NotificationCenter.default.addObserver(
                        of: context,
                        for: .pkyAppearanceDidChange
                    ) { _ in
                        appearanceChanged()
                    }

                    context.activate(theme: PKYThemeContextTests.makeTheme(contentPrimary: .blue))
                    withExtendedLifetime((themeToken, appearanceToken)) {}
                }
            }
        }

        @Test("Appearance activation invalidates Swift Observation dependencies")
        func appearanceActivationInvalidatesObservation() async throws {
            let context = try Self.makeContext(
                appearance: PKYAppearance(store: Self.isolatedStore())
            )

            await confirmation(expectedCount: 1) { changed in
                withObservationTracking {
                    _ = context.appearance
                } onChange: {
                    changed()
                }

                context.activate(appearance: .light)
            }
        }

        @Test("Scene setup installs the current theme and appearance overrides")
        func sceneSetupInstallsThemeAndAppearance() throws {
            let store = try Self.isolatedStore()
            store.set("dark", forKey: "Pocky.appearance")
            let context = Self.makeContext(appearance: PKYAppearance(store: store))
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
            window.isHidden = false
            defer { window.isHidden = true }

            context.install(on: &window.traitOverrides)
            window.updateTraitsIfNeeded()

            #expect(window.traitCollection.pkyTheme == context.themeTraitValue)
            #expect(window.traitCollection.userInterfaceStyle == .dark)

            context.activate(appearance: .system, in: [UIScene]())
            context.applyAppearance(on: &window.traitOverrides)

            #expect(!window.traitOverrides.contains(UITraitUserInterfaceStyle.self))
        }

        @Test("Theme activation replaces missing or previous snapshots and keeps custom ones")
        func themeActivationKeepsCustomSnapshots() throws {
            let context = try Self.makeContext(
                appearance: PKYAppearance(store: Self.isolatedStore())
            )
            let previous = context.themeTraitValue
            let custom = PKYThemeTraitValue(theme: PKYThemeFallback.system)
            let missing = UIView()
            let following = UIView()
            let customized = UIView()
            following.traitOverrides.pkyTheme = previous
            customized.traitOverrides.pkyTheme = custom

            context.activate(
                theme: PKYThemeContextTests.makeTheme(contentPrimary: .blue),
                in: [UIScene]()
            )
            for view in [missing, following, customized] {
                context.replaceTheme(on: &view.traitOverrides, previous: previous)
            }

            #expect(missing.traitOverrides.pkyTheme == context.themeTraitValue)
            #expect(following.traitOverrides.pkyTheme == context.themeTraitValue)
            #expect(customized.traitOverrides.pkyTheme == custom)
        }
    }
#endif
