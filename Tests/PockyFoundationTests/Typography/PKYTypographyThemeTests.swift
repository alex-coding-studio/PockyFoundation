#if os(iOS)
    import PockyFoundation
    import SwiftUI
    import Testing
    import UIKit

    @MainActor
    struct PKYTypographyThemeTests {
        static let customFamily = PKYFontFamily.custom(
            regular: "HelveticaNeue",
            medium: "HelveticaNeue-Medium",
            semibold: "HelveticaNeue-Medium",
            bold: "HelveticaNeue-Bold",
            italic: "HelveticaNeue-Italic",
            mediumItalic: "HelveticaNeue-MediumItalic",
            boldItalic: "HelveticaNeue-BoldItalic"
        )

        @Test("Bold Text increases UIKit weight for system and custom faces", arguments: [
            PKYFontFamily.system,
            PKYFontFamily.custom(regular: "HelveticaNeue", bold: "HelveticaNeue-Bold"),
        ])
        func boldTextIncreasesUIKitWeight(family: PKYFontFamily) throws {
            let style = PKYTypographyTheme(
                family: family,
                scaling: .dynamic(maximum: .xxxLarge)
            ).body
            let regular = UITraitCollection { $0.legibilityWeight = .regular }
            let bold = UITraitCollection { $0.legibilityWeight = .bold }

            #expect(try fontWeight(style.uiFont(compatibleWith: bold))
                > fontWeight(style.uiFont(compatibleWith: regular)))
            #expect(try fontWeight(style.uiFont(referenceSize: 17, compatibleWith: bold))
                > fontWeight(style.uiFont(referenceSize: 17, compatibleWith: regular)))
        }

        @Test("SwiftUI Bold Text selects a heavier custom face from the environment")
        func swiftUIBoldTextChangesCustomFace() throws {
            let family = PKYFontFamily.custom(regular: "HelveticaNeue", bold: "HelveticaNeue-Bold")
            let style = PKYTypographyTheme(family: family, scaling: .fixed).body

            func renderedText(_ weight: LegibilityWeight) throws -> Data {
                let renderer = ImageRenderer(content: Text("Bold Text")
                    .pkyFont(style)
                    .environment(\.legibilityWeight, weight)
                    .fixedSize())
                return try #require(renderer.uiImage?.pngData())
            }

            #expect(try renderedText(.bold) != renderedText(.regular))
        }

        @Test("S2-02/T01 System roles use their corresponding native Apple text styles")
        func systemRolesUseNativeTextStyles() {
            let theme = PKYTypographyTheme.system(scaling: .fixed)
            let largeTraits = UITraitCollection(preferredContentSizeCategory: .large)

            #expect(theme.display.uiFont.pointSize == preferredSize(
                .largeTitle,
                traits: largeTraits
            ))
            #expect(theme.pageTitle.uiFont.pointSize == preferredSize(.title1, traits: largeTraits))
            #expect(theme.title.uiFont.pointSize == preferredSize(.title2, traits: largeTraits))
            #expect(theme.heading.uiFont.pointSize == preferredSize(.headline, traits: largeTraits))
            #expect(theme.body.uiFont.pointSize == preferredSize(.body, traits: largeTraits))
            #expect(theme.supporting.uiFont.pointSize == preferredSize(
                .subheadline,
                traits: largeTraits
            ))
            #expect(theme.caption.uiFont.pointSize == preferredSize(.footnote, traits: largeTraits))
            #expect(theme.action.uiFont.pointSize == preferredSize(.body, traits: largeTraits))
        }

        @Test("S2-02/T02 Custom roles select the supplied faces and preserve the size hierarchy")
        func customRolesUseReferenceSizesAndStandardWeights() {
            let theme = PKYTypographyTheme(family: Self.customFamily, scaling: .fixed)

            let sizes = [
                theme.display,
                theme.pageTitle,
                theme.title,
                theme.heading,
                theme.body,
                theme.supporting,
                theme.caption,
            ]
            .map(\.uiFont.pointSize)
            #expect(zip(sizes, sizes.dropFirst()).allSatisfy { $0 > $1 })
            #expect(theme.action.uiFont.pointSize == theme.body.uiFont.pointSize)

            #expect(theme.display.uiFont.fontName == "HelveticaNeue-Bold")
            #expect(theme.pageTitle.uiFont.fontName == "HelveticaNeue-Bold")
            #expect(theme.title.uiFont.fontName == "HelveticaNeue-Medium")
            #expect(theme.heading.uiFont.fontName == "HelveticaNeue-Medium")
            #expect(theme.body.uiFont.fontName == "HelveticaNeue")
            #expect(theme.action.uiFont.fontName == "HelveticaNeue-Medium")
        }

        @Test(
            "S2-02/T03 Weight and italic modifiers compose in either order without changing role size"
        )
        func systemWeightAndItalicCompose() {
            let theme = PKYTypographyTheme.system(scaling: .fixed)
            let weightThenItalic = theme.body.bold.italic.uiFont
            let italicThenWeight = theme.body.italic.bold.uiFont

            #expect(weightThenItalic.pointSize == theme.body.uiFont.pointSize)
            #expect(weightThenItalic.fontName == italicThenWeight.fontName)
            #expect(weightThenItalic.fontDescriptor.symbolicTraits.contains(.traitBold))
            #expect(weightThenItalic.fontDescriptor.symbolicTraits.contains(.traitItalic))
        }

        @Test(
            "S2-02/T04 A missing custom italic face falls back to the upright face at the same weight"
        )
        func missingCustomItalicFallsBackToUprightWeight() {
            let family = PKYFontFamily.custom(
                regular: "HelveticaNeue",
                bold: "HelveticaNeue-Bold"
            )
            let theme = PKYTypographyTheme(family: family, scaling: .fixed)

            #expect(theme.body.bold.italic.uiFont.fontName == "HelveticaNeue-Bold")
        }

        @Test("S2-02/T05 A supplied custom bold italic face is used")
        func suppliedCustomBoldItalicIsUsed() {
            let theme = PKYTypographyTheme(family: Self.customFamily, scaling: .fixed)

            #expect(theme.body.bold.italic.uiFont.fontName == "HelveticaNeue-BoldItalic")
        }

        @Test("S2-02/T06 A missing custom weight falls back to the nearest available upright face")
        func missingCustomWeightUsesNearestAvailableUpright() {
            let family = PKYFontFamily.custom(
                regular: "HelveticaNeue",
                bold: "HelveticaNeue-Bold"
            )
            let theme = PKYTypographyTheme(family: family, scaling: .fixed)

            #expect(theme.body.medium.uiFont.fontName == "HelveticaNeue")
            #expect(theme.body.semibold.uiFont.fontName == "HelveticaNeue-Bold")
        }

        @Test("S2-02/T07 Fixed typography ignores UIKit content-size changes")
        func fixedTypographyIgnoresContentSizeCategory() {
            let theme = PKYTypographyTheme(family: Self.customFamily, scaling: .fixed)
            let large = theme.body.uiFont(
                compatibleWith: UITraitCollection(preferredContentSizeCategory: .large)
            )
            let accessibility = theme.body.uiFont(
                compatibleWith: UITraitCollection(
                    preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge
                )
            )

            #expect(accessibility.pointSize == large.pointSize)
        }

        @Test(
            "S2-02/T08 Dynamic typography scales with Apple categories and clamps to its explicit maximum"
        )
        func dynamicTypographyClampsToMaximum() {
            let theme = PKYTypographyTheme(
                family: Self.customFamily,
                scaling: .dynamic(maximum: .xxxLarge)
            )
            let large = theme.body.uiFont(
                compatibleWith: UITraitCollection(preferredContentSizeCategory: .large)
            )
            let maximum = theme.body.uiFont(
                compatibleWith: UITraitCollection(
                    preferredContentSizeCategory: .extraExtraExtraLarge
                )
            )
            let beyondMaximum = theme.body.uiFont(
                compatibleWith: UITraitCollection(
                    preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge
                )
            )

            #expect(maximum.pointSize > large.pointSize)
            #expect(beyondMaximum.pointSize == maximum.pointSize)
        }

        @Test("S2-02/T09 Custom SwiftUI fonts scale relative to the role with Dynamic Type")
        func customSwiftUIFontScalesWithDynamicType() {
            let theme = PKYTypographyTheme(
                family: Self.customFamily,
                scaling: .dynamic(maximum: .accessibility5)
            )
            let large = renderedSize(theme.body.font, dynamicTypeSize: .large)
            let accessibility = renderedSize(theme.body.font, dynamicTypeSize: .accessibility3)

            #expect(accessibility.width > large.width)
            #expect(accessibility.height > large.height)
        }

        @Test("S2-02/T10 System rounded design preserves size and weight")
        func systemRoundedUsesRoundedDesign() {
            let theme = PKYTypographyTheme.system(scaling: .fixed)
            let plain = theme.display.bold.uiFont
            let rounded = theme.display.bold.rounded.uiFont
            let appleRounded = UIFont.systemFont(ofSize: plain.pointSize, weight: .bold)
                .fontDescriptor
                .withDesign(.rounded)
                .map { UIFont(descriptor: $0, size: plain.pointSize) }

            #expect(rounded.pointSize == plain.pointSize)
            #expect(rounded.fontName != plain.fontName)
            #expect(rounded.fontName == appleRounded?.fontName)
            #expect(theme.title.rounded.font != theme.title.font)
        }

        @Test(
            "S2-02/T11 Rounded and weight modifiers compose in either order and repeated application is unchanged"
        )
        func roundedComposesWithWeightInAnyOrder() {
            let theme = PKYTypographyTheme.system(scaling: .fixed)

            #expect(
                theme.title.bold.rounded.uiFont.fontName == theme.title.rounded.bold.uiFont.fontName
            )
            #expect(
                theme.title.rounded.rounded.uiFont.fontName == theme.title.rounded.uiFont.fontName
            )
            #expect(theme.title.rounded.font == theme.title.rounded.rounded.font)
        }

        @Test("S2-02/T12 Rounded custom fonts retain their supplied face")
        func customRoundedKeepsCustomFace() {
            let theme = PKYTypographyTheme(family: Self.customFamily, scaling: .fixed)

            #expect(theme.body.rounded.uiFont.fontName == "HelveticaNeue")
            #expect(theme.body.bold.rounded.uiFont.fontName == "HelveticaNeue-Bold")
        }

        @Test("S2-02/T13 Reference sizes follow fixed or capped dynamic scaling")
        func referenceSizeFollowsScalingPolicy() {
            let referenceSize: CGFloat = 40
            let large = UITraitCollection(
                preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge
            )
            let fixed = PKYTypographyTheme.system(scaling: .fixed)
            let dynamic = PKYTypographyTheme.system(scaling: .dynamic(maximum: .xxxLarge))

            #expect(fixed.display.bold.uiFont(
                referenceSize: referenceSize,
                compatibleWith: large
            ).pointSize == referenceSize)
            let scaled = dynamic.display.bold.uiFont(
                referenceSize: referenceSize,
                compatibleWith: large
            ).pointSize
            let ceiling = UIFontMetrics(forTextStyle: .largeTitle).scaledValue(
                for: referenceSize,
                compatibleWith: UITraitCollection(
                    preferredContentSizeCategory: .extraExtraExtraLarge
                )
            )
            #expect(scaled > referenceSize)
            #expect(abs(scaled - ceiling) < 0.5)
        }

        @Test(
            "S2-02/T14 Role reference sizes survive composition and explicit resolution overrides"
        )
        func roleReferenceSizeSurvivesCompositionAndExplicitOverride() {
            let theme = PKYTheme(
                color: .system(accent: .init(
                    primary: .systemBlue,
                    secondary: .systemTeal,
                    onAccent: .white
                )),
                typography: .system(scaling: .fixed)
            )
            let traits = UITraitCollection(preferredContentSizeCategory: .large)
            let small = PKYTypographyRole.display.withReferenceSize(
                24
            ).bold.rounded.monospacedDigits
            let large = PKYTypographyRole.display.bold.rounded.monospacedDigits.withReferenceSize(
                48
            )
            #expect(large.uiFont(in: theme, compatibleWith: traits).pointSize > small.uiFont(
                in: theme,
                compatibleWith: traits
            ).pointSize)
            #expect(large.uiFont(
                in: theme,
                compatibleWith: traits,
                referenceSize: 12
            ).pointSize < small.uiFont(
                in: theme,
                compatibleWith: traits
            ).pointSize)
            #expect(
                small == PKYTypographyRole.display.bold.rounded.monospacedDigits.withReferenceSize(
                    24
                )
            )
            #expect(Set([small, large]).count == 2)
        }

        @Test(
            "S2-02/T15 Monospaced role resolves a monospaced descriptor, keeps role size, and overrides rounded"
        )
        func monospacedRolePreservesSizeAndOverridesRounded() {
            let theme = PKYThemeFallback.system
            let traits = UITraitCollection(preferredContentSizeCategory: .large)
            let plain = PKYTypographyRole.body.uiFont(in: theme, compatibleWith: traits)
            let monospaced = PKYTypographyRole.body.monospaced.uiFont(
                in: theme,
                compatibleWith: traits
            )
            let appleMonospaced = UIFont.systemFont(ofSize: plain.pointSize, weight: .regular)
                .fontDescriptor
                .withDesign(.monospaced)
                .map { UIFont(descriptor: $0, size: plain.pointSize) }

            #expect(monospaced.pointSize == plain.pointSize)
            #expect(monospaced.fontName != plain.fontName)
            #expect(monospaced.fontName == appleMonospaced?.fontName)
            #expect(monospaced.fontDescriptor.symbolicTraits.contains(.traitMonoSpace))
            #expect(
                PKYTypographyRole.body.rounded.monospaced.uiFont(
                    in: theme,
                    compatibleWith: traits
                ).fontName == monospaced.fontName
            )
            #expect(
                PKYTypographyRole.body.monospaced.rounded.uiFont(
                    in: theme,
                    compatibleWith: traits
                ).fontName == monospaced.fontName
            )
            #expect(theme.typography.body.monospaced.font != theme.typography.body.font)
            #expect(
                theme.typography.body.rounded.monospaced.font
                    == theme.typography.body.monospaced.font
            )
            let custom = PKYTypographyTheme(family: Self.customFamily, scaling: .fixed)
            #expect(custom.body.monospaced.uiFont.fontName == custom.body.uiFont.fontName)
        }

        private func fontWeight(_ font: UIFont) throws -> Double {
            let traits = font.fontDescriptor.object(forKey: .traits) as? NSDictionary
            return try #require(traits?[UIFontDescriptor.TraitKey.weight.rawValue] as? NSNumber)
                .doubleValue
        }

        private func preferredSize(
            _ style: UIFont.TextStyle,
            traits: UITraitCollection
        ) -> CGFloat {
            UIFont.preferredFont(forTextStyle: style, compatibleWith: traits).pointSize
        }

        private func renderedSize(_ font: Font, dynamicTypeSize: DynamicTypeSize) -> CGSize {
            let renderer = ImageRenderer(
                content: Text("MMMM").font(font).dynamicTypeSize(dynamicTypeSize).fixedSize()
            )
            renderer.scale = 1
            return renderer.uiImage?.size ?? .zero
        }
    }
#endif
