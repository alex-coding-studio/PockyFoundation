#if os(macOS)
    import CoreGraphics
    import Foundation
    import PockyFoundation
    import Testing

    struct READMEValuesTests {
        static let variants: [PKYLayout.Variant] = [.compact, .standard, .wide]

        static let rows: [(String, [Double])] = [
            ("Space", spaces()),
            ("Gap content; group; section (compact / standard / wide)", gaps()),
            (
                "Inset page/container; control vertical/horizontal; row vertical/horizontal",
                insets()
            ),
            ("Size button; row; dot; auxiliary; minimum target", sizes()),
            ("Radius tile / compact / content / card / panel", radii()),
            ("Stroke standard / strong / heavy / display", strokes()),
            ("Duration quick / standard / slow / long / extended", durations()),
            ("Spring smooth / snappy / bouncy / pop (bounce)", springs()),
            ("Opacity tint / focusScrim / dimmed / glassTint", opacities()),
            ("Icon accessory / badge / control / item / feature", icons()),
            ("Grid tile reference columns (ordinary / large)", gridColumns()),
            ("Grid page margin; card minimum width", gridWidths()),
            ("Grid tile gaps without / with caption", gridGaps()),
            ("Elevation subtle light / dark (opacity, radius, visual y)", subtleElevation()),
            ("Elevation insetIndicator light / dark", recipe(.insetIndicator, .light)),
            ("Elevation floating; mediaContent; mediaHalo", detachedElevation()),
        ]

        private static func spaces() -> [Double] {
            [
                PKYLayout.Space.s4,
                PKYLayout.Space.s8,
                PKYLayout.Space.s12,
                PKYLayout.Space.s16,
                PKYLayout.Space.s24,
                PKYLayout.Space.s32,
            ].map(Double.init)
        }

        private static func gaps() -> [Double] {
            let content = variants.map(PKYLayout.Gap.content)
            let group = variants.map(PKYLayout.Gap.group)
            let section = variants.map(PKYLayout.Gap.section)
            return (content + group + section).map(Double.init)
        }

        private static func insets() -> [Double] {
            let page = variants.map(PKYLayout.Inset.page)
            let control = variants.map(PKYLayout.Inset.control.vertical)
                + variants.map(PKYLayout.Inset.control.horizontal)
            let row = variants.map(PKYLayout.Inset.row.vertical)
                + variants.map(PKYLayout.Inset.row.horizontal)
            return (page + control + row).map(Double.init)
        }

        private static func sizes() -> [Double] {
            let button = variants.map(PKYLayout.Size.button)
            let row = variants.map(PKYLayout.Size.row)
            let dot = variants.map(PKYLayout.Size.dot)
            let fixed = [PKYLayout.Size.auxiliaryButton, PKYLayout.Target.minimum]
            return (button + row + dot + fixed).map(Double.init)
        }

        private static func radii() -> [Double] {
            [
                PKYShape.Radius.tile,
                PKYShape.Radius.compact,
                PKYShape.Radius.content,
                PKYShape.Radius.card,
                PKYShape.Radius.panel,
            ].map(Double.init)
        }

        private static func strokes() -> [Double] {
            [
                PKYShape.Stroke.standard,
                PKYShape.Stroke.strong,
                PKYShape.Stroke.heavy,
                PKYShape.Stroke.display,
            ].map(Double.init)
        }

        private static func durations() -> [Double] {
            [
                PKYMotion.Duration.quick,
                PKYMotion.Duration.standard,
                PKYMotion.Duration.slow,
                PKYMotion.Duration.long,
                PKYMotion.Duration.extended,
            ]
        }

        private static func springs() -> [Double] {
            [PKYMotion.Spring.smooth, .snappy, .bouncy, .pop].map { Double($0.bounce) }
        }

        private static func opacities() -> [Double] {
            [
                PKYOpacity.tint,
                PKYOpacity.focusScrim,
                PKYOpacity.dimmed,
                PKYOpacity.glassTint,
            ].map(Double.init)
        }

        private static func icons() -> [Double] {
            PKYIcon.Size.allCases.map { Double($0.pointSize) }
        }

        private static func gridColumns() -> [Double] {
            [false, true].map { isLarge in
                let width: CGFloat = isLarge ? 820 : 375
                let device = PKYGridPlacementRole.Device(
                    portraitWidth: width,
                    availableWidth: width,
                    isLarge: isLarge
                )
                let output = PKYGridPlacementRole.tile(captioned: false).resolve(
                    width: width,
                    device: device
                )
                return Double(output.columns)
            }
        }

        private static func gridWidths() -> [Double] {
            let columns = PKYGridPlacementRole.card.columns(contentWidth: 1000, device: .unknown)
            guard case let .fitting(minimumWidth, _) = columns else {
                return []
            }
            return [Double(PKYGridPlacementRole.card.margin), Double(minimumWidth)]
        }

        private static func gridGaps() -> [Double] {
            let plain = PKYGridPlacementRole.tile(captioned: false)
            let captioned = PKYGridPlacementRole.tile(captioned: true)
            return [
                plain.columnSpacing,
                captioned.columnSpacing,
                plain.rowSpacing,
                captioned.rowSpacing,
            ].map(Double.init)
        }

        private static func subtleElevation() -> [Double] {
            recipe(.subtle, .light) + recipe(.subtle, .dark)
        }

        private static func detachedElevation() -> [Double] {
            [PKYElevation.Style.floating, .mediaContent, .mediaHalo].flatMap { recipe($0, .light) }
        }

        private static func recipe(
            _ style: PKYElevation.Style,
            _ appearance: PKYElevation.Appearance
        ) -> [Double] {
            let recipe = style.recipe(for: appearance)
            return [recipe.opacity, Double(recipe.radius), Double(recipe.offset.height)]
        }

        private static func platformValues() throws -> [String: String] {
            let root = URL(filePath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
            let url = root.appending(path: "README.md")
            let section = try String(contentsOf: url, encoding: .utf8)
                .components(separatedBy: "### Platform values").last ?? ""
            let table = section.components(separatedBy: "\n### ").first ?? ""
            var values = [String: String]()
            for line in table.split(separator: "\n") where line.hasPrefix("| ") {
                let cells = line.dropFirst(2).dropLast(2).components(separatedBy: " | ")
                if cells.count == 2 {
                    values[cells[0]] = cells[1]
                }
            }
            return values
        }

        private static func numbers(in text: String) -> [Double] {
            text.matches(of: #/\d*\.?\d+/#).compactMap { match in
                let number = String(match.output)
                return Double(number.hasPrefix(".") ? "0" + number : number)
            }
        }

        @Test("README platform values match the shared role values", arguments: rows)
        func platformValuesMatchCode(label: String, expected: [Double]) throws {
            let row = try #require(try Self.platformValues()[label], "Missing README row")
            #expect(Self.numbers(in: row) == expected)
        }

        @Test("README shorthand for shared insets and the dark inset indicator matches the code")
        func platformValueShorthandMatchesCode() throws {
            for variant in Self.variants {
                #expect(PKYLayout.Inset.page(variant) == PKYLayout.Inset.container(variant))
            }
            let indicator = try #require(
                try Self.platformValues()["Elevation insetIndicator light / dark"]
            )
            let dark = PKYElevation.Style.insetIndicator.recipe(for: .dark)
            #expect(indicator.hasSuffix("/ none"))
            #expect(dark.opacity == 0 && dark.radius == 0 && dark.offset == .zero)
        }
    }
#endif
