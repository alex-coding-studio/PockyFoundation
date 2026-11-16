#if os(iOS)
    import SwiftUI

    public extension View {
        /// Injects an app-root theme context into a SwiftUI subtree and applies its typography scaling policy.
        ///
        /// Descendants read it through `@Environment(PKYThemeContext.self)`; there is no implicit default context.
        ///
        /// - Parameter context: The same context instance shared with UIKit consumers.
        /// - Returns: A view using this context and its Dynamic Type range.
        @MainActor
        func pkyTheme(_ context: PKYThemeContext) -> some View {
            PKYThemeRoot(context: context, content: self)
        }
    }

    @MainActor
    private struct PKYThemeRoot<Content: View>: View {
        let context: PKYThemeContext
        let content: Content

        var body: some View {
            let range: ClosedRange<DynamicTypeSize> = switch context.theme.typography.scaling {
            case .fixed: .large ... .large
            case let .dynamic(maximum): .xSmall ... maximum
            }

            content
                .environment(context)
                .environment(\.pkyTheme, context.themeTraitValue)
                .dynamicTypeSize(range)
        }
    }
#endif
