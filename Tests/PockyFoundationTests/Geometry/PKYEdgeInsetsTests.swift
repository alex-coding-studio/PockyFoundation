import PockyFoundation
import Testing

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

struct PKYEdgeInsetsTests {
    #if os(iOS)
        @Test(
            "Symmetric physical insets preserve horizontal/vertical axes and allow negative values"
        )
        func symmetricInsetsPreserveAxes() {
            let horizontal: CGFloat = 7
            let vertical: CGFloat = -3
            let insets = UIEdgeInsets.pky(horizontal: horizontal, vertical: vertical)
            #expect(insets.left == horizontal)
            #expect(insets.right == insets.left)
            #expect(insets.top == vertical)
            #expect(insets.bottom == insets.top)

            let horizontalOnly = UIEdgeInsets.pky(horizontal: horizontal)
            #expect(horizontalOnly.left == horizontal)
            #expect(horizontalOnly.right == horizontal)
            #expect(horizontalOnly.top == 0)
            #expect(horizontalOnly.bottom == 0)

            let verticalOnly = UIEdgeInsets.pky(vertical: vertical)
            #expect(verticalOnly.top == vertical)
            #expect(verticalOnly.bottom == vertical)
            #expect(verticalOnly.left == 0)
            #expect(verticalOnly.right == 0)

            #expect(UIEdgeInsets.pky() == .zero)
        }
    #endif

    @Test("Symmetric directional insets match PKYEdgeInsets and preserve axes")
    func symmetricDirectionalInsetsPreserveAxes() {
        let horizontal: CGFloat = 16
        let vertical: CGFloat = 8
        let insets = NSDirectionalEdgeInsets.pky(horizontal: horizontal, vertical: vertical)
        let foundation = PKYEdgeInsets(
            top: vertical,
            leading: horizontal,
            bottom: vertical,
            trailing: horizontal
        )
        #expect(insets.leading == foundation.leading)
        #expect(insets.trailing == foundation.trailing)
        #expect(insets.top == foundation.top)
        #expect(insets.bottom == foundation.bottom)
        let empty = NSDirectionalEdgeInsets.pky()
        #expect(empty.top == 0)
        #expect(empty.leading == 0)
        #expect(empty.bottom == 0)
        #expect(empty.trailing == 0)
    }
}
