#if os(iOS)
    import PockyFoundation
    import Testing
    import UIKit

    struct PKYEdgeInsetsTests {
        @Test(
            "Symmetric physical insets preserve horizontal/vertical axes and allow negative values"
        )
        func symmetricInsetsPreserveAxes() {
            #expect(UIEdgeInsets.pky(horizontal: 7, vertical: -3) == UIEdgeInsets(
                top: -3,
                left: 7,
                bottom: -3,
                right: 7
            ))
            #expect(UIEdgeInsets.pky(horizontal: 7) == UIEdgeInsets(
                top: 0,
                left: 7,
                bottom: 0,
                right: 7
            ))
            #expect(UIEdgeInsets.pky(vertical: 3) == UIEdgeInsets(
                top: 3,
                left: 0,
                bottom: 3,
                right: 0
            ))
            #expect(UIEdgeInsets.pky() == .zero)
        }

        @Test("Symmetric directional insets preserve leading/trailing and vertical axes")
        func symmetricDirectionalInsetsPreserveAxes() {
            let horizontal: CGFloat = 16
            let vertical: CGFloat = 8
            let insets = NSDirectionalEdgeInsets.pky(horizontal: horizontal, vertical: vertical)
            #expect(insets.leading == horizontal)
            #expect(insets.trailing == insets.leading)
            #expect(insets.top == vertical)
            #expect(insets.bottom == insets.top)
        }
    }
#endif
