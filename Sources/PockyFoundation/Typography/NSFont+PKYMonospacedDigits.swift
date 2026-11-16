#if os(macOS)
    import AppKit

    public extension NSFont {
        /// Preserves family, size, and traits while making digits monospaced for changing counts or readings.
        var pkyMonospacedDigits: NSFont {
            let descriptor = fontDescriptor.addingAttributes([
                .featureSettings: [[
                    NSFontDescriptor.FeatureKey.typeIdentifier: kNumberSpacingType,
                    NSFontDescriptor.FeatureKey.selectorIdentifier: kMonospacedNumbersSelector,
                ]],
            ])
            return NSFont(descriptor: descriptor, size: 0) ?? self
        }
    }
#endif
