#if os(iOS)
    @_spi(Pocky) import PockyFoundation
    import Testing
    import UIKit

    @MainActor
    struct UIKitTypographyBindingTests {
        @Test("The latest label binding owns subsequent typography updates")
        func labelReplacesCompetingBinding() {
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            window.traitOverrides.pkyTheme = PKYThemeTraitValue(theme: PKYThemeFallback.system)
            window.isHidden = false
            defer { window.isHidden = true }
            let label = UILabel()
            window.addSubview(label)
            window.updateTraitsIfNeeded()
            label.pkyTypography = .body
            var builds = 0
            label.pkyAttributedText { _ in
                builds += 1
                return NSAttributedString(string: "Title")
            }
            #expect(label.text == "Title")
            #expect(label.pkyTypography == nil)
            label.pkyTypography = .caption
            let count = builds
            window.traitOverrides.legibilityWeight = .bold
            window.updateTraitsIfNeeded()
            #expect(builds == count)
            #expect(pkyAttributedTextRegistration(on: label) == nil)
        }

        @Test("Mounted typography updates when Bold Text is enabled and disabled")
        func labelReappliesFontOnLegibilityChange() throws {
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            window.traitOverrides.pkyTheme = PKYThemeTraitValue(theme: PKYThemeFallback.system)
            window.traitOverrides.legibilityWeight = .regular
            window.isHidden = false
            defer { window.isHidden = true }

            let label = UILabel()
            window.addSubview(label)
            window.updateTraitsIfNeeded()
            label.pkyTypography = .body
            let regularFont = try #require(label.font)

            window.traitOverrides.legibilityWeight = .bold
            window.updateTraitsIfNeeded()
            #expect(label.font != regularFont)

            window.traitOverrides.legibilityWeight = .regular
            window.updateTraitsIfNeeded()
            #expect(label.font == regularFont)
        }

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
