#if os(iOS)
    import PockyFoundation
    import Testing
    import UIKit

    @MainActor
    struct UIStackViewPKYArrangedTests {
        @Test("STACK-01/T01 Initialization applies subviews and arrangement settings")
        func arrangedInitAppliesConfiguration() {
            let first = UIView()
            let second = UIView()

            let stack = UIStackView(
                pkyArranged: [first, second],
                axis: .vertical,
                spacing: 8,
                alignment: .center,
                distribution: .equalSpacing
            )

            #expect(stack.arrangedSubviews == [first, second])
            #expect(stack.axis == .vertical)
            #expect(stack.alignment == .center)
            #expect(stack.distribution == .equalSpacing)
        }

        @Test("STACK-01/T02 Omitted settings retain UIKit defaults and autoresizing behavior")
        func omittedParametersKeepUIKitDefaults() {
            let stack = UIStackView(pkyArranged: [UIView()])
            let native = UIStackView(arrangedSubviews: [UIView()])

            #expect(stack.axis == native.axis)
            #expect(stack.spacing == native.spacing)
            #expect(stack.alignment == native.alignment)
            #expect(stack.distribution == native.distribution)
            #expect(
                stack.translatesAutoresizingMaskIntoConstraints == native.translatesAutoresizingMaskIntoConstraints
            )
        }
    }
#endif
