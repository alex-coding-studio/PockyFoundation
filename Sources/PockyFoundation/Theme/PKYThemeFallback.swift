#if os(iOS)
    import os
    import Synchronization
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

public enum PKYThemeFallback {
    #if os(iOS)
        public static let system = PKYTheme(
            color: .system(accent: .init(
                primary: .systemBlue,
                secondary: .systemBlue,
                onAccent: .white
            )),
            typography: .system(scaling: .fixed)
        )
    #elseif os(macOS)
        public static let system = PKYTheme(
            color: .system(accent: .init(
                primary: .controlAccentColor,
                secondary: .controlAccentColor,
                onAccent: .white
            )),
            typography: .system(scaling: .fixed)
        )
    #endif
}

#if os(iOS)
    enum PKYThemeDiagnostics {
        private static let logger = Logger(subsystem: "Pocky", category: "ThemeInjection")
        private static let reports = Mutex(0)

        static var reportCount: Int {
            reports.withLock { $0 }
        }

        static func reportMissingInjection() {
            let isFirst = reports.withLock { count in
                count += 1
                return count == 1
            }
            if isFirst {
                logger.error("Missing PKYThemeTrait injection; using PKYThemeFallback.system")
            }
        }
    }
#endif
