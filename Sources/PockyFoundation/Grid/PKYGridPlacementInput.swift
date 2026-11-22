import CoreGraphics

public struct PKYGridPlacementInput: Hashable, Sendable {
    public enum Columns: Hashable, Sendable {
        case fixed(Int)
        case fitting(minimumWidth: CGFloat, range: ClosedRange<Int>)
    }

    public enum ItemWidth: Hashable, Sendable {
        case fill(rounding: FloatingPointRoundingRule? = nil)
        case fixed(CGFloat)
    }

    public let width: CGFloat
    public let padding: PKYEdgeInsets
    public let columns: Columns
    public let spacing: CGFloat
    public let itemWidth: ItemWidth

    public init(
        width: CGFloat,
        padding: PKYEdgeInsets = .zero,
        columns: Columns,
        spacing: CGFloat,
        itemWidth: ItemWidth = .fill()
    ) {
        self.width = width
        self.padding = padding
        self.columns = columns
        self.spacing = spacing
        self.itemWidth = itemWidth
    }

    public func resolve() -> PKYGridPlacementOutput {
        PKYGridPlacementOutput(self)
    }
}
