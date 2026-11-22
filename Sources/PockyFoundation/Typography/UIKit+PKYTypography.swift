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

    @MainActor
    func pkyTypographyRegistration(
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
        var pkyTypography: PKYTypographyRole? {
            get { pkyReadTypography(on: self) }
            set { pkySetTypography(newValue, on: self) }
        }
    }

    public extension UITextView {
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

    @MainActor
    func pkyTitleTypographyRegistration(
        on button: UIButton
    ) -> (any UITraitChangeRegistration)? {
        (objc_getAssociatedObject(
            button,
            &pkyTitleTypographyKey
        ) as? PKYTitleTypographyBinding)?.observer.registration
    }

    @MainActor
    func pkyAttributedTextRegistration(
        on view: UIView
    ) -> (any UITraitChangeRegistration)? {
        pkyThemeUpdateRegistration(on: view, key: &pkyAttributedTextKey)
    }

    public extension UIButton {
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
