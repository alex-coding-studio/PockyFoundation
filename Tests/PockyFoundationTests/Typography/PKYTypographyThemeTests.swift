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

        static let largeTraits = UITraitCollection(preferredContentSizeCategory: .large)

        static let roles: [PKYTypographyRole] = [
            .display,
            .pageTitle,
            .title,
            .heading,
            .body,
            .supporting,
            .caption,
        ]

        static func theme(
            _ family: PKYFontFamily = .system,
            scaling: PKYTypographyTheme.Scaling = .fixed
        ) -> PKYTheme {
            PKYTheme(
                color: PKYThemeFallback.system.color,
                typography: PKYTypographyTheme(family: family, scaling: scaling)
            )
        }

        @Test("Bold Text increases UIKit weight for system and custom faces", arguments: [
            PKYFontFamily.system,
            PKYFontFamily.custom(regular: "HelveticaNeue", bold: "HelveticaNeue-Bold"),
        ])
        func boldTextIncreasesUIKitWeight(family: PKYFontFamily) throws {
            let theme = Self.theme(family, scaling: .dynamic(maximum: .xxxLarge))
            let regular = UITraitCollection { $0.legibilityWeight = .regular }
            let bold = UITraitCollection { $0.legibilityWeight = .bold }
            let sized = PKYTypographyRole.body.withReferenceSize(17)

            #expect(try fontWeight(PKYTypographyRole.body.uiFont(in: theme, compatibleWith: bold))
                > fontWeight(PKYTypographyRole.body.uiFont(in: theme, compatibleWith: regular)))
            #expect(try fontWeight(sized.uiFont(in: theme, compatibleWith: bold))
                > fontWeight(sized.uiFont(in: theme, compatibleWith: regular)))
        }

        @Test("SwiftUI Bold Text selects a heavier custom face from the environment")
        func swiftUIBoldTextChangesCustomFace() throws {
            let theme = Self.theme(.custom(regular: "HelveticaNeue", bold: "HelveticaNeue-Bold"))

            func renderedText(_ weight: LegibilityWeight) throws -> Data {
                let renderer = ImageRenderer(content: Text("Bold Text")
                    .pkyFont(.body)
                    .environment(\.legibilityWeight, weight)
                    .environment(\.pkyTheme, PKYThemeTraitValue(theme: theme))
                    .fixedSize())
                return try #require(renderer.uiImage?.pngData())
            }

            #expect(try renderedText(.bold) != renderedText(.regular))
        }

        @Test("SwiftUI roles render the UIKit font resolved for the same environment")
        func swiftUIRoleMatchesUIKitResolution() throws {
            let theme = Self.theme(scaling: .dynamic(maximum: .accessibility2))
            let role = PKYTypographyRole.caption.semibold.monospacedDigits.withReferenceSize(20)
            let traits = UITraitCollection {
                $0.preferredContentSizeCategory = .extraExtraExtraLarge
                $0.legibilityWeight = .bold
            }
            let expected = Font(role.uiFont(in: theme, compatibleWith: traits))

            func rendered(_ text: some View) throws -> Data {
                let renderer = ImageRenderer(content: text
                    .environment(\.pkyTheme, PKYThemeTraitValue(theme: theme))
                    .environment(\.legibilityWeight, .bold)
                    .dynamicTypeSize(.xxxLarge)
                    .fixedSize())
                return try #require(renderer.uiImage?.pngData())
            }

            let swiftUI = try rendered(Text("0123 Bold").pkyFont(role))
            #expect(try swiftUI == rendered(Text("0123 Bold").font(expected)))
        }

        @Test("S2-02/T01 System roles use their corresponding native Apple text styles")
        func systemRolesUseNativeTextStyles() {
            let theme = Self.theme()
            let native: [UIFont.TextStyle] = [
                .largeTitle,
                .title1,
                .title2,
                .headline,
                .body,
                .subheadline,
                .footnote,
            ]

            for (role, style) in zip(Self.roles + [.action], native + [.body]) {
                #expect(role.uiFont(in: theme, compatibleWith: Self.largeTraits).pointSize
                    == preferredSize(style, traits: Self.largeTraits))
            }
        }

        @Test("S2-02/T02 Custom roles select the supplied faces and preserve the size hierarchy")
        func customRolesUseReferenceSizesAndStandardWeights() {
            let theme = Self.theme(Self.customFamily)
            func font(_ role: PKYTypographyRole) -> UIFont {
                role.uiFont(in: theme, compatibleWith: Self.largeTraits)
            }

            let sizes = Self.roles.map { font($0).pointSize }
            #expect(zip(sizes, sizes.dropFirst()).allSatisfy { $0 > $1 })
            #expect(font(.action).pointSize == font(.body).pointSize)

            #expect(font(.display).fontName == "HelveticaNeue-Bold")
            #expect(font(.pageTitle).fontName == "HelveticaNeue-Bold")
            #expect(font(.title).fontName == "HelveticaNeue-Medium")
            #expect(font(.heading).fontName == "HelveticaNeue-Medium")
            #expect(font(.body).fontName == "HelveticaNeue")
            #expect(font(.action).fontName == "HelveticaNeue-Medium")
        }

        @Test(
            "S2-02/T03 Weight and italic modifiers compose in either order without changing role size"
        )
        func systemWeightAndItalicCompose() {
            let theme = Self.theme()
            let weightThenItalic = PKYTypographyRole.body.bold.italic.uiFont(
                in: theme,
                compatibleWith: Self.largeTraits
            )
            let italicThenWeight = PKYTypographyRole.body.italic.bold.uiFont(
                in: theme,
                compatibleWith: Self.largeTraits
            )

            #expect(weightThenItalic.pointSize == PKYTypographyRole.body.uiFont(
                in: theme,
                compatibleWith: Self.largeTraits
            ).pointSize)
            #expect(weightThenItalic.fontName == italicThenWeight.fontName)
            #expect(weightThenItalic.fontDescriptor.symbolicTraits.contains(.traitBold))
            #expect(weightThenItalic.fontDescriptor.symbolicTraits.contains(.traitItalic))
        }

        @Test(
            "S2-02/T04 A missing custom italic face falls back to the upright face at the same weight"
        )
        func missingCustomItalicFallsBackToUprightWeight() {
            let theme = Self.theme(.custom(regular: "HelveticaNeue", bold: "HelveticaNeue-Bold"))

            #expect(PKYTypographyRole.body.bold.italic.uiFont(
                in: theme,
                compatibleWith: Self.largeTraits
            ).fontName == "HelveticaNeue-Bold")
        }

        @Test("S2-02/T05 A supplied custom bold italic face is used")
        func suppliedCustomBoldItalicIsUsed() {
            #expect(PKYTypographyRole.body.bold.italic.uiFont(
                in: Self.theme(Self.customFamily),
                compatibleWith: Self.largeTraits
            ).fontName == "HelveticaNeue-BoldItalic")
        }

        @Test("S2-02/T06 A missing custom weight falls back to the nearest available upright face")
        func missingCustomWeightUsesNearestAvailableUpright() {
            let theme = Self.theme(.custom(regular: "HelveticaNeue", bold: "HelveticaNeue-Bold"))

            #expect(PKYTypographyRole.body.medium.uiFont(
                in: theme,
                compatibleWith: Self.largeTraits
            ).fontName == "HelveticaNeue")
            #expect(PKYTypographyRole.body.semibold.uiFont(
                in: theme,
                compatibleWith: Self.largeTraits
            ).fontName == "HelveticaNeue-Bold")
        }

        @Test("S2-02/T07 Fixed typography ignores UIKit content-size changes")
        func fixedTypographyIgnoresContentSizeCategory() {
            let theme = Self.theme(Self.customFamily)
            let large = PKYTypographyRole.body.uiFont(in: theme, compatibleWith: Self.largeTraits)
            let accessibility = PKYTypographyRole.body.uiFont(
                in: theme,
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
            let theme = Self.theme(Self.customFamily, scaling: .dynamic(maximum: .xxxLarge))
            let large = PKYTypographyRole.body.uiFont(in: theme, compatibleWith: Self.largeTraits)
            let maximum = PKYTypographyRole.body.uiFont(
                in: theme,
                compatibleWith: UITraitCollection(
                    preferredContentSizeCategory: .extraExtraExtraLarge
                )
            )
            let beyondMaximum = PKYTypographyRole.body.uiFont(
                in: theme,
                compatibleWith: UITraitCollection(
                    preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge
                )
            )

            #expect(maximum.pointSize > large.pointSize)
            #expect(beyondMaximum.pointSize == maximum.pointSize)
        }

        @Test("S2-02/T09 SwiftUI roles scale with Dynamic Type up to the theme maximum")
        func swiftUIRoleScalesWithDynamicTypeUpToMaximum() {
            let theme = Self.theme(Self.customFamily, scaling: .dynamic(maximum: .xxxLarge))
            let large = renderedSize(.body, theme: theme, dynamicTypeSize: .large)
            let maximum = renderedSize(.body, theme: theme, dynamicTypeSize: .xxxLarge)
            let beyondMaximum = renderedSize(.body, theme: theme, dynamicTypeSize: .accessibility3)

            #expect(maximum.width > large.width)
            #expect(maximum.height > large.height)
            #expect(beyondMaximum == maximum)
        }

        @Test("S2-02/T10 System rounded design preserves size and weight")
        func systemRoundedUsesRoundedDesign() {
            let theme = Self.theme()
            let plain = PKYTypographyRole.display.bold.uiFont(
                in: theme,
                compatibleWith: Self.largeTraits
            )
            let rounded = PKYTypographyRole.display.bold.rounded.uiFont(
                in: theme,
                compatibleWith: Self.largeTraits
            )
            let appleRounded = UIFont.systemFont(ofSize: plain.pointSize, weight: .bold)
                .fontDescriptor
                .withDesign(.rounded)
                .map { UIFont(descriptor: $0, size: plain.pointSize) }

            #expect(rounded.pointSize == plain.pointSize)
            #expect(rounded.fontName != plain.fontName)
            #expect(rounded.fontName == appleRounded?.fontName)
        }

        @Test(
            "S2-02/T11 Rounded and weight modifiers compose in either order and repeated application is unchanged"
        )
        func roundedComposesWithWeightInAnyOrder() {
            let theme = Self.theme()
            func name(_ role: PKYTypographyRole) -> String {
                role.uiFont(in: theme, compatibleWith: Self.largeTraits).fontName
            }

            #expect(name(.title.bold.rounded) == name(.title.rounded.bold))
            #expect(name(.title.rounded.rounded) == name(.title.rounded))
            #expect(PKYTypographyRole.title.rounded.rounded == .title.rounded)
        }

        @Test("S2-02/T12 Rounded custom fonts retain their supplied face")
        func customRoundedKeepsCustomFace() {
            let theme = Self.theme(Self.customFamily)

            #expect(PKYTypographyRole.body.rounded.uiFont(
                in: theme,
                compatibleWith: Self.largeTraits
            ).fontName == "HelveticaNeue")
            #expect(PKYTypographyRole.body.bold.rounded.uiFont(
                in: theme,
                compatibleWith: Self.largeTraits
            ).fontName == "HelveticaNeue-Bold")
        }

        @Test("S2-02/T13 Reference sizes follow fixed or capped dynamic scaling")
        func referenceSizeFollowsScalingPolicy() {
            let role = PKYTypographyRole.display.bold.withReferenceSize(40)
            let fixed = Self.theme()
            let dynamic = Self.theme(scaling: .dynamic(maximum: .xxxLarge))
            let maximum = UITraitCollection(preferredContentSizeCategory: .extraExtraExtraLarge)
            let beyondMaximum = UITraitCollection(
                preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge
            )

            let fixedSize = role.uiFont(in: fixed, compatibleWith: Self.largeTraits).pointSize
            let cappedSize = role.uiFont(in: dynamic, compatibleWith: maximum).pointSize
            #expect(role.uiFont(in: fixed, compatibleWith: beyondMaximum).pointSize == fixedSize)
            #expect(cappedSize > fixedSize)
            #expect(role.uiFont(in: dynamic, compatibleWith: beyondMaximum).pointSize == cappedSize)
        }

        @Test("S2-02/T14 Role reference sizes survive composition and the latest size wins")
        func roleReferenceSizeSurvivesCompositionAndLatestWins() {
            let theme = Self.theme()
            let small = PKYTypographyRole.display.withReferenceSize(
                24
            ).bold.rounded.monospacedDigits
            let large = PKYTypographyRole.display.bold.rounded.monospacedDigits.withReferenceSize(
                48
            )
            func size(_ role: PKYTypographyRole) -> CGFloat {
                role.uiFont(in: theme, compatibleWith: Self.largeTraits).pointSize
            }

            #expect(size(large) > size(small))
            #expect(size(large.withReferenceSize(12)) < size(small))
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
            let traits = Self.largeTraits
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
            let custom = Self.theme(Self.customFamily)
            let customFont = PKYTypographyRole.body.uiFont(in: custom, compatibleWith: traits)
            let customMonospaced = PKYTypographyRole.body.monospaced.uiFont(
                in: custom,
                compatibleWith: traits
            )
            #expect(customMonospaced.fontName == customFont.fontName)
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

        private func renderedSize(
            _ role: PKYTypographyRole,
            theme: PKYTheme,
            dynamicTypeSize: DynamicTypeSize
        ) -> CGSize {
            let renderer = ImageRenderer(
                content: Text("MMMM")
                    .pkyFont(role)
                    .environment(\.pkyTheme, PKYThemeTraitValue(theme: theme))
                    .dynamicTypeSize(dynamicTypeSize)
                    .fixedSize()
            )
            renderer.scale = 1
            return renderer.uiImage?.size ?? .zero
        }
    }
#endif
