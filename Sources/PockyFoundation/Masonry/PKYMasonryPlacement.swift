import CoreGraphics

/// Places equal-width items in the shortest column; equal heights choose the leading column.
public enum PKYMasonryPlacement {
    /// Computes frames in a top-down coordinate space using width divided by height ratios.
    ///
    /// Nonpositive and nonfinite ratios use a square. Finite positive ratios are clamped
    /// to `minimumAspectRatio`. Rounding affects height only; nil preserves fractional heights.
    /// A height cap is applied after rounding so that rounded output never exceeds the cap.
    /// Nonfinite width or spacing produces an empty placement. Negative spacing allows overlap.
    /// - Parameters:
    ///   - aspectRatios: Item width divided by item height, in display order.
    ///   - width: Container width; negative values are treated as zero.
    ///   - columns: Requested column count, clamped to at least one.
    ///   - spacing: Gap between columns and items, including negative overlap.
    ///   - rounding: Height rounding rule, or nil to retain fractional heights.
    ///   - maximumHeightRatio: Optional positive finite height-to-width cap, such as 2.5.
    ///   - minimumAspectRatio: Positive finite lower ratio limit; invalid limits use 0.01.
    /// - Returns: Ordered frames and the content height, which is the lowest frame edge and never negative.
    public static func frames(
        aspectRatios: [CGFloat],
        width: CGFloat,
        columns: Int,
        spacing: CGFloat,
        rounding: FloatingPointRoundingRule? = .toNearestOrAwayFromZero,
        maximumHeightRatio: CGFloat? = nil,
        minimumAspectRatio: CGFloat = 0.01
    ) -> (frames: [CGRect], height: CGFloat) {
        guard width.isFinite, spacing.isFinite, !aspectRatios.isEmpty else {
            return ([], 0)
        }
        let count = max(columns, 1)
        let geometry = PKYGridPlacementInput(
            width: width,
            columns: .fixed(count),
            spacing: spacing
        ).resolve()
        let columnWidth = geometry.itemWidth
        guard columnWidth.isFinite else {
            return ([], 0)
        }
        let minimum = minimumAspectRatio.isFinite && minimumAspectRatio > 0 ? minimumAspectRatio : 0.01
        let cap = maximumHeightRatio.flatMap { $0.isFinite && $0 > 0 ? $0 : nil }
        var heights = Array(repeating: CGFloat(0), count: min(count, aspectRatios.count))
        var frames = [CGRect]()
        for ratio in aspectRatios {
            let selected = heights.indices.min { heights[$0] < heights[$1] } ?? 0
            let validRatio = ratio.isFinite && ratio > 0 ? max(ratio, minimum) : 1
            let raw = columnWidth / validRatio
            var height = rounding.map { raw.rounded($0) } ?? raw
            if let cap {
                height = min(height, columnWidth * cap)
            }
            guard height.isFinite else {
                return ([], 0)
            }
            let frame = CGRect(
                x: CGFloat(selected) * (columnWidth + spacing),
                y: heights[selected],
                width: columnWidth,
                height: height
            )
            heights[selected] = frame.maxY + spacing
            frames.append(frame)
        }
        let height = frames.reduce(CGFloat(0)) { max($0, $1.maxY) }
        return (frames, height)
    }

    /// Fits columns to a minimum width within an inclusive range; nonpositive minima use its lower bound.
    public static func columns(
        width: CGFloat,
        minimumColumnWidth: CGFloat,
        spacing: CGFloat,
        range: ClosedRange<Int>
    ) -> Int {
        PKYGridPlacementInput(
            width: width,
            columns: .fitting(minimumWidth: minimumColumnWidth, range: range),
            spacing: spacing
        ).resolve().columns
    }
}
