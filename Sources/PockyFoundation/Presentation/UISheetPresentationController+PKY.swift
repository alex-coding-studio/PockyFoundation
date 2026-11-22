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
        func pkyApplyStandardStyle(
            detents: [Detent],
            fillsWidthInLandscape: Bool = false
        ) {
            pkyApplyStandardGeometry(detents: detents, fillsWidthInLandscape: fillsWidthInLandscape)
            pkyUsePaperBackground()
        }

        func pkyUsePaperBackground() {
            #if compiler(>=6.2.1)
                guard #available(iOS 26.1, *) else {
                    return
                }
                let controller = presentedViewController
                if pkyPaperBackgroundBinding?.controller !== controller {
                    pkyPaperBackgroundBinding?.stop()
                    let registration = controller.registerForTraitChanges(
                        [
                            PKYThemeTrait.self,
                        ] + UITraitCollection.systemTraitsAffectingColorAppearance
                    ) { [weak self] (controller: UIViewController, _) in
                        self?.pkyApplyPaperBackground(compatibleWith: controller.traitCollection)
                    }
                    pkyPaperBackgroundBinding = PKYPaperBackgroundBinding(
                        controller: controller,
                        registration: registration
                    )
                }
                pkyApplyPaperBackground(compatibleWith: controller.traitCollection)
            #endif
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

        #if compiler(>=6.2.1)
            @available(iOS 26.1, *)
            private func pkyApplyPaperBackground(compatibleWith traits: UITraitCollection) {
                let paper = UIColor.pkyBackground(.grouped(.primary))
                backgroundEffect = UIColorEffect(
                    color: traits.pkyTheme == nil ? paper : paper.resolvedColor(with: traits)
                )
            }
        #endif
    }
#endif
