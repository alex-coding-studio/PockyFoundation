import CoreGraphics
import PockyFoundation
import Testing

struct PKYLayoutWidthRulesTests {
    @Test(
        "Width class turns wide at the minimum wide width",
        arguments: [
            (CGFloat(0), PKYLayout.WidthClass.narrow),
            (CGFloat(320), PKYLayout.WidthClass.narrow),
            (CGFloat(375), PKYLayout.WidthClass.narrow),
            (CGFloat(519.9), PKYLayout.WidthClass.narrow),
            (CGFloat(520), PKYLayout.WidthClass.wide),
            (CGFloat(568), PKYLayout.WidthClass.wide),
            (CGFloat(667), PKYLayout.WidthClass.wide),
        ]
    )
    func widthClassFollowsAvailableWidth(
        availableWidth: CGFloat,
        expected: PKYLayout.WidthClass
    ) {
        #expect(PKYLayout.WidthClass(availableWidth: availableWidth) == expected)
    }

    @Test(
        "Split stacks content that fits and uses columns only in wide regions",
        arguments: [
            (CGFloat(600), CGSize(width: 390, height: 700), PKYLayout.Split.stacked),
            (CGFloat(600), CGSize(width: 1180, height: 700), PKYLayout.Split.stacked),
            (CGFloat(600), CGSize(width: 750, height: 330), PKYLayout.Split.sideBySide),
            (CGFloat(600), CGSize(width: 520, height: 330), PKYLayout.Split.sideBySide),
            (CGFloat(600), CGSize(width: 519, height: 330), PKYLayout.Split.stacked),
            (CGFloat(330), CGSize(width: 750, height: 330), PKYLayout.Split.stacked),
        ]
    )
    func splitFollowsStackedFit(
        stackedHeight: CGFloat,
        available: CGSize,
        expected: PKYLayout.Split
    ) {
        #expect(PKYLayout.Split(stackedHeight: stackedHeight, available: available) == expected)
    }
}
