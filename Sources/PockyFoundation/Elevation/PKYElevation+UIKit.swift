#if os(iOS)
    import ObjectiveC
    import UIKit

    @MainActor private var pkyElevationKey: UInt8 = 0

    public extension UIView {
        /// Applies the shared elevation and keeps it current as the view's appearance changes.
        ///
        /// The recipe and color resolve against the view's current traits immediately, and again when
        /// the view mounts or the theme or any trait affecting color appearance, such as dark mode or
        /// increased contrast, changes. A later call replaces the style and color; theme injection is not
        /// required. Preserves the view's clipping, corners, layout, and `shadowPath`. The shadow color is
        /// managed here, so do not also set `pkyLayerShadowColor`.
        ///
        /// - Parameters:
        ///   - style: The shadow role chosen for the surface relationship or media legibility.
        ///   - color: The shadow color provided by the theme or component.
        func pkyApplyElevation(_ style: PKYElevation.Style, color: UIColor) {
            let observed = UITraitCollection.systemTraitsAffectingColorAppearance
            let current = objc_getAssociatedObject(self, &pkyElevationKey) as? PKYThemeBinding
            let binding: PKYThemeBinding
            if let current, current.observes(observed) {
                binding = current
            } else {
                current?.stop()
                binding = PKYThemeBinding(owner: self, traits: observed)
                objc_setAssociatedObject(
                    self,
                    &pkyElevationKey,
                    binding,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
            binding.onUpdate = { [weak self] traits in
                self?.pkyResolveElevation(style, color: color, traits: traits)
            }
            pkyResolveElevation(style, color: color, traits: traitCollection)
        }

        /// Stops elevation updates and clears the managed shadow properties while preserving the
        /// component's clipping, corners, layout, and `shadowPath`.
        func pkyRemoveElevation() {
            (objc_getAssociatedObject(self, &pkyElevationKey) as? PKYThemeBinding)?.stop()
            objc_setAssociatedObject(
                self,
                &pkyElevationKey,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            layer.pkyRemoveElevation()
        }

        private func pkyResolveElevation(
            _ style: PKYElevation.Style,
            color: UIColor,
            traits: UITraitCollection
        ) {
            layer.pkyApplyElevation(
                style,
                color: color.resolvedColor(with: traits).cgColor,
                appearance: traits.userInterfaceStyle == .dark ? .dark : .light
            )
        }
    }
#endif
