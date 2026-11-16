import CoreGraphics

/// Content-independent grid inputs; width is measured before directional padding.
public struct PKYGridPlacementInput {
    /// A fixed count or the largest count that fits a minimum item width.
    public enum Columns {
        /// Uses at least one column.
        case fixed(Int)
        /// Fits the minimum width within the supplied inclusive column-count range.
        case fitting(minimumWidth: CGFloat, range: ClosedRange<Int>)
    }

    /// Fill available width, optionally rounded, or distribute gaps around fixed-width items.
    public enum ItemWidth {
        /// Fills available width; nil rounding preserves fractional point sizes.
        case fill(rounding: FloatingPointRoundingRule? = nil)
        /// Preserves the supplied item width and distributes remaining horizontal space.
        case fixed(CGFloat)
    }

    /// Container width before padding.
    public let width: CGFloat
    /// Directional padding; native layout adapters resolve its direction.
    public let padding: PKYEdgeInsets
    /// The rule used to choose the number of columns.
    public let columns: Columns
    /// Inter-column spacing; negative values intentionally allow overlap.
    public let spacing: CGFloat
    /// The item-width allocation policy.
    public let itemWidth: ItemWidth

    /// Creates grid inputs; the caller supplies content measurement and safe-area policy.
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

    /// Resolves a grid without creating views or reading platform state.
    public func resolve() -> PKYGridPlacementOutput {
        PKYGridPlacementOutput(self)
    }
}
