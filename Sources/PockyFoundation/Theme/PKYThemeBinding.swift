#if os(iOS)
    import UIKit

    @MainActor
    public final class PKYThemeBinding {
        public var onUpdate: (@MainActor (UITraitCollection) -> Void)?

        private(set) var registration: (any UITraitChangeRegistration)?
        private(set) var mountLink: UIUpdateLink?
        let resolvesTheme: Bool

        private weak var owner: UIView?
        private let observedTraits: [ObjectIdentifier]

        public init(
            owner: UIView,
            traits: [UITrait] = [],
            resolvesTheme: Bool = false
        ) {
            self.owner = owner
            self.resolvesTheme = resolvesTheme
            observedTraits = traits.map { ObjectIdentifier($0) }
            registration = owner.registerForTraitChanges([
                PKYThemeTrait.self,
                UITraitPreferredContentSizeCategory.self,
                UITraitLegibilityWeight.self,
            ] + traits) { [weak self] (_: UIView, _) in
                self?.refresh(fromTraitChange: true)
            }
        }

        public func refresh() {
            refresh(fromTraitChange: false)
        }

        public func stop() {
            onUpdate = nil
            mountLink?.isEnabled = false
            mountLink = nil
            if let owner, let registration {
                owner.unregisterForTraitChanges(registration)
            }
            registration = nil
        }

        func observes(_ traits: [UITrait]) -> Bool {
            registration != nil && observedTraits == traits.map { ObjectIdentifier($0) }
        }

        func refresh(fromTraitChange: Bool) {
            guard let owner else {
                return
            }
            let traits = owner.traitCollection
            guard hasFinalTraitsForImmediateUpdate(
                owner: owner,
                traits: traits,
                fromTraitChange: fromTraitChange
            ) else {
                scheduleVisibleUpdate(owner)
                return
            }
            if owner.window != nil {
                mountLink?.isEnabled = false
                mountLink = nil
            }
            onUpdate?(traits)
        }

        func performVisibleUpdate() {
            guard mountLink != nil, let owner, owner.window != nil else {
                return
            }
            mountLink?.isEnabled = false
            mountLink = nil
            onUpdate?(owner.traitCollection)
        }

        private func hasFinalTraitsForImmediateUpdate(
            owner: UIView,
            traits: UITraitCollection,
            fromTraitChange: Bool
        ) -> Bool {
            let hasEffectiveTraits = owner.window != nil || traits.pkyTheme != nil
            let waitsForThemeInjection = resolvesTheme && !fromTraitChange && traits.pkyTheme == nil
            return hasEffectiveTraits && !waitsForThemeInjection
        }

        private func scheduleVisibleUpdate(_ owner: UIView) {
            guard mountLink == nil else {
                return
            }
            let link = UIUpdateLink(view: owner)
            link.addAction { [weak self] _, _ in
                self?.performVisibleUpdate()
            }
            mountLink = link
            link.isEnabled = true
        }
    }
#endif
