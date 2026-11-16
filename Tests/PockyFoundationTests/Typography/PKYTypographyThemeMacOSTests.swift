#if os(macOS)
    import AppKit
    import PockyFoundation
    import SwiftUI
    import Testing

    @MainActor
    struct PKYTypographyThemeMacOSTests {
        @Test("S2-03/T01 Both families use native preferred text-style sizes and ignore scaling")
        func nativeSizesAndScalingPolicy() {
            let native: [NSFont.TextStyle] = [
                .largeTitle,
                .title1,
                .title2,
                .headline,
                .body,
                .subheadline,
                .footnote,
                .body,
            ]
            for family in [PKYFontFamily.system, .custom(regular: "HelveticaNeue")] {
                let fixed = PKYTypographyTheme(family: family, scaling: .fixed)
                let dynamic = PKYTypographyTheme(
                    family: family,
                    scaling: .dynamic(maximum: .accessibility5)
                )
                let fixedStyles = [
                    fixed.display,
                    fixed.pageTitle,
                    fixed.title,
                    fixed.heading,
                    fixed.body,
                    fixed.supporting,
                    fixed.caption,
                    fixed.action,
                ]
                let dynamicStyles = [
                    dynamic.display,
                    dynamic.pageTitle,
                    dynamic.title,
                    dynamic.heading,
                    dynamic.body,
                    dynamic.supporting,
                    dynamic.caption,
                    dynamic.action,
                ]
                for (style, textStyle) in zip(fixedStyles, native) {
                    #expect(style.nsFont.pointSize == NSFont.preferredFont(
                        forTextStyle: textStyle,
                        options: [:]
                    ).pointSize)
                }
                for (plain, scaled) in zip(fixedStyles, dynamicStyles) {
                    #expect(plain.nsFont.pointSize == scaled.nsFont.pointSize)
                }
                let sizes = fixedStyles.dropLast().map(\.nsFont.pointSize)
                #expect(zip(sizes, sizes.dropFirst()).allSatisfy { $0 >= $1 })
            }
        }

        @Test(
            "S2-03/T02 Weight, italic, and rounded modifiers preserve size and native descriptor traits"
        )
        func modifiersPreserveNativeTraits() throws {
            let theme = PKYTypographyTheme.system(scaling: .fixed)
            let regular = theme.body.regular.nsFont
            let bold = theme.body.bold.nsFont
            let italic = theme.body.italic.nsFont
            let rounded = theme.body.rounded.nsFont
            let regularTraits = try #require(
                regular.fontDescriptor.object(forKey: .traits) as? [NSFontDescriptor.TraitKey: Any]
            )
            let boldTraits = try #require(
                bold.fontDescriptor.object(forKey: .traits) as? [NSFontDescriptor.TraitKey: Any]
            )
            let regularWeight = try #require(regularTraits[.weight] as? NSNumber)
            let boldWeight = try #require(boldTraits[.weight] as? NSNumber)
            #expect(boldWeight.doubleValue > regularWeight.doubleValue)
            #expect(italic.fontDescriptor.symbolicTraits.contains(.italic))
            #expect(!italic.fontDescriptor.isEqual(regular.fontDescriptor))
            #expect(!rounded.fontDescriptor.isEqual(regular.fontDescriptor))
            #expect(italic.pointSize == regular.pointSize)
            #expect(rounded.pointSize == regular.pointSize)
            #expect(
                theme.body.bold.italic.nsFont.fontName == theme.body.italic.bold.nsFont.fontName
            )
            #expect(
                theme.body.bold.rounded.nsFont.fontName == theme.body.rounded.bold.nsFont.fontName
            )
        }

        @Test(
            "S2-03/T03 Monospaced digits add the number-spacing feature while preserving the font"
        )
        func monospacedDigitsPreserveFaceAndAddFeature() throws {
            let original = NSFont.systemFont(
                ofSize: NSFont.preferredFont(forTextStyle: .body, options: [:]).pointSize,
                weight: .semibold
            )
            let font = original.pkyMonospacedDigits
            let features = try #require(
                font.fontDescriptor.object(forKey: .featureSettings) as? [
                    [NSFontDescriptor.FeatureKey: Int]
                ]
            )
            #expect(features.contains {
                $0[.typeIdentifier] == kNumberSpacingType && $0[
                    .selectorIdentifier
                ] == kMonospacedNumbersSelector
            })
            #expect(font.familyName == original.familyName)
            #expect(font.pointSize == original.pointSize)
            #expect(font.fontDescriptor.symbolicTraits == original.fontDescriptor.symbolicTraits)
            #expect(font.pkyMonospacedDigits.fontDescriptor.isEqual(font.fontDescriptor))
        }

        @Test(
            "S2-03/T04 Explicit and stored reference sizes survive role composition and overrides"
        )
        func referenceSizesFollowCallerInput() {
            let reference: CGFloat = 31
            let override: CGFloat = 23
            let typography = PKYTypographyTheme.system(scaling: .dynamic(maximum: .accessibility5))
            #expect(
                typography.display.bold.rounded.nsFont(
                    referenceSize: reference
                ).pointSize == reference
            )
            let theme = PKYTheme(
                color: .system(accent: .init(
                    primary: .systemBlue,
                    secondary: .systemTeal,
                    onAccent: .white
                )),
                typography: typography
            )
            let role = PKYTypographyRole.body.withReferenceSize(
                reference
            ).bold.italic.monospacedDigits
            let resolved = role.nsFont(in: theme)
            #expect(resolved.pointSize == reference)
            #expect(resolved.fontDescriptor.symbolicTraits.contains(.italic))
            #expect(role.nsFont(in: theme, referenceSize: override).pointSize == override)
            let features = resolved.fontDescriptor.object(forKey: .featureSettings) as? [
                [NSFontDescriptor.FeatureKey: Int]
            ]
            #expect(
                features?.contains { $0[.selectorIdentifier] == kMonospacedNumbersSelector } == true
            )
        }

        @Test(
            "S2-03/T05 Custom faces fall back through matching upright and nearest available weight"
        )
        func customFacesRetainFallbackOrder() {
            let family = PKYFontFamily.custom(regular: "HelveticaNeue", bold: "HelveticaNeue-Bold")
            let theme = PKYTypographyTheme(family: family, scaling: .fixed)
            #expect(theme.body.bold.italic.nsFont.fontName == theme.body.bold.nsFont.fontName)
            #expect(theme.body.medium.nsFont.fontName == theme.body.regular.nsFont.fontName)
            #expect(theme.body.semibold.nsFont.fontName == theme.body.bold.nsFont.fontName)
            #expect(theme.body.rounded.nsFont.fontName == theme.body.nsFont.fontName)
            let italicFamily = PKYFontFamily.custom(
                regular: "HelveticaNeue",
                boldItalic: "HelveticaNeue-BoldItalic"
            )
            let italic = PKYTypographyTheme(
                family: italicFamily,
                scaling: .fixed
            ).body.bold.italic.nsFont
            #expect(italic.fontName == "HelveticaNeue-BoldItalic")
        }

        @Test("S2-03/T06 Unloadable custom faces fall back to the equivalent system font")
        func unloadableCustomFaceUsesSystemFont() {
            let family = PKYFontFamily.custom(
                regular: "PKYMissingTypographyFace",
                boldItalic: "PKYMissingBoldItalicFace"
            )
            let custom = PKYTypographyTheme(family: family, scaling: .fixed).body.bold.italic.nsFont
            let system = PKYTypographyTheme.system(scaling: .fixed).body.bold.italic.nsFont
            #expect(custom.fontName == system.fontName)
            #expect(custom.pointSize == system.pointSize)
            #expect(custom.fontDescriptor.symbolicTraits == system.fontDescriptor.symbolicTraits)
        }
    }
#endif
