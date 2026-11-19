import CoreGraphics

public extension PKYLayout {
    /// A width classification derived from available content space.
    enum WidthClass: Equatable, Sendable {
        /// Available width below the wide threshold, suited to a single column.
        case narrow

        /// Available width at or above the wide threshold, suited to side-by-side content.
        case wide

        private static let minimumWideWidth: CGFloat = 520

        /// Classifies the supplied content width independently of device identity.
        public init(availableWidth: CGFloat) {
            self = availableWidth >= Self.minimumWideWidth ? .wide : .narrow
        }
    }
}
