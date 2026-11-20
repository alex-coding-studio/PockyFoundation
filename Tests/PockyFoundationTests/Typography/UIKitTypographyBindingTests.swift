#if os(iOS)
    import Testing
    import UIKit
    @testable import PockyFoundation

    @MainActor
    struct UIKitTypographyBindingTests {
        enum TextControl: CaseIterable, Sendable {
            case label
            case field
            case textView
        }

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

        @Test("The latest text view binding owns subsequent typography updates")
        func textViewReplacesCompetingBinding() {
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            window.traitOverrides.pkyTheme = PKYThemeTraitValue(theme: PKYThemeFallback.system)
            window.isHidden = false
            defer { window.isHidden = true }
            let text = UITextView()
            window.addSubview(text)
            window.updateTraitsIfNeeded()
            text.pkyTypography = .body
            var builds = 0
            text.pkyAttributedText { _ in
                builds += 1
                return NSAttributedString(string: "Title")
            }
            #expect(text.text == "Title")
            #expect(text.pkyTypography == nil)
            #expect(pkyTypographyRegistration(on: text) == nil)
            text.pkyTypography = .caption
            let count = builds
            window.traitOverrides.legibilityWeight = .bold
            window.updateTraitsIfNeeded()
            #expect(builds == count)
            #expect(pkyAttributedTextRegistration(on: text) == nil)
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

        @Test("Registrations reuse one binding per control and clear when the role is removed")
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

        @Test(
            "Label, field, and text view roles follow theme swaps and keep text and selection",
            arguments: TextControl.allCases
        )
        func textControlRoleFollowsThemeSwaps(kind: TextControl) throws {
            let themes = UIViewPKYThemeChangeTests.makeThemes()
            let control = makeTextControl(kind)
            control.pkyTypography = .body.bold
            let binding = try #require(pkyTypographyRegistration(on: control))
            control.pkyTypography = .body.bold
            #expect(
                (pkyTypographyRegistration(on: control) as AnyObject?) === (binding as AnyObject)
            )
            let window = UIViewPKYThemeChangeTests.makeWindow(theme: themes.first)
            defer { window.isHidden = true }
            window.addSubview(control)
            window.updateTraitsIfNeeded()
            let first = try #require(displayedFont(of: control))
            #expect(first == resolvedFont(.body.bold, in: themes.first, for: control))
            selectMiddle(of: control)
            let selection = selectedRange(in: control)
            window.traitOverrides.pkyTheme = themes.second
            window.updateTraitsIfNeeded()
            let second = try #require(displayedFont(of: control))
            #expect(second == resolvedFont(.body.bold, in: themes.second, for: control))
            #expect(second != first)
            #expect(displayedText(of: control) == "Retained input")
            #expect(selectedRange(in: control) == selection)
            control.pkyTypography = nil
            #expect(pkyTypographyRegistration(on: control) == nil)
            window.traitOverrides.pkyTheme = themes.first
            window.updateTraitsIfNeeded()
            #expect(displayedFont(of: control) == second)
        }

        @Test("Replacing the role of a mounted label resolves the new role immediately")
        func mountedLabelResolvesReplacementRoleImmediately() {
            let themes = UIViewPKYThemeChangeTests.makeThemes()
            let label = UILabel()
            label.pkyTypography = .caption
            let window = UIViewPKYThemeChangeTests.makeWindow(theme: themes.first)
            defer { window.isHidden = true }
            window.addSubview(label)
            window.updateTraitsIfNeeded()
            #expect(label.font == resolvedFont(.caption, in: themes.first, for: label))
            label.pkyTypography = .display.bold
            #expect(label.font == resolvedFont(.display.bold, in: themes.first, for: label))
            window.traitOverrides.pkyTheme = themes.second
            window.updateTraitsIfNeeded()
            #expect(label.font == resolvedFont(.display.bold, in: themes.second, for: label))
            #expect(label.pkyTypography == .display.bold)
        }

        @Test("Roles set in a controller's theme trait callback wait for the child label's theme")
        func roleSetDuringControllerMountWaitsForChildTheme() async throws {
            let themes = UIViewPKYThemeChangeTests.makeThemes()
            let controller = RoleResetController()
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
            window.traitOverrides.pkyTheme = themes.first
            window.rootViewController = controller
            window.isHidden = false
            defer {
                window.isHidden = true
                window.rootViewController = nil
            }
            for theme in [themes.first, themes.second] {
                window.traitOverrides.pkyTheme = theme
                let deadline = ContinuousClock.now + .seconds(3)
                while !showsRole(controller.label, in: theme), ContinuousClock.now < deadline {
                    window.updateTraitsIfNeeded()
                    window.layoutIfNeeded()
                    try await Task.sleep(for: .milliseconds(10))
                }
                #expect(showsRole(controller.label, in: theme))
            }
            #expect(controller.resets > 0)
        }

        @Test("Labels under different theme overrides resolve the same role from their own themes")
        func subtreeThemesResolveIndependently() {
            let themes = UIViewPKYThemeChangeTests.makeThemes()
            let root = UIView()
            let left = UILabel()
            let right = UILabel()
            left.traitOverrides.pkyTheme = themes.first
            right.traitOverrides.pkyTheme = themes.second
            left.pkyTypography = .body
            right.pkyTypography = .body
            root.addSubview(left)
            root.addSubview(right)
            let window = UIViewPKYThemeChangeTests.makeWindow(theme: themes.first)
            defer { window.isHidden = true }
            window.addSubview(root)
            window.updateTraitsIfNeeded()
            #expect(left.font == resolvedFont(.body, in: themes.first, for: left))
            #expect(right.font == resolvedFont(.body, in: themes.second, for: right))
            #expect(left.font != right.font)
            window.traitOverrides.pkyTheme = themes.second
            window.updateTraitsIfNeeded()
            #expect(left.font == resolvedFont(.body, in: themes.first, for: left))
            #expect(right.font == resolvedFont(.body, in: themes.second, for: right))
        }

        @Test(
            "A role set before mounting resolves once mounted and keeps updating after subview removal"
        )
        func detachedRoleResolvesAfterMountingAndSubviewRemoval() throws {
            let themes = UIViewPKYThemeChangeTests.makeThemes()
            let label = UILabel()
            label.text = "Retained"
            let removable = UIView()
            label.addSubview(removable)
            let unbound = try #require(label.font)
            label.pkyTypography = .display.bold
            #expect(label.font == unbound)
            let window = UIViewPKYThemeChangeTests.makeWindow(theme: themes.first)
            defer { window.isHidden = true }
            window.addSubview(label)
            window.updateTraitsIfNeeded()
            #expect(label.font == resolvedFont(.display.bold, in: themes.first, for: label))
            for subview in label.subviews {
                subview.removeFromSuperview()
            }
            #expect(removable.superview == nil)
            window.traitOverrides.pkyTheme = themes.second
            window.updateTraitsIfNeeded()
            #expect(label.font == resolvedFont(.display.bold, in: themes.second, for: label))
            #expect(label.text == "Retained")
        }

        @Test(
            "A detached label with an explicit theme resolves its role at once and keeps it when mounted"
        )
        func explicitThemeResolvesRoleBeforeMounting() throws {
            let themes = UIViewPKYThemeChangeTests.makeThemes()
            let label = UILabel()
            label.traitOverrides.pkyTheme = themes.first
            label.updateTraitsIfNeeded()
            #expect(label.traitCollection.pkyTheme == themes.first)
            label.pkyTypography = .display.bold
            let detached = try #require(label.font)
            #expect(detached == resolvedFont(.display.bold, in: themes.first, for: label))
            let window = UIViewPKYThemeChangeTests.makeWindow(theme: themes.first)
            defer { window.isHidden = true }
            window.addSubview(label)
            window.updateTraitsIfNeeded()
            #expect(label.traitCollection.pkyTheme == themes.first)
            #expect(label.font == detached)
        }

        @Test(
            "Button title typography follows theme swaps and keeps its transformer, title, and state"
        )
        func buttonTitleTypographyFollowsThemeSwaps() throws {
            let themes = UIViewPKYThemeChangeTests.makeThemes()
            let role = PKYTypographyRole.body.semibold
            let link = URL(string: "pky://retained-transformer")
            var configuration = UIButton.Configuration.plain()
            configuration.title = "Delete"
            configuration.subtitle = "Retained"
            let transformer = UIConfigurationTextAttributesTransformer { incoming in
                var attributes = incoming
                attributes.link = link
                return attributes
            }
            configuration.titleTextAttributesTransformer = transformer
            let button = UIButton(configuration: configuration)
            var actions = 0
            button.addAction(UIAction { _ in actions += 1 }, for: .touchUpInside)
            button.isSelected = true
            button.pkyTitleTypography = role
            let window = UIViewPKYThemeChangeTests.makeWindow(theme: themes.first)
            defer { window.isHidden = true }
            window.addSubview(button)
            window.updateTraitsIfNeeded()
            let first = try titleAttributes(of: button)
            #expect(first.uiKit.font == resolvedFont(role, in: themes.first, for: button))
            #expect(first.link == link)
            button.configuration?.title = "Renamed"
            window.traitOverrides.pkyTheme = themes.second
            window.updateTraitsIfNeeded()
            let second = try titleAttributes(of: button)
            #expect(second.uiKit.font == resolvedFont(role, in: themes.second, for: button))
            #expect(second.uiKit.font != first.uiKit.font)
            #expect(second.link == link)
            #expect(button.configuration?.title == "Renamed")
            #expect(button.configuration?.subtitle == "Retained")
            #expect(button.isSelected)
            button.sendActions(for: .touchUpInside)
            #expect(actions == 1)
        }

        @Test(
            "Attributed text rebuilds on theme swaps and text views keep multi-range bidirectional selections"
        )
        func attributedTextRebuildsOnThemeSwaps() throws {
            let themes = UIViewPKYThemeChangeTests.makeThemes()
            let label = UILabel()
            let text = UITextView()
            var stale = 0
            label.pkyAttributedText { _ in
                stale += 1
                return nil
            }
            let binding = try #require(pkyAttributedTextRegistration(on: label))
            let make: @MainActor (UITraitCollection) -> NSAttributedString = { traits in
                let color = traits.pkyResolvedTheme.color.accent(.primary)
                return NSAttributedString(
                    string: "Retained שלום input",
                    attributes: [.foregroundColor: color]
                )
            }
            label.pkyAttributedText(make)
            #expect(
                (pkyAttributedTextRegistration(on: label) as AnyObject?) === (binding as AnyObject)
            )
            text.pkyAttributedText(make)
            let window = UIViewPKYThemeChangeTests.makeWindow(theme: themes.first)
            defer { window.isHidden = true }
            window.addSubview(label)
            window.addSubview(text)
            window.updateTraitsIfNeeded()
            let first = themes.first.theme.color.accent(.primary)
            #expect(foreground(of: label.attributedText) == first)
            #expect(foreground(of: text.attributedText) == first)
            text.selectedRanges = [
                NSRange(location: 2, length: 3),
                NSRange(location: 10, length: 2),
            ]
            let selection = text.selectedRanges
            #expect(selection.count == 2)
            window.traitOverrides.pkyTheme = themes.second
            window.updateTraitsIfNeeded()
            let second = themes.second.theme.color.accent(.primary)
            #expect(foreground(of: label.attributedText) == second)
            #expect(foreground(of: text.attributedText) == second)
            #expect(label.attributedText?.string == "Retained שלום input")
            #expect(text.attributedText.string == "Retained שלום input")
            #expect(text.selectedRanges == selection)
            #expect(stale == 0)
        }

        @Test("Typography and attributed-text bindings do not retain their controls")
        func typographyBindingsReleaseTheirControls() {
            weak var label: UILabel?
            weak var button: UIButton?
            weak var attributed: UILabel?
            autoreleasepool {
                let typed = UILabel()
                typed.pkyTypography = .body
                label = typed
                let action = UIButton(configuration: .plain())
                action.pkyTitleTypography = .body
                button = action
                let text = UILabel()
                text.pkyAttributedText { _ in NSAttributedString(string: "Released") }
                attributed = text
            }
            #expect(label == nil)
            #expect(button == nil)
            #expect(attributed == nil)
        }
    }

    @MainActor
    private protocol TypographyTextControl: UIView {
        var pkyTypography: PKYTypographyRole? { get set }
    }

    extension UILabel: TypographyTextControl {}

    extension UITextField: TypographyTextControl {}

    extension UITextView: TypographyTextControl {}

    private final class RoleResetController: UIViewController {
        let label = UILabel()
        private(set) var resets = 0

        override func viewDidLoad() {
            super.viewDidLoad()
            label.text = "Retained"
            view.addSubview(label)
            registerForTraitChanges([PKYThemeTrait.self]) { (controller: RoleResetController, _) in
                controller.resets += 1
                let even = controller.resets.isMultiple(of: 2)
                controller.label.pkyTypography = even ? .caption : .title.bold
            }
        }
    }

    @MainActor
    private func makeTextControl(
        _ kind: UIKitTypographyBindingTests.TextControl
    ) -> any TypographyTextControl {
        switch kind {
        case .label:
            let label = UILabel()
            label.text = "Retained input"
            return label
        case .field:
            let field = UITextField()
            field.text = "Retained input"
            return field
        case .textView:
            let text = UITextView()
            text.text = "Retained input"
            return text
        }
    }

    @MainActor
    private func displayedFont(of control: UIView) -> UIFont? {
        switch control {
        case let label as UILabel: label.font
        case let field as UITextField: field.font
        case let text as UITextView: text.font
        default: nil
        }
    }

    @MainActor
    private func displayedText(of control: UIView) -> String? {
        switch control {
        case let label as UILabel: label.text
        case let field as UITextField: field.text
        case let text as UITextView: text.text
        default: nil
        }
    }

    @MainActor
    private func resolvedFont(
        _ role: PKYTypographyRole,
        in theme: PKYThemeTraitValue,
        for view: UIView
    ) -> UIFont {
        role.uiFont(in: theme.theme, compatibleWith: view.traitCollection)
    }

    @MainActor
    private func selectMiddle(of control: UIView) {
        if let input = control as? UITextInput,
           let start = input.position(from: input.beginningOfDocument, offset: 2),
           let end = input.position(from: start, offset: 3) {
            input.selectedTextRange = input.textRange(from: start, to: end)
        }
    }

    @MainActor
    private func selectedRange(in control: UIView) -> NSRange? {
        guard let input = control as? UITextInput, let range = input.selectedTextRange else {
            return nil
        }
        return NSRange(
            location: input.offset(from: input.beginningOfDocument, to: range.start),
            length: input.offset(from: range.start, to: range.end)
        )
    }

    @MainActor
    private func showsRole(_ label: UILabel, in theme: PKYThemeTraitValue) -> Bool {
        guard label.traitCollection.pkyTheme == theme, let role = label.pkyTypography else {
            return false
        }
        return label.font == resolvedFont(role, in: theme, for: label)
    }

    @MainActor
    private func titleAttributes(of button: UIButton) throws -> AttributeContainer {
        let transformer = try #require(button.configuration?.titleTextAttributesTransformer)
        return transformer.transform(AttributeContainer())
    }

    private func foreground(of text: NSAttributedString?) -> UIColor? {
        text?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
    }
#endif
