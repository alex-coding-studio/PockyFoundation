#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// A standard inverse pair: dark fill with light content in light appearance, reversed in dark appearance.
///
/// These are the defaults for ``PKYColorTheme``. Inverse is independent of theme tint and provides
/// strong contrast for elements such as capsules, while prominent fills may follow theme colors.
/// A theme may supply its own inverse pair, with at least 7:1 contrast in both appearances.
/// Both colors use custom dynamic providers that return concrete values. On iOS 26, semantic
/// colors such as label or system background can appear gray in glass sheets even when resolved
/// to opaque white.
public enum PKYStandardInverse {
    #if os(iOS)
        /// The standard inverse background.
        public static let inverse = UIColor { $0.userInterfaceStyle == .dark ? .white : .black }
    #elseif os(macOS)
        /// The standard inverse background.
        public static let inverse = NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? .white : .black
        }
    #endif

    #if os(iOS)
        /// Text and symbols on the standard inverse background.
        public static let onInverse = UIColor { $0.userInterfaceStyle == .dark ? .black : .white }
    #elseif os(macOS)
        /// Text and symbols on the standard inverse background.
        public static let onInverse = NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? .black : .white
        }
    #endif
}
