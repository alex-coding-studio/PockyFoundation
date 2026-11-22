import CoreGraphics

public struct PKYGridPlacementOutput: Equatable, Sendable {
    private static let exactFitRoundingTolerance: CGFloat = 1e-6

    public let padding: PKYEdgeInsets
    public let contentWidth: CGFloat
    public let columns: Int
    public let spacing: CGFloat
    public let itemWidth: CGFloat

    init(_ input: PKYGridPlacementInput) {
        padding = input.padding
        let available = input.width - input.padding.leading - input.padding.trailing
        contentWidth = available.isFinite ? max(0, available) : 0
        let gap = input.spacing.isFinite ? input.spacing : 0
        let target: CGFloat
        let range: ClosedRange<Int>
        switch input.columns {
        case let .fixed(count):
            target = 0
            range = max(1, count) ... max(1, count)
        case let .fitting(minimumWidth, bounds):
            target = minimumWidth
            range = bounds
        }
        let lower = max(1, range.lowerBound)
        let upper = max(lower, range.upperBound)
        if target.isFinite, target > 0, target + gap > 0 {
            let fitting = ((contentWidth + gap) / (
                target + gap
            ) + Self.exactFitRoundingTolerance).rounded(.down)
            if fitting >= CGFloat(upper) {
                columns = upper
            } else if fitting > CGFloat(lower) {
                columns = Int(fitting)
            } else {
                columns = lower
            }
        } else {
            columns = lower
        }
        let width: CGFloat
        switch input.itemWidth {
        case let .fill(rounding):
            let fitting = (contentWidth - gap * CGFloat(columns - 1)) / CGFloat(columns)
            width = fitting.isFinite ? max(0, rounding.map { fitting.rounded($0) } ?? fitting) : 0
            spacing = gap
        case let .fixed(fixed):
            width = fixed.isFinite ? max(0, fixed) : 0
            spacing = columns > 1
                ? max(0, (contentWidth - width * CGFloat(columns)) / CGFloat(columns - 1))
                : gap
        }
        itemWidth = width
    }

    public func width(spanning count: Int) -> CGFloat {
        let count = max(1, count)
        return itemWidth * CGFloat(count) + spacing * CGFloat(count - 1)
    }
}
