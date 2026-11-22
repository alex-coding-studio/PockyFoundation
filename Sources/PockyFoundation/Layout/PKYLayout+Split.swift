import CoreGraphics

public extension PKYLayout {
    enum Split: Equatable, Sendable {
        case stacked

        case sideBySide

        public init(stackedHeight: CGFloat, available: CGSize) {
            if stackedHeight <= available.height {
                self = .stacked
            } else {
                self = WidthClass(availableWidth: available.width) == .wide ? .sideBySide : .stacked
            }
        }
    }
}
