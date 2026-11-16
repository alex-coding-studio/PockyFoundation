import CoreGraphics

/// Content roles that select grid spacing and column policy.
public enum PKYGridPlacementRole: Sendable {
    /// Thumbnail tiles, with extra spacing when accompanied by a caption.
    case tile(captioned: Bool)
    /// Folder cards containing a prominent readout.
    case folder
    /// Ordinary content cards that expand to a single column in narrow space.
    case card

    /// Caller-provided window geometry; the library never queries devices or screens.
    public struct Device: Equatable, Sendable {
        /// A fallback when no window geometry is available.
        public static let unknown = Device(portraitWidth: 0, availableWidth: 0, isLarge: false)

        /// Reference width in portrait, or zero when unknown.
        public var portraitWidth: CGFloat
        /// Currently available window width, or zero when unknown.
        public var availableWidth: CGFloat
        /// Whether the caller requests the large-device reference column policy.
        public var isLarge: Bool

        /// Records caller-provided window geometry without consulting platform state.
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

    /// Horizontal page margin for this grid role.
    public var margin: CGFloat {
        PKYLayout.Inset.page()
    }

    /// Horizontal gap selected for the content role.
    public var columnSpacing: CGFloat {
        switch self {
        case .tile(captioned: false): PKYLayout.Gap.content()
        case .tile(captioned: true), .card: PKYLayout.Gap.group(.compact)
        case .folder: PKYLayout.Gap.group()
        }
    }

    /// Vertical gap selected for the content role.
    public var rowSpacing: CGFloat {
        switch self {
        case .tile(captioned: false): PKYLayout.Gap.content()
        case .tile(captioned: true), .folder: PKYLayout.Gap.group()
        case .card: PKYLayout.Gap.group(.compact)
        }
    }

    /// Resolves column geometry; content height, safe areas, and scrolling remain caller-owned.
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

    /// Returns the column policy for the supplied content width and device geometry.
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
