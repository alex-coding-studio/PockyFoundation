#if os(iOS)
    import UIKit

    @MainActor
    public extension NSCollectionLayoutSection {
        static func pkyFullWidth(height: NSCollectionLayoutDimension) -> NSCollectionLayoutSection {
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: height
            )
            return NSCollectionLayoutSection(group: .vertical(
                layoutSize: size,
                subitems: [NSCollectionLayoutItem(layoutSize: size)]
            ))
        }

        static func pkyInsetGroupedList(
            _ environment: any NSCollectionLayoutEnvironment
        ) -> NSCollectionLayoutSection {
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            configuration.backgroundColor = .clear
            configuration.separatorConfiguration.color = .pkySeparator(.standard)
            return .list(using: configuration, layoutEnvironment: environment)
        }
    }
#endif
