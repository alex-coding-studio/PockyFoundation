#if os(iOS)
    import UIKit

    public extension UIFont {
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
