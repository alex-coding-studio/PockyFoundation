#if os(iOS)
    import Foundation
    import Observation
    import UIKit

    /// An app-root context sharing the current theme and appearance selection with SwiftUI and UIKit.
    ///
    /// SwiftUI observes it through Observation; UIKit uses this instance's typed notifications.
    /// Apps own product themes, while ``PKYAppearance`` restores and saves appearance independently.
    @MainActor
    @Observable
    public final class PKYThemeContext {
        /// A main-actor message posted after theme activation so UIKit can reapply colors and fonts.
        ///
        /// Observe this context through `.pkyThemeDidChange`; appearance changes do not post this message.
        public struct ThemeDidChangeMessage: NotificationCenter.MainActorMessage {
            /// The notification name shared by typed and traditional observers.
            public static let name = Notification.Name("Pocky.PKYThemeContext.themeDidChange")

            /// Creates a notification for a completed theme activation.
            public init() {}
        }

        /// A main-actor message posted after appearance activation so settings can update their selection.
        ///
        /// Observe through `.pkyAppearanceDidChange`; dynamic colors already follow the scene appearance
        /// and do not need reassignment for this notification.
        public struct AppearanceDidChangeMessage: NotificationCenter.MainActorMessage {
            /// The notification name shared by typed and traditional appearance observers.
            public static let name = Notification.Name("Pocky.PKYThemeContext.appearanceDidChange")

            /// Creates a notification for a completed appearance activation.
            public init() {}
        }

        /// An immutable snapshot of the current theme, published by the root into scene traits.
        public private(set) var themeTraitValue: PKYThemeTraitValue

        /// The user's current appearance mode.
        public private(set) var appearance: PKYAppearance.Mode

        @ObservationIgnored private let appearanceStorage: PKYAppearance

        /// The complete product theme currently active in the app.
        public var theme: PKYTheme {
            themeTraitValue.theme
        }

        /// Creates a context with a product theme and restores the saved appearance mode.
        ///
        /// - Parameters:
        ///   - theme: The complete product theme selected by the app.
        ///   - appearance: Persistence configuration, including an existing key or App Group store.
        public init(theme: PKYTheme, appearance: PKYAppearance = PKYAppearance()) {
            themeTraitValue = PKYThemeTraitValue(theme: theme)
            self.appearance = appearance.storedMode()
            appearanceStorage = appearance
        }

        /// Updates connected window scenes with no theme or this context’s previous snapshot, then notifies observers.
        ///
        /// App extensions use ``activate(theme:in:)`` with their own scenes instead.
        ///
        /// - Parameter theme: The next complete theme.
        @available(iOSApplicationExtension, unavailable)
        public func activate(theme: PKYTheme) {
            activate(theme: theme, in: UIApplication.shared.connectedScenes)
        }

        /// Updates the supplied window scenes with no theme or this context’s previous snapshot, then notifies observers.
        ///
        /// Use from app extensions or when the app tracks its own scenes; other scenes keep their current snapshot.
        ///
        /// - Parameters:
        ///   - theme: The next complete theme.
        ///   - scenes: The scenes whose theme trait follows this context.
        public func activate(theme: PKYTheme, in scenes: some Sequence<UIScene>) {
            let previous = themeTraitValue
            themeTraitValue = PKYThemeTraitValue(theme: theme)
            for case let scene as UIWindowScene in scenes {
                replaceTheme(on: &scene.traitOverrides, previous: previous)
            }
            NotificationCenter.default.post(ThemeDidChangeMessage(), subject: self)
        }

        /// Saves an appearance selection, applies it to every connected scene, and then posts its message.
        ///
        /// App extensions use ``activate(appearance:in:)`` with their own scenes instead.
        ///
        /// - Parameter appearance: System, light, or dark appearance selected by the user.
        @available(iOSApplicationExtension, unavailable)
        public func activate(appearance: PKYAppearance.Mode) {
            activate(appearance: appearance, in: UIApplication.shared.connectedScenes)
        }

        /// Saves an appearance selection, applies it to the supplied scenes, and then posts its message.
        ///
        /// Each window scene receives a user-interface-style trait override that all of its windows
        /// follow; `system` removes the override. Other scenes keep their current style.
        ///
        /// - Parameters:
        ///   - appearance: System, light, or dark appearance selected by the user.
        ///   - scenes: The scenes that follow this context.
        public func activate(appearance: PKYAppearance.Mode, in scenes: some Sequence<UIScene>) {
            self.appearance = appearance
            appearanceStorage.save(appearance)
            for case let scene as UIWindowScene in scenes {
                applyAppearance(on: &scene.traitOverrides)
            }
            NotificationCenter.default.post(AppearanceDidChangeMessage(), subject: self)
        }

        /// Installs the current theme snapshot and appearance on a newly connected scene.
        ///
        /// Call from `scene(_:willConnectTo:options:)` in UIKit apps. Every window in the scene follows,
        /// including windows created later, and later `activate` calls update the scene. SwiftUI apps
        /// apply `View.pkyTheme(_:)` to the root view instead.
        ///
        /// - Parameter scene: The window scene that follows this context.
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
        /// The identifier for observing theme activation with dot syntax.
        static var pkyThemeDidChange: Self {
            .init()
        }
    }

    public extension NotificationCenter.MessageIdentifier
        where Self == NotificationCenter.BaseMessageIdentifier<
            PKYThemeContext.AppearanceDidChangeMessage
        > {
        /// The identifier for observing appearance activation with dot syntax.
        static var pkyAppearanceDidChange: Self {
            .init()
        }
    }

    public extension PKYThemeContext.ThemeDidChangeMessage {
        /// The context type whose theme changed.
        typealias Subject = PKYThemeContext
    }

    public extension PKYThemeContext.AppearanceDidChangeMessage {
        /// The context type whose appearance changed.
        typealias Subject = PKYThemeContext
    }

#endif
