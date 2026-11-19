#if os(macOS)
    import AppKit
    import PockyFoundation
    import SwiftUI
    import Testing

    @MainActor
    struct PKYTypographyThemeMacOSTests {
        static func theme(
            _ family: PKYFontFamily = .system,
            scaling: PKYTypographyTheme.Scaling = .fixed
        ) -> PKYTheme {
            PKYTheme(
                color: PKYThemeFallback.system.color,
                typography: PKYTypographyTheme(family: family, scaling: scaling)
            )
        }

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
            let roles: [PKYTypographyRole] = [
                .display,
                .pageTitle,
                .title,
                .heading,
                .body,
                .supporting,
                .caption,
                .action,
            ]
            for family in [PKYFontFamily.system, .custom(regular: "HelveticaNeue")] {
                let fixed = Self.theme(family)
                let dynamic = Self.theme(family, scaling: .dynamic(maximum: .accessibility5))
                for (role, textStyle) in zip(roles, native) {
                    #expect(role.nsFont(in: fixed).pointSize == NSFont.preferredFont(
                        forTextStyle: textStyle,
                        options: [:]
                    ).pointSize)
                    #expect(role.nsFont(in: fixed).pointSize == role.nsFont(in: dynamic).pointSize)
                }
                let sizes = roles.dropLast().map { $0.nsFont(in: fixed).pointSize }
                #expect(zip(sizes, sizes.dropFirst()).allSatisfy { $0 >= $1 })
            }
        }

        @Test(
            "S2-03/T02 Weight, italic, and rounded modifiers preserve size and native descriptor traits"
        )
        func modifiersPreserveNativeTraits() throws {
            let theme = Self.theme()
            let regular = PKYTypographyRole.body.regular.nsFont(in: theme)
            let bold = PKYTypographyRole.body.bold.nsFont(in: theme)
            let italic = PKYTypographyRole.body.italic.nsFont(in: theme)
            let rounded = PKYTypographyRole.body.rounded.nsFont(in: theme)
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
                PKYTypographyRole.body.bold.italic.nsFont(in: theme).fontName
                    == PKYTypographyRole.body.italic.bold.nsFont(in: theme).fontName
            )
            #expect(
                PKYTypographyRole.body.bold.rounded.nsFont(in: theme).fontName
                    == PKYTypographyRole.body.rounded.bold.nsFont(in: theme).fontName
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

        @Test("S2-03/T04 Reference sizes survive role composition and the latest size wins")
        func referenceSizesFollowCallerInput() {
            let reference: CGFloat = 31
            let override: CGFloat = 23
            let theme = Self.theme(scaling: .dynamic(maximum: .accessibility5))
            #expect(
                PKYTypographyRole.display.bold.rounded.withReferenceSize(reference).nsFont(
                    in: theme
                ).pointSize == reference
            )
            let role = PKYTypographyRole.body.withReferenceSize(
                reference
            ).bold.italic.monospacedDigits
            let resolved = role.nsFont(in: theme)
            #expect(resolved.pointSize == reference)
            #expect(resolved.fontDescriptor.symbolicTraits.contains(.italic))
            #expect(role.withReferenceSize(override).nsFont(in: theme).pointSize == override)
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
            let theme = Self.theme(.custom(regular: "HelveticaNeue", bold: "HelveticaNeue-Bold"))
            func name(_ role: PKYTypographyRole) -> String {
                role.nsFont(in: theme).fontName
            }
            #expect(name(.body.bold.italic) == name(.body.bold))
            #expect(name(.body.medium) == name(.body.regular))
            #expect(name(.body.semibold) == name(.body.bold))
            #expect(name(.body.rounded) == name(.body))
            let italic = PKYTypographyRole.body.bold.italic.nsFont(in: Self.theme(.custom(
                regular: "HelveticaNeue",
                boldItalic: "HelveticaNeue-BoldItalic"
            )))
            #expect(italic.fontName == "HelveticaNeue-BoldItalic")
        }

        @Test("S2-03/T06 Unloadable custom faces fall back to the equivalent system font")
        func unloadableCustomFaceUsesSystemFont() {
            let role = PKYTypographyRole.body.bold.italic
            let custom = role.nsFont(in: Self.theme(.custom(
                regular: "PKYMissingTypographyFace",
                boldItalic: "PKYMissingBoldItalicFace"
            )))
            let system = role.nsFont(in: Self.theme())
            #expect(custom.fontName == system.fontName)
            #expect(custom.pointSize == system.pointSize)
            #expect(custom.fontDescriptor.symbolicTraits == system.fontDescriptor.symbolicTraits)
        }

        @Test(
            "S2-03/T07 Monospaced role resolves a fixed-pitch font, keeps role size, and overrides rounded"
        )
        func monospacedRolePreservesSizeAndOverridesRounded() {
            let theme = PKYThemeFallback.system
            let plain = PKYTypographyRole.body.nsFont(in: theme)
            let monospaced = PKYTypographyRole.body.monospaced.nsFont(in: theme)
            #expect(monospaced.isFixedPitch)
            #expect(monospaced.fontDescriptor.symbolicTraits.contains(.monoSpace))
            #expect(monospaced.pointSize == plain.pointSize)
            #expect(monospaced.fontName != plain.fontName)
            #expect(
                PKYTypographyRole.body.rounded.monospaced.nsFont(in: theme).fontName
                    == monospaced.fontName
            )
            #expect(
                PKYTypographyRole.body.monospaced.rounded.nsFont(in: theme).fontName
                    == monospaced.fontName
            )
            let custom = Self.theme(.custom(regular: "HelveticaNeue"))
            #expect(
                PKYTypographyRole.body.monospaced.nsFont(in: custom).fontName
                    == PKYTypographyRole.body.nsFont(in: custom).fontName
            )
        }
    }
#endif
