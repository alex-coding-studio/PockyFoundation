import CoreGraphics

public extension PKYLayout {
    enum WidthClass: Equatable, Sendable {
        case narrow

        case wide

        private static let minimumWideWidth: CGFloat = 520

        public init(availableWidth: CGFloat) {
            self = availableWidth >= Self.minimumWideWidth ? .wide : .narrow
        }
    }
}
