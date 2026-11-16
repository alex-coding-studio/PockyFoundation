import Foundation
#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

public extension PKYAppearance {
    /// The interface appearance the user selected; the raw value is also the stored preference.
    ///
    /// `system` keeps following the system and is never replaced by the light or dark style
    /// resolved at the time.
    enum Mode: String, CaseIterable, Sendable {
        /// Follows the system Light or Dark setting.
        case system
        /// Always uses the Light appearance.
        case light
        /// Always uses the Dark appearance.
        case dark

        #if os(iOS)
            /// The window style override; `system` removes the override.
            public var userInterfaceStyle: UIUserInterfaceStyle {
                switch self {
                case .system: .unspecified
                case .light: .light
                case .dark: .dark
                }
            }
        #elseif os(macOS)
            /// The application or window appearance; `system` is `nil`, which follows the system.
            public var nsAppearance: NSAppearance? {
                switch self {
                case .system: nil
                case .light: NSAppearance(named: .aqua)
                case .dark: NSAppearance(named: .darkAqua)
                }
            }
        #endif

        /// The localized name for an appearance option.
        public var title: String {
            String(localized: String.LocalizationValue(titleKey), bundle: .module)
        }

        var titleKey: String {
            "appearance.mode.\(rawValue)"
        }
    }
}
