#if os(iOS)
    import UIKit

    public extension UIFont {
        /// Preserves the font family, size, and traits while making digits monospaced for changing counts or readings.
        var pkyMonospacedDigits: UIFont {
            let descriptor = fontDescriptor.addingAttributes([
                .featureSettings: [[
                    UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
                    UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector,
                ]],
            ])
            return UIFont(descriptor: descriptor, size: 0)
        }
    }
#endif
