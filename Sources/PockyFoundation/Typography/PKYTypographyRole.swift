import CoreGraphics

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// A text role and its modifiers, independent of font family or scaling.
///
/// Roles are the only typography descriptor. Compose weight, italic, design, digit, and
/// reference-size modifiers here; a ``PKYTypographyTheme`` supplies the family and scaling policy
/// when UIKit, AppKit, or SwiftUI resolves the role.
public struct PKYTypographyRole: Hashable, Sendable {
    enum Kind: Hashable, Sendable {
        case display
        case pageTitle
        case title
        case heading
        case body
        case supporting
        case caption
        case action

        var customSize: CGFloat {
            switch self {
            case .display: 32
            case .pageTitle: 28
            case .title: 24
            case .heading: 18
            case .body: 16
            case .supporting: 15
            case .caption: 14
            case .action: 16
            }
        }

        var standardWeight: PKYFontWeight {
            switch self {
            case .display, .pageTitle: .bold
            case .title, .heading, .action: .semibold
            case .body, .supporting, .caption: .regular
            }
        }

        #if os(iOS)
            var uiKitTextStyle: UIFont.TextStyle {
                switch self {
                case .display: .largeTitle
                case .pageTitle: .title1
                case .title: .title2
                case .heading: .headline
                case .body, .action: .body
                case .supporting: .subheadline
                case .caption: .footnote
                }
            }
        #elseif os(macOS)
            var nsFontTextStyle: NSFont.TextStyle {
                switch self {
                case .display: .largeTitle
                case .pageTitle: .title1
                case .title: .title2
                case .heading: .headline
                case .body, .action: .body
                case .supporting: .subheadline
                case .caption: .footnote
                }
            }
        #endif
    }

    /// A visual focus or display value.
    public static let display = Self(kind: .display)
    /// A persistent page title that does not collapse.
    public static let pageTitle = Self(kind: .pageTitle)
    /// A primary object title or prominent section title.
    public static let title = Self(kind: .title)
    /// A card, section, or content-group heading.
    public static let heading = Self(kind: .heading)
    /// Body text or primary list content.
    public static let body = Self(kind: .body)
    /// Subtitles, explanations, and supplementary content.
    public static let supporting = Self(kind: .supporting)
    /// Compact metadata such as a time, count, or source.
    public static let caption = Self(kind: .caption)
    /// Text in buttons and other actionable controls.
    public static let action = Self(kind: .action)

    let kind: Kind
    private(set) var weight: PKYFontWeight?
    private(set) var isItalic = false
    private(set) var isRounded = false
    private(set) var isMonospaced = false
    private(set) var usesMonospacedDigits = false
    private(set) var referenceSize: CGFloat?

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

    /// Selects the theme's italic face while preserving the semantic size; custom families fall back
    /// to upright faces when needed.
    public var italic: Self {
        var copy = self
        copy.isItalic = true
        return copy
    }

    /// Uses the system rounded design while preserving the semantic size; custom families keep their face.
    public var rounded: Self {
        var copy = self
        copy.isRounded = true
        return copy
    }

    /// Uses the system monospaced design while preserving the semantic size; overrides rounded if both
    /// are set, and custom families keep their face.
    public var monospaced: Self {
        var copy = self
        copy.isMonospaced = true
        return copy
    }

    /// Applies the monospaced-digit feature to the resolved font, for changing counts or readings.
    public var monospacedDigits: Self {
        var copy = self
        copy.usesMonospacedDigits = true
        return copy
    }

    private init(kind: Kind) {
        self.kind = kind
    }

    /// Uses a component's reference size while preserving the theme's family and scaling policy.
    ///
    /// Fixed scaling uses the size directly; dynamic scaling uses it as the Dynamic Type baseline.
    ///
    /// - Parameter size: The component-owned point size.
    /// - Returns: A role resolved at the reference size.
    public func withReferenceSize(_ size: CGFloat) -> Self {
        var copy = self
        copy.referenceSize = size
        return copy
    }

    private func withWeight(_ weight: PKYFontWeight) -> Self {
        var copy = self
        copy.weight = weight
        return copy
    }
}
