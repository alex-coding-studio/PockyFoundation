#if os(iOS)
    @_spi(Pocky) import PockyFoundation
    import Testing
    import UIKit

    @MainActor
    struct UIKitTypographyBindingTests {
        @Test(
            "S4-02/T01 SPI registrations reuse one binding per control and clear when the role is removed"
        )
        func registrationsAreReusedAndReleased() throws {
            let label = UILabel()
            label.pkyTypography = .body
            let typography = try #require(pkyTypographyRegistration(on: label))
            label.pkyTypography = .caption
            #expect(
                (pkyTypographyRegistration(on: label) as AnyObject?) === (typography as AnyObject)
            )
            #expect(label.pkyTypography == .caption)
            label.pkyTypography = nil
            #expect(pkyTypographyRegistration(on: label) == nil)

            let button = UIButton(configuration: .plain())
            button.pkyTitleTypography = .action
            let title = try #require(pkyTitleTypographyRegistration(on: button))
            button.pkyTitleTypography = .action.semibold
            #expect(
                (pkyTitleTypographyRegistration(on: button) as AnyObject?) === (title as AnyObject)
            )
            button.pkyTitleTypography = nil
            #expect(pkyTitleTypographyRegistration(on: button) == nil)

            let text = UITextView()
            text.pkyAttributedText { _ in NSAttributedString(string: "text") }
            #expect(pkyAttributedTextRegistration(on: text) != nil)
            text.pkyAttributedText(nil)
            #expect(pkyAttributedTextRegistration(on: text) == nil)
        }
    }
#endif
