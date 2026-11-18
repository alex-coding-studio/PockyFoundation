#if os(iOS)
    import PockyFoundation
    import Testing
    import UIKit

    @MainActor
    struct UILabelMultilineTests {
        @Test("Multiline labels default to centered text and unlimited lines")
        func defaultsToCenteredUnlimitedLines() {
            let label = UILabel.pkyMultiline()
            #expect(label.numberOfLines == 0)
            #expect(label.textAlignment == .center)
        }

        @Test("Multiline labels preserve explicit text alignment")
        func usesExplicitAlignment() {
            let label = UILabel.pkyMultiline(alignment: .natural)
            #expect(label.numberOfLines == 0)
            #expect(label.textAlignment == .natural)
        }
    }
#endif
