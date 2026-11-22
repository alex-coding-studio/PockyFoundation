import CoreGraphics

public enum PKYIcon {
    public enum Size: CaseIterable, Sendable {
        case accessory
        case badge
        case control
        case item
        case feature

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
