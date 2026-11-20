import SwiftUI

#if os(iOS)
    import UIKit
#endif

public extension PKYIcon.Size {
    /// Creates a SwiftUI font at this role's point size for `Image(systemName:)`.
    ///
    /// - Parameter weight: Symbol weight, defaulting to `.regular`.
    /// - Returns: A system font using this role's point size and the given weight.
    func font(weight: Font.Weight = .regular) -> Font {
        .system(size: pointSize, weight: weight)
    }
}

#if os(iOS)
    public extension PKYIcon.Size {
        /// Creates a UIKit symbol configuration at this role's point size.
        ///
        /// - Parameter weight: Symbol weight, defaulting to `.regular`.
        /// - Returns: A symbol configuration with this role's point size and the given weight.
        func symbolConfiguration(
            weight: UIImage.SymbolWeight = .regular
        ) -> UIImage.SymbolConfiguration {
            UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        }

        /// Loads a system symbol image at this role's point size.
        ///
        /// - Parameters:
        ///   - systemName: The SF Symbol system name.
        ///   - weight: Symbol weight, defaulting to `.regular`.
        /// - Returns: The configured image, or `nil` if the symbol name does not exist.
        func image(
            systemName: String,
            weight: UIImage.SymbolWeight = .regular
        ) -> UIImage? {
            UIImage(systemName: systemName, withConfiguration: symbolConfiguration(weight: weight))
        }
    }
#endif
