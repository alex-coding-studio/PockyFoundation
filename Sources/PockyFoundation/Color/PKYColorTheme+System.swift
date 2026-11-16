import Foundation

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

public extension PKYColorTheme {
    #if os(iOS)
        /// Creates a complete color theme from native system semantics and app-provided brand colors.
        ///
        /// iOS keeps UIKit backgrounds, content, fills, and separators, including an opposite-appearance
        /// secondary prominent fill. macOS uses AppKit roles and maps grouped backgrounds like standard
        /// backgrounds. Status uses system red, orange, and green with white foregrounds. Media uses white
        /// overlays and black shadows and scrims; the focus scrim uses ``PKYOpacity/focusScrim``.
        ///
        /// - Parameter accent: Three dynamic brand colors supplied by the app.
        /// - Returns: A complete semantic color theme.
        static func system(accent: Accent) -> PKYColorTheme {
            PKYColorTheme(
                background: .init(
                    standard: .init(
                        primary: .systemBackground,
                        secondary: .secondarySystemBackground,
                        tertiary: .tertiarySystemBackground
                    ),
                    grouped: .init(
                        primary: .systemGroupedBackground,
                        secondary: .secondarySystemGroupedBackground,
                        tertiary: .tertiarySystemGroupedBackground
                    )
                ),
                content: .init(
                    primary: .label,
                    secondary: .secondaryLabel,
                    tertiary: .tertiaryLabel,
                    quaternary: .quaternaryLabel,
                    placeholder: .placeholderText
                ),
                filled: .init(
                    quiet: .init(
                        primary: .systemFill,
                        secondary: .secondarySystemFill,
                        tertiary: .tertiarySystemFill,
                        quaternary: .quaternarySystemFill
                    ),
                    prominent: .init(
                        primary: .label,
                        onPrimary: .systemBackground,
                        secondary: oppositeInterfaceStyle(of: .systemGray3),
                        onSecondary: .systemBackground
                    )
                ),
                separator: .init(standard: .separator, opaque: .opaqueSeparator),
                accent: accent,
                status: .init(
                    destructive: .systemRed,
                    onDestructive: .white,
                    warning: .systemOrange,
                    onWarning: .white,
                    success: .systemGreen,
                    onSuccess: .white
                ),
                media: .init(
                    placeholder: .systemGray5,
                    content: .white,
                    contentShadow: .black,
                    scrim: .black,
                    focusScrim: .black.withAlphaComponent(PKYOpacity.focusScrim)
                ),
                shadow: .black
            )
        }
    #elseif os(macOS)
        /// Creates a complete color theme from native system semantics and app-provided brand colors.
        ///
        /// iOS keeps UIKit backgrounds, content, fills, and separators, including an opposite-appearance
        /// secondary prominent fill. macOS uses AppKit roles and maps grouped backgrounds like standard
        /// backgrounds. Status uses system red, orange, and green with white foregrounds. Media uses white
        /// overlays and black shadows and scrims; the focus scrim uses ``PKYOpacity/focusScrim``.
        ///
        /// - Parameter accent: Three dynamic brand colors supplied by the app.
        /// - Returns: A complete semantic color theme.
        static func system(accent: Accent) -> PKYColorTheme {
            PKYColorTheme(
                background: .init(
                    standard: .init(
                        primary: .windowBackgroundColor,
                        secondary: .controlBackgroundColor,
                        tertiary: .underPageBackgroundColor
                    ),
                    grouped: .init(
                        primary: .windowBackgroundColor,
                        secondary: .controlBackgroundColor,
                        tertiary: .underPageBackgroundColor
                    )
                ),
                content: .init(
                    primary: .labelColor,
                    secondary: .secondaryLabelColor,
                    tertiary: .tertiaryLabelColor,
                    quaternary: .quaternaryLabelColor,
                    placeholder: .placeholderTextColor
                ),
                filled: .init(
                    quiet: .init(
                        primary: .systemFill,
                        secondary: .secondarySystemFill,
                        tertiary: .tertiarySystemFill,
                        quaternary: .quaternarySystemFill
                    ),
                    prominent: .init(
                        primary: .labelColor,
                        onPrimary: .windowBackgroundColor,
                        secondary: .secondaryLabelColor,
                        onSecondary: .windowBackgroundColor
                    )
                ),
                separator: .init(standard: .separatorColor, opaque: .gridColor),
                accent: accent,
                status: .init(
                    destructive: .systemRed,
                    onDestructive: .white,
                    warning: .systemOrange,
                    onWarning: .white,
                    success: .systemGreen,
                    onSuccess: .white
                ),
                media: .init(
                    placeholder: .quaternarySystemFill,
                    content: .white,
                    contentShadow: .black,
                    scrim: .black,
                    focusScrim: .black.withAlphaComponent(PKYOpacity.focusScrim)
                ),
                shadow: .black
            )
        }
    #endif

    #if os(iOS)
        private static func oppositeInterfaceStyle(of color: UIColor) -> UIColor {
            UIColor { traits in
                let opposite: UIUserInterfaceStyle = traits.userInterfaceStyle == .dark ? .light : .dark
                return color.resolvedColor(
                    with: traits.modifyingTraits { $0.userInterfaceStyle = opposite }
                )
            }
        }
    #endif
}
