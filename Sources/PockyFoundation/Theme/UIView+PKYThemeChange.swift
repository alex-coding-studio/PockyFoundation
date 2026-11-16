#if os(iOS)
    import ObjectiveC
    import UIKit

    @MainActor private var pkyThemeChangeKey: UInt8 = 0
    @MainActor private var pkyLayerColorBindingKey: UInt8 = 0
    @MainActor private var pkyLayerColorsKey: UInt8 = 0

    /// Installs, replaces, or removes an associated theme update, reusing unchanged trait registrations.
    @MainActor
    @_spi(Pocky) public func pkyInstallThemeUpdate(
        on view: UIView,
        key: UnsafeRawPointer,
        observing traits: [UITrait] = [],
        update: (@MainActor (UITraitCollection) -> Void)?
    ) {
        let current = objc_getAssociatedObject(view, key) as? PKYThemeBinding
        guard let update else {
            current?.stop()
            objc_setAssociatedObject(view, key, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return
        }
        let observed = UITraitCollection.systemTraitsAffectingColorAppearance + traits
        let binding: PKYThemeBinding
        if let current, current.observes(observed) {
            binding = current
        } else {
            current?.stop()
            binding = PKYThemeBinding(owner: view, traits: observed, resolvesTheme: true)
            objc_setAssociatedObject(view, key, binding, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        binding.onUpdate = { traits in
            _ = traits.pkyResolvedTheme
            update(traits)
        }
        binding.refresh()
    }

    /// Returns the active trait registration associated with the supplied owner and key.
    @MainActor
    @_spi(Pocky) public func pkyThemeUpdateRegistration(
        on view: UIView,
        key: UnsafeRawPointer
    ) -> (any UITraitChangeRegistration)? {
        (objc_getAssociatedObject(view, key) as? PKYThemeBinding)?.registration
    }

    /// Returns the view's active one-line theme-change registration.
    @MainActor
    @_spi(Pocky) public func pkyThemeChangeRegistration(
        on view: UIView
    ) -> (any UITraitChangeRegistration)? {
        pkyThemeUpdateRegistration(on: view, key: &pkyThemeChangeKey)
    }

    /// Returns the view's active layer-color registration.
    @MainActor
    @_spi(Pocky) public func pkyLayerColorRegistration(
        on view: UIView
    ) -> (any UITraitChangeRegistration)? {
        pkyThemeUpdateRegistration(on: view, key: &pkyLayerColorBindingKey)
    }

    @MainActor
    private final class PKYLayerColors {
        var border: UIColor?
        var shadow: UIColor?
        var background: UIColor?
        var traits = [UITrait]()
    }

    public extension UIView {
        /// Runs after mounting and again when the effective theme, content size, color-appearance traits,
        /// or extra `observing` traits change. Use for baked images, trait-cached content, or font-dependent layout.
        ///
        /// Each view keeps one callback. Replacing it reuses the registration when possible; cancel with
        /// `pkyCancelThemeChange()`. The callback receives the view; do not capture it strongly. Detached
        /// views wait, and a window without theme injection follows the existing diagnostic or emergency policy.
        ///
        /// - Parameters:
        ///   - traits: Extra host traits affecting rendering, explicitly supplied because host types are unknown here.
        ///   - update: Theme-related rendering or invalidation, such as `setNeedsLayout()`.
        func pkyOnThemeChange(
            observing traits: [UITrait] = [],
            _ update: @escaping @MainActor (Self) -> Void
        ) {
            pkyInstallThemeUpdate(on: self, key: &pkyThemeChangeKey, observing: traits) { [
                weak self
            ] _ in
                guard let view = self as? Self else {
                    return
                }
                update(view)
            }
        }

        /// Cancels the callback installed with `pkyOnThemeChange`, preserving the current rendering.
        func pkyCancelThemeChange() {
            pkyInstallThemeUpdate(on: self, key: &pkyThemeChangeKey, update: nil)
        }

        /// A dynamic color driving `layer.borderColor`, resolved with the view's effective traits on mount and trait changes.
        /// Set to nil to stop management while preserving the current CGColor.
        var pkyLayerBorderColor: UIColor? {
            get { pkyLayerColors?.border }
            set { pkyUpdateLayerColors { $0.border = newValue } }
        }

        /// A dynamic color driving `layer.shadowColor`, resolved on mount and trait changes.
        /// Set to nil to stop management while preserving the current CGColor.
        var pkyLayerShadowColor: UIColor? {
            get { pkyLayerColors?.shadow }
            set { pkyUpdateLayerColors { $0.shadow = newValue } }
        }

        /// A dynamic color driving `layer.backgroundColor` when direct layer assignment is required;
        /// prefer `backgroundColor` for ordinary backgrounds. Nil stops management and preserves the current CGColor.
        var pkyLayerBackgroundColor: UIColor? {
            get { pkyLayerColors?.background }
            set { pkyUpdateLayerColors { $0.background = newValue } }
        }

        /// Extra host traits observed by layer-color bindings when colors depend on app-owned recipes.
        /// Theme, content size, and color appearance are observed by default. Set before or after colors.
        var pkyLayerColorTraits: [UITrait] {
            get { pkyLayerColors?.traits ?? [] }
            set { pkyUpdateLayerColors { $0.traits = newValue } }
        }

        private var pkyLayerColors: PKYLayerColors? {
            objc_getAssociatedObject(self, &pkyLayerColorsKey) as? PKYLayerColors
        }

        private func pkyUpdateLayerColors(_ change: (PKYLayerColors) -> Void) {
            let colors = pkyLayerColors ?? PKYLayerColors()
            change(colors)
            let isEmpty = colors.border == nil && colors.shadow == nil && colors.background == nil
            objc_setAssociatedObject(
                self,
                &pkyLayerColorsKey,
                isEmpty && colors.traits.isEmpty ? nil : colors,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            guard !isEmpty else {
                pkyInstallThemeUpdate(on: self, key: &pkyLayerColorBindingKey, update: nil)
                return
            }
            pkyInstallThemeUpdate(
                on: self,
                key: &pkyLayerColorBindingKey,
                observing: colors.traits
            ) { [weak self, colors] traits in
                guard let layer = self?.layer else {
                    return
                }
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                if let border = colors.border {
                    layer.borderColor = border.resolvedColor(with: traits).cgColor
                }
                if let shadow = colors.shadow {
                    layer.shadowColor = shadow.resolvedColor(with: traits).cgColor
                }
                if let background = colors.background {
                    layer.backgroundColor = background.resolvedColor(with: traits).cgColor
                }
                CATransaction.commit()
            }
        }
    }
#endif
