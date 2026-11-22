#if os(iOS)
    import Foundation
    import Observation
    import UIKit

    @MainActor
    @Observable
    public final class PKYThemeContext {
        public struct ThemeDidChangeMessage: NotificationCenter.MainActorMessage {
            public static let name = Notification.Name("Pocky.PKYThemeContext.themeDidChange")

            public init() {}
        }

        public struct AppearanceDidChangeMessage: NotificationCenter.MainActorMessage {
            public static let name = Notification.Name("Pocky.PKYThemeContext.appearanceDidChange")

            public init() {}
        }

        public private(set) var themeTraitValue: PKYThemeTraitValue

        public private(set) var appearance: PKYAppearance.Mode

        @ObservationIgnored private let appearanceStorage: PKYAppearance

        public var theme: PKYTheme {
            themeTraitValue.theme
        }

        public init(theme: PKYTheme, appearance: PKYAppearance = PKYAppearance()) {
            themeTraitValue = PKYThemeTraitValue(theme: theme)
            self.appearance = appearance.storedMode()
            appearanceStorage = appearance
        }

        @available(iOSApplicationExtension, unavailable)
        public func activate(theme: PKYTheme) {
            activate(theme: theme, in: UIApplication.shared.connectedScenes)
        }

        public func activate(theme: PKYTheme, in scenes: some Sequence<UIScene>) {
            let previous = themeTraitValue
            themeTraitValue = PKYThemeTraitValue(theme: theme)
            for case let scene as UIWindowScene in scenes {
                replaceTheme(on: &scene.traitOverrides, previous: previous)
            }
            NotificationCenter.default.post(ThemeDidChangeMessage(), subject: self)
        }

        @available(iOSApplicationExtension, unavailable)
        public func activate(appearance: PKYAppearance.Mode) {
            activate(appearance: appearance, in: UIApplication.shared.connectedScenes)
        }

        public func activate(appearance: PKYAppearance.Mode, in scenes: some Sequence<UIScene>) {
            self.appearance = appearance
            appearanceStorage.save(appearance)
            for case let scene as UIWindowScene in scenes {
                applyAppearance(on: &scene.traitOverrides)
            }
            NotificationCenter.default.post(AppearanceDidChangeMessage(), subject: self)
        }

        public func apply(to scene: UIWindowScene) {
            install(on: &scene.traitOverrides)
        }

        func install(on overrides: inout UITraitOverrides) {
            overrides.pkyTheme = themeTraitValue
            applyAppearance(on: &overrides)
        }

        func replaceTheme(on overrides: inout UITraitOverrides, previous: PKYThemeTraitValue) {
            let installed = overrides.contains(PKYThemeTrait.self) ? overrides.pkyTheme : nil
            if installed == nil || installed == previous {
                overrides.pkyTheme = themeTraitValue
            }
        }

        func applyAppearance(on overrides: inout UITraitOverrides) {
            switch appearance {
            case .system: overrides.remove(UITraitUserInterfaceStyle.self)
            case .light, .dark: overrides.userInterfaceStyle = appearance.userInterfaceStyle
            }
        }
    }

    public extension NotificationCenter.MessageIdentifier
        where Self == NotificationCenter.BaseMessageIdentifier<
            PKYThemeContext.ThemeDidChangeMessage
        > {
        static var pkyThemeDidChange: Self {
            .init()
        }
    }

    public extension NotificationCenter.MessageIdentifier
        where Self == NotificationCenter.BaseMessageIdentifier<
            PKYThemeContext.AppearanceDidChangeMessage
        > {
        static var pkyAppearanceDidChange: Self {
            .init()
        }
    }

    public extension PKYThemeContext.ThemeDidChangeMessage {
        typealias Subject = PKYThemeContext
    }

    public extension PKYThemeContext.AppearanceDidChangeMessage {
        typealias Subject = PKYThemeContext
    }

#endif
