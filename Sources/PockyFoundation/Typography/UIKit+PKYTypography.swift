#if os(iOS)
    import ObjectiveC
    import UIKit

    @MainActor private var pkyTypographyKey: UInt8 = 0

    @MainActor
    private final class PKYTypographyBinding {
        var role: PKYTypographyRole
        let observer: PKYThemeBinding

        init(owner: UIView, role: PKYTypographyRole) {
            self.role = role
            observer = PKYThemeBinding(owner: owner, resolvesTheme: true)
            observer.onUpdate = { [weak self, weak owner] traits in
                guard let self, let owner else {
                    return
                }
                let font = self.role.uiFont(in: traits.pkyResolvedTheme, compatibleWith: traits)
                switch owner {
                case let label as UILabel:
                    if label.font != font {
                        label.font = font
                    }
                case let field as UITextField:
                    if field.font != font {
                        field.font = font
                    }
                case let text as UITextView:
                    if text.font != font {
                        text.font = font
                    }
                default: break
                }
            }
        }
    }

    @MainActor
    private func pkyReadTypography(on view: UIView) -> PKYTypographyRole? {
        (objc_getAssociatedObject(view, &pkyTypographyKey) as? PKYTypographyBinding)?.role
    }

    /// Returns the view's active typography-role registration.
    @MainActor
    @_spi(Pocky) public func pkyTypographyRegistration(
        on view: UIView
    ) -> (any UITraitChangeRegistration)? {
        (objc_getAssociatedObject(
            view,
            &pkyTypographyKey
        ) as? PKYTypographyBinding)?.observer.registration
    }

    @MainActor
    private func pkySetTypography(_ role: PKYTypographyRole?, on view: UIView) {
        let current = objc_getAssociatedObject(view, &pkyTypographyKey) as? PKYTypographyBinding
        guard let role else {
            current?.observer.stop()
            objc_setAssociatedObject(
                view,
                &pkyTypographyKey,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            return
        }
        let binding = current ?? PKYTypographyBinding(owner: view, role: role)
        binding.role = role
        objc_setAssociatedObject(
            view,
            &pkyTypographyKey,
            binding,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        binding.observer.refresh()
    }

    public extension UILabel {
        /// Setting a role replaces any attributed-text binding. The label resolves the role when mounted and on theme, content size, or
        /// Bold Text changes.
        ///
        /// Set `nil` to stop managing the font and keep the current one. If the theme is missing on the
        /// first mount, the established diagnostic or fallback runs at the first visible UI update.
        var pkyTypography: PKYTypographyRole? {
            get { pkyReadTypography(on: self) }
            set {
                if newValue != nil {
                    pkyAttributedText(nil)
                }
                pkySetTypography(newValue, on: self)
            }
        }
    }

    public extension UITextField {
        /// The typography role that updates the field's font on theme, content size, or Bold Text changes,
        /// preserving text and selection.
        ///
        /// Set `nil` to stop managing the font and keep the current one. If the theme is missing on the
        /// first mount, the established diagnostic or fallback runs at the first visible UI update.
        var pkyTypography: PKYTypographyRole? {
            get { pkyReadTypography(on: self) }
            set { pkySetTypography(newValue, on: self) }
        }
    }

    public extension UITextView {
        /// The typography role that updates the view's uniform font on theme, content size,
        /// or Bold Text changes, preserving text and selection.
        ///
        /// Set `nil` to stop managing the font and keep the current one. If the theme is missing on the
        /// first mount, the established diagnostic or fallback runs at the first visible UI update.
        var pkyTypography: PKYTypographyRole? {
            get { pkyReadTypography(on: self) }
            set { pkySetTypography(newValue, on: self) }
        }
    }

    @MainActor private var pkyTitleTypographyKey: UInt8 = 0
    @MainActor private var pkyAttributedTextKey: UInt8 = 0

    @MainActor
    private final class PKYTitleTypographyBinding {
        var role: PKYTypographyRole
        let observer: PKYThemeBinding

        init(button: UIButton, role: PKYTypographyRole) {
            self.role = role
            let base = button.configuration?.titleTextAttributesTransformer
            observer = PKYThemeBinding(owner: button, resolvesTheme: true)
            observer.onUpdate = { [weak self, weak button] traits in
                guard let self, let button, var configuration = button.configuration else {
                    return
                }
                let font = self.role.uiFont(in: traits.pkyResolvedTheme, compatibleWith: traits)
                configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var attributes = base?.transform(incoming) ?? incoming
                    attributes.font = font
                    return attributes
                }
                button.configuration = configuration
            }
        }
    }

    /// Returns the button's active title-typography registration.
    @MainActor
    @_spi(Pocky) public func pkyTitleTypographyRegistration(
        on button: UIButton
    ) -> (any UITraitChangeRegistration)? {
        (objc_getAssociatedObject(
            button,
            &pkyTitleTypographyKey
        ) as? PKYTitleTypographyBinding)?.observer.registration
    }

    /// Returns the view's active attributed-text registration.
    @MainActor
    @_spi(Pocky) public func pkyAttributedTextRegistration(
        on view: UIView
    ) -> (any UITraitChangeRegistration)? {
        pkyThemeUpdateRegistration(on: view, key: &pkyAttributedTextKey)
    }

    public extension UIButton {
        /// The title typography role of a configuration-based button, resolved when mounted and whenever
        /// the effective theme, content size, or Bold Text changes. The role persists when the title changes.
        ///
        /// It applies through `titleTextAttributesTransformer` and keeps any transformer present when the
        /// role is set, such as a foreground color. Other configuration, loading, disabled and selected
        /// states, and actions are unchanged. The button must already have a `configuration`; install
        /// custom transformers before setting the role. Capsule buttons manage their title font through
        /// their own style, which clears this role, so do not combine the two. Set `nil` to stop managing
        /// the font and keep the current one.
        var pkyTitleTypography: PKYTypographyRole? {
            get {
                (objc_getAssociatedObject(
                    self,
                    &pkyTitleTypographyKey
                ) as? PKYTitleTypographyBinding)?.role
            }
            set {
                let current = objc_getAssociatedObject(
                    self,
                    &pkyTitleTypographyKey
                ) as? PKYTitleTypographyBinding
                guard let newValue else {
                    current?.observer.stop()
                    objc_setAssociatedObject(
                        self,
                        &pkyTitleTypographyKey,
                        nil,
                        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    )
                    return
                }
                let binding = current ?? PKYTitleTypographyBinding(button: self, role: newValue)
                binding.role = newValue
                objc_setAssociatedObject(
                    self,
                    &pkyTitleTypographyKey,
                    binding,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                binding.observer.refresh()
            }
        }
    }

    public extension UILabel {
        /// Builds attributed text from the effective traits: once when mounted, then whenever the theme,
        /// content size, legibility weight, color appearance, or a trait in `observing` changes.
        ///
        /// Installing a builder replaces any typography role. Read the theme (`traits.pkyResolvedTheme`) and fonts from the supplied traits
        /// rather than
        /// capturing the label. A later call replaces the closure; pass `nil` to stop managing and keep
        /// the current text. `observing` adds host traits that affect the attributed text.
        func pkyAttributedText(
            observing traits: [UITrait] = [],
            _ make: (@MainActor (UITraitCollection) -> NSAttributedString?)?
        ) {
            guard let make else {
                pkyInstallThemeUpdate(on: self, key: &pkyAttributedTextKey, update: nil)
                return
            }
            pkyTypography = nil
            pkyInstallThemeUpdate(
                on: self,
                key: &pkyAttributedTextKey,
                observing: traits
            ) { [weak self] traits in
                self?.attributedText = make(traits)
            }
        }
    }

    public extension UITextView {
        /// Builds attributed text from the effective traits and keeps each selected range, including
        /// multi-range bidirectional selections; timing, replacement, and `observing` match
        /// `UILabel.pkyAttributedText`.
        func pkyAttributedText(
            observing traits: [UITrait] = [],
            _ make: (@MainActor (UITraitCollection) -> NSAttributedString?)?
        ) {
            guard let make else {
                pkyInstallThemeUpdate(on: self, key: &pkyAttributedTextKey, update: nil)
                return
            }
            pkyInstallThemeUpdate(
                on: self,
                key: &pkyAttributedTextKey,
                observing: traits
            ) { [weak self] traits in
                guard let self else {
                    return
                }
                let selection = selectedRanges
                attributedText = make(traits)
                let length = attributedText.length
                selectedRanges = selection.map { range in
                    let location = min(range.location, length)
                    return NSRange(location: location, length: min(range.length, length - location))
                }
            }
        }
    }
#endif
