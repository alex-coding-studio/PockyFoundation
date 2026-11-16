import SwiftUI

/// Creates eight semantic typography roles from one family and scaling policy.
///
/// iOS system fonts retain Apple text-style sizes; custom fonts use Pocky reference sizes. macOS
/// uses native preferred text-style sizes for both families and ignores scaling. Weight and other
/// modifiers are derived through ``PKYTextStyle``.
public struct PKYTypographyTheme: Sendable {
    /// The Dynamic Type policy shared by all typography roles; ignored on macOS.
    public enum Scaling: Sendable {
        /// Fixed sizes: the default large category for iOS system fonts, or reference sizes for custom fonts.
        case fixed

        /// Scales with Dynamic Type up to the system category specified by `maximum`.
        case dynamic(maximum: DynamicTypeSize)
    }

    /// A visual focus, display title, or prominent value.
    public let display: PKYTextStyle

    /// A persistent page title outside the system navigation bar that does not collapse.
    public let pageTitle: PKYTextStyle

    /// A primary content title or prominent page section.
    public let title: PKYTextStyle

    /// A section, card, or content-group heading.
    public let heading: PKYTextStyle

    /// Body text and primary list content.
    public let body: PKYTextStyle

    /// Subtitles, explanations, and supplementary content.
    public let supporting: PKYTextStyle

    /// Compact metadata such as a time, count, or source.
    public let caption: PKYTextStyle

    /// Text in buttons and other actionable controls.
    public let action: PKYTextStyle

    /// The scaling policy shared by all eight roles.
    public let scaling: Scaling

    /// Creates every semantic role from a family and scaling policy.
    ///
    /// - Parameters:
    ///   - family: The system family or custom faces registered by the app.
    ///   - scaling: The shared Dynamic Type policy on iOS; ignored on macOS.
    public init(family: PKYFontFamily, scaling: Scaling) {
        self.scaling = scaling
        display = PKYTextStyle(role: .display, family: family, scaling: scaling)
        pageTitle = PKYTextStyle(role: .pageTitle, family: family, scaling: scaling)
        title = PKYTextStyle(role: .title, family: family, scaling: scaling)
        heading = PKYTextStyle(role: .heading, family: family, scaling: scaling)
        body = PKYTextStyle(role: .body, family: family, scaling: scaling)
        supporting = PKYTextStyle(role: .supporting, family: family, scaling: scaling)
        caption = PKYTextStyle(role: .caption, family: family, scaling: scaling)
        action = PKYTextStyle(role: .action, family: family, scaling: scaling)
    }
}
