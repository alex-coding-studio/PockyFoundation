import SwiftUI

/// The font family and Dynamic Type policy that resolve every ``PKYTypographyRole``.
///
/// iOS system fonts retain Apple text-style sizes; custom fonts use Pocky reference sizes. macOS
/// uses native preferred text-style sizes for both families and ignores scaling.
public struct PKYTypographyTheme: Sendable {
    /// The Dynamic Type policy shared by all typography roles; ignored on macOS.
    public enum Scaling: Hashable, Sendable {
        /// Fixed sizes: the default large category for iOS system fonts, or reference sizes for custom fonts.
        case fixed

        /// Scales with Dynamic Type up to the system category specified by `maximum`.
        case dynamic(maximum: DynamicTypeSize)
    }

    /// The system family or custom faces registered by the app.
    public let family: PKYFontFamily

    /// The scaling policy shared by all roles.
    public let scaling: Scaling

    /// Creates a typography theme from a family and scaling policy.
    ///
    /// - Parameters:
    ///   - family: The system family or custom faces registered by the app.
    ///   - scaling: The shared Dynamic Type policy on iOS; ignored on macOS.
    public init(family: PKYFontFamily, scaling: Scaling) {
        self.family = family
        self.scaling = scaling
    }
}
