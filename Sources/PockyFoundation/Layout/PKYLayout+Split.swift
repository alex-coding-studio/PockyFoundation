import CoreGraphics

public extension PKYLayout {
    /// A content arrangement selected from available space, without device checks.
    enum Split: Equatable, Sendable {
        case stacked

        case sideBySide

        /// Prefers stacking when content fits; otherwise uses columns only in a wide region.
        public init(stackedHeight: CGFloat, available: CGSize) {
            if stackedHeight <= available.height {
                self = .stacked
            } else {
                self = WidthClass(availableWidth: available.width) == .wide ? .sideBySide : .stacked
            }
        }
    }
}
