import Foundation

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// A text role independent of font family or scaling, resolved in a theme and native environment.
public struct PKYTypographyRole: Hashable, Sendable {
    /// A visual focus or display value.
    public static let display = Self(role: .display)
    /// A persistent page title that does not collapse.
    public static let pageTitle = Self(role: .pageTitle)
    /// A primary object title or prominent section title.
    public static let title = Self(role: .title)
    /// A card, section, or content-group heading.
    public static let heading = Self(role: .heading)
    /// Body text or primary list content.
    public static let body = Self(role: .body)
    /// Subtitles, explanations, and supplementary content.
    public static let supporting = Self(role: .supporting)
    /// Compact metadata such as a time, count, or source.
    public static let caption = Self(role: .caption)
    /// Text in buttons and other actionable controls.
    public static let action = Self(role: .action)

    private let role: PKYTextStyle.Role
    private var weight: PKYFontWeight?
    private var isItalic = false
    private var isRounded = false
    private var isMonospaced = false
    private var usesMonospacedDigits = false
    private var referenceSize: CGFloat?

    /// Uses regular weight while preserving other modifiers.
    public var regular: Self {
        withWeight(.regular)
    }

    /// Uses medium weight while preserving other modifiers.
    public var medium: Self {
        withWeight(.medium)
    }

    /// Uses semibold weight while preserving other modifiers.
    public var semibold: Self {
        withWeight(.semibold)
    }

    /// Uses bold weight while preserving other modifiers.
    public var bold: Self {
        withWeight(.bold)
    }

    /// Selects the theme's italic face while preserving the semantic size.
    public var italic: Self {
        var copy = self
        copy.isItalic = true
        return copy
    }

    /// Uses the existing rounded design while preserving the semantic size.
    public var rounded: Self {
        var copy = self
        copy.isRounded = true
        return copy
    }

    /// Uses the monospaced design while preserving the semantic size; overrides rounded if both are set.
    public var monospaced: Self {
        var copy = self
        copy.isMonospaced = true
        return copy
    }

    /// Applies the existing monospaced-digit feature to the resolved font.
    public var monospacedDigits: Self {
        var copy = self
        copy.usesMonospacedDigits = true
        return copy
    }

    private init(role: PKYTextStyle.Role) {
        self.role = role
    }

    /// Retains a component's reference size through composition while preserving the theme's family
    /// and scaling policy. An explicit reference size passed during font resolution takes precedence.
    public func withReferenceSize(_ size: CGFloat) -> Self {
        var copy = self
        copy.referenceSize = size
        return copy
    }

    #if os(iOS)
        /// Resolves a UIKit font from the theme, optionally using a component's existing reference size.
        public func uiFont(
            in theme: PKYTheme,
            compatibleWith traits: UITraitCollection,
            referenceSize: CGFloat? = nil
        ) -> UIFont {
            var style = textStyle(in: theme)
            if let weight {
                switch weight {
                case .regular: style = style.regular
                case .medium: style = style.medium
                case .semibold: style = style.semibold
                case .bold: style = style.bold
                }
            }
            if isItalic {
                style = style.italic
            }
            if isRounded {
                style = style.rounded
            }
            if isMonospaced {
                style = style.monospaced
            }
            let font = (referenceSize ?? self.referenceSize).map {
                style.uiFont(referenceSize: $0, compatibleWith: traits)
            }
                ?? style.uiFont(compatibleWith: traits)
            return usesMonospacedDigits ? font.pkyMonospacedDigits : font
        }

    #elseif os(macOS)
        /// Resolves an AppKit font from the theme, optionally using a component's reference size; scaling is ignored.
        public func nsFont(
            in theme: PKYTheme,
            referenceSize: CGFloat? = nil
        ) -> NSFont {
            var style = textStyle(in: theme)
            if let weight {
                switch weight {
                case .regular: style = style.regular
                case .medium: style = style.medium
                case .semibold: style = style.semibold
                case .bold: style = style.bold
                }
            }
            if isItalic {
                style = style.italic
            }
            if isRounded {
                style = style.rounded
            }
            if isMonospaced {
                style = style.monospaced
            }
            let font = (referenceSize ?? self.referenceSize).map {
                style.nsFont(referenceSize: $0)
            }
                ?? style.nsFont
            return usesMonospacedDigits ? font.pkyMonospacedDigits : font
        }

    #endif

    private func textStyle(in theme: PKYTheme) -> PKYTextStyle {
        switch role {
        case .display: theme.typography.display
        case .pageTitle: theme.typography.pageTitle
        case .title: theme.typography.title
        case .heading: theme.typography.heading
        case .body: theme.typography.body
        case .supporting: theme.typography.supporting
        case .caption: theme.typography.caption
        case .action: theme.typography.action
        }
    }

    private func withWeight(_ weight: PKYFontWeight) -> Self {
        var copy = self
        copy.weight = weight
        return copy
    }
}
