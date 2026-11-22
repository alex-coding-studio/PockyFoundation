import CoreGraphics

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

enum PKYFontWeight: Int, Hashable, Sendable {
    case regular = 400
    case medium = 500
    case semibold = 600
    case bold = 700

    var rank: Int {
        rawValue
    }

    var nextHeavier: Self {
        switch self {
        case .regular: .medium
        case .medium: .semibold
        case .semibold, .bold: .bold
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

#if os(iOS)
    public extension PKYTypographyRole {
        func uiFont(in theme: PKYTheme, compatibleWith traits: UITraitCollection) -> UIFont {
            let font = resolvedFont(in: theme, traits: traits)
            return usesMonospacedDigits ? font.pkyMonospacedDigits : font
        }

        private static func usesBoldText(_ traits: UITraitCollection) -> Bool {
            let legibilityWeight = traits.legibilityWeight == .unspecified
                ? UITraitCollection.current.legibilityWeight
                : traits.legibilityWeight
            return legibilityWeight == .bold
        }

        private func resolvedFont(in theme: PKYTheme, traits: UITraitCollection) -> UIFont {
            let scaling = theme.typography.scaling
            let weight = weight ?? kind.standardWeight
            let boldText = Self.usesBoldText(traits)
            let size = referenceSize ?? kind.customSize
            let face = theme.typography.family.resolvedFace(
                weight: weight,
                isItalic: isItalic,
                size: size,
                boldText: boldText
            )
            if case let .custom(name) = face, let custom = UIFont(name: name, size: size) {
                return scaled(custom, referenceSize: size, scaling: scaling, traits: traits)
            }
            let systemWeight = boldText ? weight.nextHeavier : weight
            guard let referenceSize else {
                return systemFont(
                    size: systemPointSize(scaling: scaling, traits: traits),
                    weight: systemWeight
                )
            }
            return scaled(
                systemFont(size: referenceSize, weight: systemWeight),
                referenceSize: referenceSize,
                scaling: scaling,
                traits: traits
            )
        }

        private func systemFont(size: CGFloat, weight: PKYFontWeight) -> UIFont {
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
            let design: UIFontDescriptor.SystemDesign? = isMonospaced
                ? .monospaced
                : (isRounded ? .rounded : nil)
            if let design, let designed = descriptor.withDesign(design) {
                descriptor = designed
            }
            return UIFont(descriptor: descriptor, size: size)
        }

        private func systemPointSize(
            scaling: PKYTypographyTheme.Scaling,
            traits: UITraitCollection
        ) -> CGFloat {
            let style = kind.uiKitTextStyle
            guard case let .dynamic(maximum) = scaling else {
                return UIFont.preferredFont(
                    forTextStyle: style,
                    compatibleWith: UITraitCollection(preferredContentSizeCategory: .large)
                ).pointSize
            }
            let ceiling = UITraitCollection(
                preferredContentSizeCategory: UIContentSizeCategory(maximum)
            )
            return min(
                UIFont.preferredFont(forTextStyle: style, compatibleWith: traits).pointSize,
                UIFont.preferredFont(forTextStyle: style, compatibleWith: ceiling).pointSize
            )
        }

        private func scaled(
            _ font: UIFont,
            referenceSize: CGFloat,
            scaling: PKYTypographyTheme.Scaling,
            traits: UITraitCollection
        ) -> UIFont {
            guard case let .dynamic(maximum) = scaling else {
                return font
            }
            let metrics = UIFontMetrics(forTextStyle: kind.uiKitTextStyle)
            let ceiling = metrics.scaledValue(
                for: referenceSize,
                compatibleWith: UITraitCollection(
                    preferredContentSizeCategory: UIContentSizeCategory(maximum)
                )
            )
            return metrics.scaledFont(for: font, maximumPointSize: ceiling, compatibleWith: traits)
        }
    }

#elseif os(macOS)
    public extension PKYTypographyRole {
        func nsFont(in theme: PKYTheme) -> NSFont {
            let font = resolvedFont(in: theme)
            return usesMonospacedDigits ? font.pkyMonospacedDigits : font
        }

        private func resolvedFont(in theme: PKYTheme) -> NSFont {
            let weight = weight ?? kind.standardWeight
            let size = referenceSize ?? NSFont.preferredFont(
                forTextStyle: kind.nsFontTextStyle,
                options: [:]
            ).pointSize
            let face = theme.typography.family.resolvedFace(
                weight: weight,
                isItalic: isItalic,
                size: size
            )
            if case let .custom(name) = face, let custom = NSFont(name: name, size: size) {
                return custom
            }
            return systemFont(size: size, weight: weight)
        }

        private func systemFont(size: CGFloat, weight: PKYFontWeight) -> NSFont {
            let base = NSFont.systemFont(ofSize: size, weight: weight.nsFontValue)
            var descriptor = base.fontDescriptor
            if isItalic {
                descriptor = descriptor.withSymbolicTraits(descriptor.symbolicTraits.union(.italic))
            }
            let design: NSFontDescriptor.SystemDesign? = isMonospaced
                ? .monospaced
                : (isRounded ? .rounded : nil)
            if let design, let designed = descriptor.withDesign(design) {
                descriptor = designed
            }
            return NSFont(descriptor: descriptor, size: size) ?? base
        }
    }
#endif
