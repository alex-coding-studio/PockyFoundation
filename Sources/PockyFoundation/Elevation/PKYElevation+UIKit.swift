#if os(iOS)
    import ObjectiveC
    import UIKit

    @MainActor private var pkyElevationKey: UInt8 = 0

    public extension UIView {
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
