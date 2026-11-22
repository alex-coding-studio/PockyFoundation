#if os(iOS)
    import SwiftUI

    public extension View {
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
