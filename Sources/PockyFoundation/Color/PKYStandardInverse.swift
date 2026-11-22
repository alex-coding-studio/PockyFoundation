#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

public enum PKYStandardInverse {
    #if os(iOS)
        public static let inverse = UIColor { $0.userInterfaceStyle == .dark ? .white : .black }
    #elseif os(macOS)
        public static let inverse = NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? .white : .black
        }
    #endif

    #if os(iOS)
        public static let onInverse = UIColor { $0.userInterfaceStyle == .dark ? .black : .white }
    #elseif os(macOS)
        public static let onInverse = NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? .black : .white
        }
    #endif
}
