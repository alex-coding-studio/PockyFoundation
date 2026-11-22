import Foundation
#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

public extension PKYAppearance {
    enum Mode: String, CaseIterable, Sendable {
        case system
        case light
        case dark

        #if os(iOS)
            public var userInterfaceStyle: UIUserInterfaceStyle {
                switch self {
                case .system: .unspecified
                case .light: .light
                case .dark: .dark
                }
            }
        #elseif os(macOS)
            public var nsAppearance: NSAppearance? {
                switch self {
                case .system: nil
                case .light: NSAppearance(named: .aqua)
                case .dark: NSAppearance(named: .darkAqua)
                }
            }
        #endif

        public var title: String {
            String(localized: String.LocalizationValue(titleKey), bundle: .module)
        }

        var titleKey: String {
            "appearance.mode.\(rawValue)"
        }
    }
}
