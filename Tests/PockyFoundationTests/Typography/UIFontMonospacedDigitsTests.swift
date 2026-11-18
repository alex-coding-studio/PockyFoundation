#if os(iOS)
    import PockyFoundation
    import Testing
    import UIKit

    @MainActor
    struct UIFontMonospacedDigitsTests {
        @Test("Monospaced digits preserve font family, size, and traits", arguments: [
            UIFont.systemFont(ofSize: 23, weight: .semibold),
            UIFont.italicSystemFont(ofSize: 19),
            UIFont(name: "HelveticaNeue-Bold", size: 27) ?? .boldSystemFont(ofSize: 27),
        ])
        func preservesFont(_ original: UIFont) {
            let font = original.pkyMonospacedDigits
            #expect(font.familyName == original.familyName)
            #expect(font.pointSize == original.pointSize)
            #expect(font.fontDescriptor.symbolicTraits == original.fontDescriptor.symbolicTraits)
            #expect(font.fontDescriptor.object(forKey: .traits) as? NSDictionary
                == original.fontDescriptor.object(forKey: .traits) as? NSDictionary)
        }

        @Test("System font digits have equal widths and repeated application is unchanged")
        func digitsHaveEqualWidths() {
            let font = UIFont.systemFont(ofSize: 23, weight: .semibold).pkyMonospacedDigits
            let widths = "0123456789".map {
                (String($0) as NSString).size(withAttributes: [.font: font]).width
            }
            #expect((widths.max() ?? 0) - (widths.min() ?? 0) < 0.01)
            #expect(font.pkyMonospacedDigits == font)
        }
    }
#endif
