import SwiftUI

#if os(iOS)
    import UIKit

    public extension View {
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
        func pkyFont(_ role: PKYTypographyRole) -> some View {
            font(Font(role.nsFont(in: PKYThemeFallback.system)))
        }
    }
#endif
