#if os(iOS)
    import ObjectiveC
    import UIKit

    @MainActor private var pkyPaperBackgroundKey: UInt8 = 0

    @MainActor
    private final class PKYPaperBackgroundBinding {
        weak var controller: UIViewController?
        let registration: any UITraitChangeRegistration

        init(controller: UIViewController, registration: any UITraitChangeRegistration) {
            self.controller = controller
            self.registration = registration
        }

        func stop() {
            controller?.unregisterForTraitChanges(registration)
        }
    }

    public extension UISheetPresentationController {
        /// Applies the supplied detents, a visible grabber, and the effective theme's grouped primary
        /// background, which follows theme and appearance changes.
        ///
        /// In compact height the sheet attaches to the edge unless the caller keeps the system's
        /// full-width presentation.
        func pkyApplyStandardStyle(
            detents: [Detent],
            fillsWidthInLandscape: Bool = false
        ) {
            pkyApplyStandardGeometry(detents: detents, fillsWidthInLandscape: fillsWidthInLandscape)
            pkyUsePaperBackground()
        }

        /// On iOS 26.1 and later, applies the grouped primary background from the presented controller's
        /// effective theme without changing sheet geometry.
        ///
        /// The background updates with the effective theme and the system traits that affect color
        /// appearance; repeated calls do not add observers. Until the controller has a theme, the dynamic
        /// color is used; afterwards it resolves against that theme.
        func pkyUsePaperBackground() {
            guard #available(iOS 26.1, *) else {
                return
            }
            let controller = presentedViewController
            if pkyPaperBackgroundBinding?.controller !== controller {
                pkyPaperBackgroundBinding?.stop()
                let registration = controller.registerForTraitChanges(
                    [PKYThemeTrait.self] + UITraitCollection.systemTraitsAffectingColorAppearance
                ) { [weak self] (controller: UIViewController, _) in
                    self?.pkyApplyPaperBackground(compatibleWith: controller.traitCollection)
                }
                pkyPaperBackgroundBinding = PKYPaperBackgroundBinding(
                    controller: controller,
                    registration: registration
                )
            }
            pkyApplyPaperBackground(compatibleWith: controller.traitCollection)
        }

        private var pkyPaperBackgroundBinding: PKYPaperBackgroundBinding? {
            get { objc_getAssociatedObject(
                self,
                &pkyPaperBackgroundKey
            ) as? PKYPaperBackgroundBinding }
            set {
                objc_setAssociatedObject(
                    self,
                    &pkyPaperBackgroundKey,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }

        private func pkyApplyStandardGeometry(detents: [Detent], fillsWidthInLandscape: Bool) {
            self.detents = detents
            prefersGrabberVisible = true
            guard !fillsWidthInLandscape else {
                return
            }
            prefersEdgeAttachedInCompactHeight = true
        }

        @available(iOS 26.1, *)
        private func pkyApplyPaperBackground(compatibleWith traits: UITraitCollection) {
            let paper = UIColor.pkyBackground(.grouped(.primary))
            backgroundEffect = UIColorEffect(
                color: traits.pkyTheme == nil ? paper : paper.resolvedColor(with: traits)
            )
        }
    }
#endif
