#if os(iOS)
    import UIKit

    @MainActor
    public extension NSCollectionLayoutSection {
        /// A vertical section with one full-width item per group, suitable for self-sizing cards or rows.
        ///
        /// - Parameter height: The item height; estimated heights let content determine the final size.
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

        /// An inset-grouped list section with a clear background and the standard separator color, so the
        /// page supplies its own background.
        ///
        /// Use `UICollectionLayoutListConfiguration` directly for headers, hidden separators, or other
        /// configuration.
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
