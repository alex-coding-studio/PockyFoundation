#if os(iOS)
    import os
    import Synchronization
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// A standard recipe used for the macOS default and iOS Release emergency rendering.
///
/// The iOS fallback does not mean injection succeeded or reflect a user-selected product theme.
public enum PKYThemeFallback {
    #if os(iOS)
        /// Uses native semantic colors, system blue accents, and fixed typography without app resources or preferences.
        public static let system = PKYTheme(
            color: .system(accent: .init(
                primary: .systemBlue,
                secondary: .systemBlue,
                onAccent: .white
            )),
            typography: .system(scaling: .fixed)
        )
    #elseif os(macOS)
        /// Uses native semantic colors, system control accents, and fixed typography without app resources or preferences.
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
    /// Thread-safe diagnostics for missing iOS theme injection.
    @_spi(PockyComponents) public enum PKYThemeDiagnostics {
        private static let logger = Logger(subsystem: "Pocky", category: "ThemeInjection")
        private static let reports = Mutex(0)

        /// The number of missing-injection reports observed by this process.
        @_spi(PockyComponents) public static var reportCount: Int {
            reports.withLock { $0 }
        }

        /// Records a missing injection and logs only the first report.
        @_spi(PockyComponents) public static func reportMissingInjection() {
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
