#if os(iOS)
    import PockyFoundation
    import Testing
    import UIKit

    @MainActor
    struct UIViewPKYTargetTests {
        @Test("Minimum target bounds center each undersized axis independently")
        func minimumTargetBounds() {
            let view = UIView()
            let minimum = PKYLayout.Target.minimum
            for width in [minimum / 2, minimum * 2] {
                let height = minimum * minimum / width
                view.bounds = CGRect(x: 7, y: 11, width: width, height: height)
                let target = view.pkyMinimumTargetBounds
                #expect(target.midX == view.bounds.midX)
                #expect(target.midY == view.bounds.midY)
                #expect(target.width == max(minimum, width))
                #expect(target.height == max(minimum, height))
            }
        }
    }
#endif
