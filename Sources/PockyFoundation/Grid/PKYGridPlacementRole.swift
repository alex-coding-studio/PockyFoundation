import CoreGraphics

public enum PKYGridPlacementRole: Hashable, Sendable {
    case tile(captioned: Bool)
    case folder
    case card

    public struct Device: Equatable, Sendable {
        public static let unknown = Device(portraitWidth: 0, availableWidth: 0, isLarge: false)

        public var portraitWidth: CGFloat
        public var availableWidth: CGFloat
        public var isLarge: Bool

        public init(portraitWidth: CGFloat, availableWidth: CGFloat, isLarge: Bool) {
            self.portraitWidth = portraitWidth
            self.availableWidth = availableWidth
            self.isLarge = isLarge
        }
    }

    private enum Metrics {
        static let folderMinimumWidth: CGFloat = 137
        static let phonePortraitColumns = 3
        static let largePortraitColumns = 5
        static let phoneReferenceWidth: CGFloat = 375
        static let cardMinimumWidth: CGFloat = 300
    }

    public var margin: CGFloat {
        PKYLayout.Inset.page()
    }

    public var columnSpacing: CGFloat {
        switch self {
        case .tile(captioned: false): PKYLayout.Gap.content()
        case .tile(captioned: true), .card: PKYLayout.Gap.group(.compact)
        case .folder: PKYLayout.Gap.group()
        }
    }

    public var rowSpacing: CGFloat {
        switch self {
        case .tile(captioned: false): PKYLayout.Gap.content()
        case .tile(captioned: true), .folder: PKYLayout.Gap.group()
        case .card: PKYLayout.Gap.group(.compact)
        }
    }

    public func resolve(
        width: CGFloat,
        device: Device,
        padding: PKYEdgeInsets? = nil,
        maximum: Int = .max,
        itemWidth: PKYGridPlacementInput.ItemWidth = .fill()
    ) -> PKYGridPlacementOutput {
        let padding = padding ?? PKYEdgeInsets(
            top: 0,
            leading: margin,
            bottom: 0,
            trailing: margin
        )
        return PKYGridPlacementInput(
            width: width,
            padding: padding,
            columns: columns(
                contentWidth: width - padding.leading - padding.trailing,
                device: device,
                maximum: maximum
            ),
            spacing: columnSpacing,
            itemWidth: itemWidth
        ).resolve()
    }

    public func columns(
        contentWidth: CGFloat,
        device: Device,
        maximum: Int = .max
    ) -> PKYGridPlacementInput.Columns {
        let (minimumWidth, minimumColumns): (CGFloat, Int) = switch self {
        case .tile:
            (
                portraitTileWidth(contentWidth: contentWidth, device: device),
                Metrics.phonePortraitColumns
            )
        case .folder:
            (Metrics.folderMinimumWidth, 2)
        case .card:
            (Metrics.cardMinimumWidth, 1)
        }
        return .fitting(
            minimumWidth: minimumWidth,
            range: minimumColumns ... max(minimumColumns, maximum)
        )
    }

    private func portraitTileWidth(contentWidth: CGFloat, device: Device) -> CGFloat {
        let spacing = columnSpacing
        let phoneContent = Metrics.phoneReferenceWidth - margin * 2
        let phoneColumns = CGFloat(Metrics.phonePortraitColumns)
        let phoneTile = (phoneContent - spacing * (phoneColumns - 1)) / phoneColumns
        guard device.portraitWidth > 0, device.availableWidth > 0 else {
            return phoneTile
        }
        let count = CGFloat(
            device.isLarge ? Metrics.largePortraitColumns : Metrics.phonePortraitColumns
        )
        let portraitContent = contentWidth - max(0, device.availableWidth - device.portraitWidth)
        return max(phoneTile, (portraitContent - spacing * (count - 1)) / count)
    }
}
