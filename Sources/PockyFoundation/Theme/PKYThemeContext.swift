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
        /// Observe through `.pkyAppearanceDidChange`; dynamic colors already follow window appearance
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
        /// - Parameter theme: The next complete theme.
        public func activate(theme: PKYTheme) {
            let previous = themeTraitValue
            themeTraitValue = PKYThemeTraitValue(theme: theme)
            for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
                let installed = scene.traitOverrides.pkyTheme
                if installed == nil || installed == previous {
                    scene.traitOverrides.pkyTheme = themeTraitValue
                }
            }
            NotificationCenter.default.post(ThemeDidChangeMessage(), subject: self)
        }

        /// Saves an appearance selection, applies it to every connected scene window, and then posts its message.
        ///
        /// - Parameter appearance: System, light, or dark appearance selected by the user.
        public func activate(appearance: PKYAppearance.Mode) {
            self.appearance = appearance
            appearanceStorage.save(appearance)
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else {
                    continue
                }
                for window in windowScene.windows {
                    applyAppearance(to: window)
                }
            }
            NotificationCenter.default.post(AppearanceDidChangeMessage(), subject: self)
        }

        /// Applies the current appearance to a new window when its scene is created.
        ///
        /// Later ``activate(appearance:)`` calls update every connected scene window automatically.
        ///
        /// - Parameter window: The window that should follow the current appearance.
        public func applyAppearance(to window: UIWindow) {
            window.overrideUserInterfaceStyle = appearance.userInterfaceStyle
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
