import CoreGraphics

/// Semantic point sizes for standalone symbols, independent of fonts and hit targets.
public enum PKYIcon {
    /// The visual role of a symbol; inline symbols should inherit their text font.
    public enum Size: CaseIterable, Sendable {
        /// A secondary symbol beside text or within a compact control.
        case accessory
        /// A symbol within a badge or compact readout.
        case badge
        /// A primary button, toolbar, navigation, or filter symbol.
        case control
        /// A leading content symbol or selection marker.
        case item
        /// A focal symbol in an empty state or completion presentation.
        case feature

        /// The fixed point size; callers own fonts, weights, and platform image configuration.
        public var pointSize: CGFloat {
            switch self {
            case .accessory: 12
            case .badge: 16
            case .control: 18
            case .item: 20
            case .feature: 24
            }
        }
    }
}
