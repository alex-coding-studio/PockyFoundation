import CoreGraphics
import Foundation
import PockyFoundation

enum PlatformValues {
    static let variants: [PKYLayout.Variant] = [.compact, .standard, .wide]
    static let darkInsetIsInvisible = PKYElevation.Style.insetIndicator.recipe(for: .dark).opacity == 0

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
        ("Elevation insetIndicator light / dark", recipe(.insetIndicator, .light)
            + (darkInsetIsInvisible ? [] : recipe(.insetIndicator, .dark))),
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
            fail("The grid card width policy no longer provides a fitting minimum width for the README.")
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
}

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("\(message)\n".utf8))
    exit(1)
}

let path = CommandLine.arguments.dropFirst().first ?? "README.md"
let lines: [Substring]
do {
    lines = try String(contentsOfFile: path, encoding: .utf8)
        .split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
} catch {
    fail("Cannot read \(path): \(error.localizedDescription)")
}
guard let heading = lines.firstIndex(of: "### Platform values") else {
    fail("\(path): missing 'Platform values' heading")
}
let section = lines.dropFirst(heading + 1).prefix { !$0.hasPrefix("#") }
guard let header = section.firstIndex(of: "| Role | Value |"),
      section[header...].dropFirst().first == "| --- | --- |" else {
    fail("\(path): missing Role / Value table in 'Platform values'")
}

var remaining = Dictionary(uniqueKeysWithValues: PlatformValues.rows)
for line in lines.dropFirst(header + 2).prefix(while: { $0.hasPrefix("|") }) {
    let cells = line.split(separator: "|", omittingEmptySubsequences: false)
    guard cells.count == 4, cells.first == "", cells.last == "" else {
        fail("\(path): malformed platform-value row: \(line)")
    }
    let role = cells[1].trimmingCharacters(in: .whitespaces)
    let value = cells[2].trimmingCharacters(in: .whitespaces)
    guard let apiValues = remaining.removeValue(forKey: role) else {
        fail("\(path): unexpected or duplicate platform-value row: \(role)")
    }
    let documented = value.matches(of: #/[+-]?(?:\d+(?:\.\d+)?|\.\d+)(?:[eE][+-]?\d+)?/#)
        .compactMap { Double($0.output) }
    guard documented == apiValues else {
        fail("\(path): \(role): documented \(value); current API values \(apiValues)")
    }
    if role == "Elevation insetIndicator light / dark", value.hasSuffix("/ none") != PlatformValues.darkInsetIsInvisible {
        fail("\(path): \(role): check the documented dark-mode 'none' shorthand")
    }
}
guard remaining.isEmpty else {
    fail("\(path): missing platform-value rows: \(remaining.keys.sorted().joined(separator: ", "))")
}
for variant in PlatformValues.variants where PKYLayout.Inset.page(variant) != PKYLayout.Inset.container(variant) {
    fail("\(path): the shared page/container inset row does not describe \(variant)")
}
print("README platform values match the public API.")
