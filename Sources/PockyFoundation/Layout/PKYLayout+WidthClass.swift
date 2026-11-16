import CoreGraphics

public extension PKYLayout {
    /// A width classification derived from available content space.
    enum WidthClass: Equatable, Sendable {
        case narrow

        case wide

        private static let minimumWideWidth: CGFloat = 520

        /// Classifies the supplied content width independently of device identity.
        public init(availableWidth: CGFloat) {
            self = availableWidth >= Self.minimumWideWidth ? .wide : .narrow
        }
    }
}
