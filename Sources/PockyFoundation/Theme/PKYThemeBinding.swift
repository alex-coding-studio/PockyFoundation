#if os(iOS)
    import UIKit

    /// Tracks trait changes and one pending visible update without retaining the owner.
    @MainActor
    @_spi(PockyComponents) public final class PKYThemeBinding {
        /// The appearance-dependent callback, invoked with the owner's current traits.
        @_spi(PockyComponents) public var onUpdate: (@MainActor (UITraitCollection) -> Void)?
        /// The active trait registration, cleared by `stop()`.
        @_spi(PockyComponents) public private(set) var registration: (
            any UITraitChangeRegistration
        )?

        /// The pending visible-update link, if the owner is waiting to mount.
        @_spi(PockyComponents) public private(set) var mountLink: UIUpdateLink?

        /// Whether callbacks require inherited theme traits before an external refresh.
        @_spi(PockyComponents) public var resolvesTheme: Bool

        private weak var owner: UIView?
        private let observedTraits: [ObjectIdentifier]

        /// Registers theme, content-size, and supplied traits for a weakly held owner.
        @_spi(PockyComponents) public init(
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
            ] + traits) { [weak self] (_: UIView, _) in
                self?.refresh(fromTraitChange: true)
            }
        }

        /// Whether an active binding observes exactly the supplied additional traits in the same order.
        @_spi(PockyComponents) public func observes(_ traits: [UITrait]) -> Bool {
            registration != nil && observedTraits == traits.map { ObjectIdentifier($0) }
        }

        /// Refreshes the owner's appearance-dependent state when its current traits are ready.
        ///
        /// - Parameter fromTraitChange: Whether this is the owner's own trait callback, where its traits are current.
        @_spi(PockyComponents) public func refresh(fromTraitChange: Bool = false) {
            guard let owner else {
                return
            }
            let traits = owner.traitCollection
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

        /// Clears the callback and cancels both trait registration and pending visible updates.
        @_spi(PockyComponents) public func stop() {
            onUpdate = nil
            mountLink?.isEnabled = false
            mountLink = nil
            if let owner, let registration {
                owner.unregisterForTraitChanges(registration)
            }
            registration = nil
        }

        /// Runs one pending callback when the owner reaches a visible update, clearing the wait; detached owners keep waiting.
        @_spi(PockyComponents) public func performVisibleUpdate() {
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
