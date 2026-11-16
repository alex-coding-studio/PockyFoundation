import SwiftUI

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// A semantic typography role with immutable weight, italic, and rounded-design modifiers.
///
/// Modifiers retain the role's size and scaling policy. SwiftUI uses ``font``, UIKit uses `uiFont`,
/// and AppKit uses `nsFont`.
public struct PKYTextStyle: Sendable {
    enum Role: Hashable, Sendable {
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

        var swiftUITextStyle: Font.TextStyle {
            switch self {
            case .display: .largeTitle
            case .pageTitle: .title
            case .title: .title2
            case .heading: .headline
            case .body, .action: .body
            case .supporting: .subheadline
            case .caption: .footnote
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

    let role: Role
    let family: PKYFontFamily
    let scaling: PKYTypographyTheme.Scaling
    var weight: PKYFontWeight
    var isItalic: Bool
    var isRounded: Bool

    /// A regular-weight variant preserving the current italic setting.
    public var regular: PKYTextStyle {
        withWeight(.regular)
    }

    /// A medium-weight variant preserving the current italic setting.
    public var medium: PKYTextStyle {
        withWeight(.medium)
    }

    /// A semibold-weight variant preserving the current italic setting.
    public var semibold: PKYTextStyle {
        withWeight(.semibold)
    }

    /// A bold variant preserving the current italic setting.
    public var bold: PKYTextStyle {
        withWeight(.bold)
    }

    /// An italic variant preserving weight; custom families fall back to upright faces if needed.
    public var italic: PKYTextStyle {
        var copy = self
        copy.isItalic = true
        return copy
    }

    /// A system rounded variant preserving size, scaling, weight, and italic settings.
    ///
    /// Useful for prominent statistics or progress values; custom families retain their original face.
    public var rounded: PKYTextStyle {
        var copy = self
        copy.isRounded = true
        return copy
    }

    /// The SwiftUI font resolved for the current role and face.
    ///
    /// On iOS, use in a subtree injected with `pkyTheme(_:)` to follow fixed or capped scaling.
    /// On macOS, uses the native font and ignores scaling.
    public var font: Font {
        #if os(iOS)
            switch family.resolvedFace(weight: weight, isItalic: isItalic, size: role.customSize) {
            case let .system(weight, isItalic):
                var font = Font.system(
                    role.swiftUITextStyle,
                    design: isRounded ? .rounded : nil,
                    weight: weight.swiftUIValue
                )
                if isItalic {
                    font = font.italic()
                }
                return font
            case let .custom(name):
                switch scaling {
                case .fixed:
                    return Font.custom(name, fixedSize: role.customSize)
                case .dynamic:
                    return Font.custom(
                        name,
                        size: role.customSize,
                        relativeTo: role.swiftUITextStyle
                    )
                }
            }
        #elseif os(macOS)
            Font(nsFont)
        #endif
    }

    #if os(iOS)
        /// The font resolved for the current UIKit environment.
        public var uiFont: UIFont {
            resolveUIFont(compatibleWith: nil)
        }

    #endif

    init(role: Role, family: PKYFontFamily, scaling: PKYTypographyTheme.Scaling) {
        self.role = role
        self.family = family
        self.scaling = scaling
        weight = role.standardWeight
        isItalic = false
        isRounded = false
    }

    #if os(iOS)
        private static func systemUIFont(
            size: CGFloat,
            weight: PKYFontWeight,
            isItalic: Bool,
            isRounded: Bool
        ) -> UIFont {
            var descriptor = UIFont.systemFont(
                ofSize: size,
                weight: weight.uiKitValue
            ).fontDescriptor
            if isItalic,
               let italic = descriptor.withSymbolicTraits(
                   descriptor.symbolicTraits.union(.traitItalic)
               ) {
                descriptor = italic
            }
            if isRounded, let rounded = descriptor.withDesign(.rounded) {
                descriptor = rounded
            }
            return UIFont(descriptor: descriptor, size: size)
        }

        /// Resolves a font for a specific UIKit environment when a component updates its typography.
        ///
        /// - Parameter traits: The target view's trait environment.
        /// - Returns: A role font following the theme's scaling policy.
        public func uiFont(compatibleWith traits: UITraitCollection) -> UIFont {
            resolveUIFont(compatibleWith: traits)
        }

        /// Resolves a component's reference size while retaining the theme's scaling policy.
        ///
        /// Use for component-owned sizes such as a welcome page recipe; ordinary text uses `uiFont`.
        ///
        /// - Parameters:
        ///   - referenceSize: The size used directly for fixed scaling or as the Dynamic Type baseline.
        ///   - traits: The target view's traits, or the current environment when omitted.
        /// - Returns: A font preserving face, weight, and design with the theme's scaling ceiling.
        public func uiFont(
            referenceSize: CGFloat,
            compatibleWith traits: UITraitCollection? = nil
        ) -> UIFont {
            let base: UIFont = switch family.resolvedFace(
                weight: weight,
                isItalic: isItalic,
                size: referenceSize
            ) {
            case let .system(weight, isItalic):
                Self.systemUIFont(
                    size: referenceSize,
                    weight: weight,
                    isItalic: isItalic,
                    isRounded: isRounded
                )
            case let .custom(name):
                UIFont(name: name, size: referenceSize) ?? Self.systemUIFont(
                    size: referenceSize,
                    weight: weight,
                    isItalic: isItalic,
                    isRounded: isRounded
                )
            }
            switch scaling {
            case .fixed:
                return base
            case let .dynamic(maximum):
                let metrics = UIFontMetrics(forTextStyle: role.uiKitTextStyle)
                let ceiling = metrics.scaledValue(
                    for: referenceSize,
                    compatibleWith: UITraitCollection(
                        preferredContentSizeCategory: UIContentSizeCategory(maximum)
                    )
                )
                return metrics.scaledFont(
                    for: base,
                    maximumPointSize: ceiling,
                    compatibleWith: traits
                )
            }
        }

    #endif

    private func withWeight(_ weight: PKYFontWeight) -> PKYTextStyle {
        var copy = self
        copy.weight = weight
        return copy
    }

    #if os(iOS)
        private func resolveUIFont(compatibleWith traits: UITraitCollection?) -> UIFont {
            let face = family.resolvedFace(
                weight: weight,
                isItalic: isItalic,
                size: role.customSize
            )
            switch face {
            case let .system(weight, isItalic):
                let size = systemPointSize(compatibleWith: traits)
                return Self.systemUIFont(
                    size: size,
                    weight: weight,
                    isItalic: isItalic,
                    isRounded: isRounded
                )
            case let .custom(name):
                guard let base = UIFont(name: name, size: role.customSize) else {
                    return Self.systemUIFont(
                        size: systemPointSize(compatibleWith: traits),
                        weight: weight,
                        isItalic: isItalic,
                        isRounded: isRounded
                    )
                }
                switch scaling {
                case .fixed:
                    return base
                case let .dynamic(maximum):
                    let metrics = UIFontMetrics(forTextStyle: role.uiKitTextStyle)
                    return metrics.scaledFont(
                        for: base,
                        maximumPointSize: maximumPointSize(metrics: metrics, maximum: maximum),
                        compatibleWith: traits
                    )
                }
            }
        }

        private func systemPointSize(compatibleWith traits: UITraitCollection?) -> CGFloat {
            let resolutionTraits: UITraitCollection?
            switch scaling {
            case .fixed:
                resolutionTraits = UITraitCollection(preferredContentSizeCategory: .large)
            case let .dynamic(maximum):
                let maximumTraits = UITraitCollection(
                    preferredContentSizeCategory: UIContentSizeCategory(maximum)
                )
                let current = UIFont.preferredFont(
                    forTextStyle: role.uiKitTextStyle,
                    compatibleWith: traits
                ).pointSize
                let ceiling = UIFont.preferredFont(
                    forTextStyle: role.uiKitTextStyle,
                    compatibleWith: maximumTraits
                ).pointSize
                return min(current, ceiling)
            }

            return UIFont.preferredFont(
                forTextStyle: role.uiKitTextStyle,
                compatibleWith: resolutionTraits
            ).pointSize
        }

        private func maximumPointSize(
            metrics: UIFontMetrics,
            maximum: DynamicTypeSize
        ) -> CGFloat {
            metrics.scaledValue(
                for: role.customSize,
                compatibleWith: UITraitCollection(
                    preferredContentSizeCategory: UIContentSizeCategory(maximum)
                )
            )
        }
    #endif
}

enum PKYFontWeight: Int, Hashable, Sendable {
    case regular = 400
    case medium = 500
    case semibold = 600
    case bold = 700

    var rank: Int {
        rawValue
    }

    var swiftUIValue: Font.Weight {
        switch self {
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        }
    }

    #if os(iOS)
        var uiKitValue: UIFont.Weight {
            switch self {
            case .regular: .regular
            case .medium: .medium
            case .semibold: .semibold
            case .bold: .bold
            }
        }
    #elseif os(macOS)
        var nsFontValue: NSFont.Weight {
            switch self {
            case .regular: .regular
            case .medium: .medium
            case .semibold: .semibold
            case .bold: .bold
            }
        }
    #endif
}

#if os(macOS)
    public extension PKYTextStyle {
        /// Resolves the native preferred text-style size for either family, ignoring scaling.
        var nsFont: NSFont {
            nsFont(referenceSize: NSFont.preferredFont(
                forTextStyle: role.nsFontTextStyle,
                options: [:]
            ).pointSize)
        }

        /// Resolves an explicit reference size, preserving face, weight, italic, and rounded design.
        ///
        /// - Parameter referenceSize: The point size supplied by the caller; scaling is ignored.
        /// - Returns: A native font at the supplied reference size.
        func nsFont(referenceSize: CGFloat) -> NSFont {
            switch family.resolvedFace(weight: weight, isItalic: isItalic, size: referenceSize) {
            case let .system(weight, isItalic):
                Self.systemNSFont(
                    size: referenceSize,
                    weight: weight,
                    isItalic: isItalic,
                    isRounded: isRounded
                )
            case let .custom(name):
                NSFont(name: name, size: referenceSize) ?? Self.systemNSFont(
                    size: referenceSize,
                    weight: weight,
                    isItalic: isItalic,
                    isRounded: isRounded
                )
            }
        }

        private static func systemNSFont(
            size: CGFloat,
            weight: PKYFontWeight,
            isItalic: Bool,
            isRounded: Bool
        ) -> NSFont {
            let base = NSFont.systemFont(ofSize: size, weight: weight.nsFontValue)
            var descriptor = base.fontDescriptor
            if isItalic {
                descriptor = descriptor.withSymbolicTraits(descriptor.symbolicTraits.union(.italic))
            }
            if isRounded, let rounded = descriptor.withDesign(.rounded) {
                descriptor = rounded
            }
            return NSFont(descriptor: descriptor, size: size) ?? base
        }
    }
#endif
