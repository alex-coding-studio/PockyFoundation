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
    }
#endif
