import SwiftUI

#if os(iOS)
    import UIKit
#endif

public extension PKYIcon.Size {
    func font(weight: Font.Weight = .regular) -> Font {
        .system(size: pointSize, weight: weight)
    }
}

#if os(iOS)
    public extension PKYIcon.Size {
        func symbolConfiguration(
            weight: UIImage.SymbolWeight = .regular
        ) -> UIImage.SymbolConfiguration {
            UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        }

        func image(
            systemName: String,
            weight: UIImage.SymbolWeight = .regular
        ) -> UIImage? {
            UIImage(systemName: systemName, withConfiguration: symbolConfiguration(weight: weight))
        }
    }
#endif
