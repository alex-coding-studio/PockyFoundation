import SwiftUI

#if os(iOS)
    import UIKit

    public extension View {
        /// Applies a typography role resolved from the injected theme and the SwiftUI environment.
        ///
        /// The font matches UIKit resolution for the same theme, Dynamic Type size, and Bold Text setting,
        /// including reference sizes and monospaced digits. Missing theme injection follows the established
        /// diagnostic or emergency policy.
        ///
        /// - Parameter role: The semantic role and its modifiers.
        /// - Returns: A view whose text uses the resolved font.
        func pkyFont(_ role: PKYTypographyRole) -> some View {
            modifier(PKYTypographyModifier(role: role))
        }
    }

    private struct PKYTypographyModifier: ViewModifier {
        @Environment(\.pkyTheme) private var theme
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize
        @Environment(\.legibilityWeight) private var legibilityWeight

        let role: PKYTypographyRole

        func body(content: Content) -> some View {
            let traits = UITraitCollection { traits in
                traits.pkyTheme = theme
                traits.preferredContentSizeCategory = UIContentSizeCategory(dynamicTypeSize)
                traits.legibilityWeight = legibilityWeight == .bold ? .bold : .regular
            }
            content.font(Font(role.uiFont(in: traits.pkyResolvedTheme, compatibleWith: traits)))
        }
    }

#elseif os(macOS)
    public extension View {
        /// Applies a typography role resolved from the macOS default theme.
        ///
        /// macOS has no theme injection; use `Font(role.nsFont(in:))` to resolve against another theme.
        ///
        /// - Parameter role: The semantic role and its modifiers.
        /// - Returns: A view whose text uses the resolved font.
        func pkyFont(_ role: PKYTypographyRole) -> some View {
            font(Font(role.nsFont(in: PKYThemeFallback.system)))
        }
    }
#endif
