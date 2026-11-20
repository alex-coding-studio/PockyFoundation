#if os(iOS)
    import UIKit

    /// Keeps a component's theme-dependent rendering current without retaining its owner.
    ///
    /// Reusable components use a binding for updates of their own, independent of the host's
    /// `pkyOnThemeChange(observing:_:)` callback. Set `onUpdate`, then call `refresh()` after changing
    /// the state it renders. The update runs at once when the owner is in a window or already inherits
    /// a theme, otherwise at the owner's first visible UI update, and again whenever the theme, content
    /// size, legibility weight, or supplied traits change. Keep the binding for as long as updates are
    /// needed; `stop()` ends them.
    @MainActor
    public final class PKYThemeBinding {
        /// The theme-dependent update, invoked with the owner's current traits.
        public var onUpdate: (@MainActor (UITraitCollection) -> Void)?

        private(set) var registration: (any UITraitChangeRegistration)?
        private(set) var mountLink: UIUpdateLink?
        let resolvesTheme: Bool

        private weak var owner: UIView?
        private let observedTraits: [ObjectIdentifier]

        /// Registers for theme, content-size, legibility-weight, and supplied trait changes on the owner.
        ///
        /// - Parameters:
        ///   - owner: The view whose traits drive the update; the binding holds it weakly.
        ///   - traits: Additional traits that affect the rendering, such as
        ///     `UITraitCollection.systemTraitsAffectingColorAppearance`.
        ///   - resolvesTheme: Whether the update reads the theme. A refresh outside a trait change then
        ///     waits until the owner inherits a theme rather than running the missing-injection policy.
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

        /// Runs the update when the owner's traits are final, otherwise at its next visible UI update.
        public func refresh() {
            refresh(fromTraitChange: false)
        }

        /// Clears `onUpdate` and cancels the trait registration and any pending visible update.
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
            // Run now only with final traits: mounted, or already inheriting a theme. Theme-resolving
            // updates outside a trait callback also wait until the theme arrives.
            let waitsForTraits = resolvesTheme && !fromTraitChange && traits.pkyTheme == nil
            guard owner.window != nil || traits.pkyTheme != nil, !waitsForTraits else {
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
