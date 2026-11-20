#if os(iOS)
    import SwiftUI
    import UIKit

    /// Maps app-owned interaction events to consistent haptic feedback. Callers describe the event; Pocky chooses its intensity.
    ///
    /// Do not add feedback to system interactions that already provide it, such as switches, context menus, drag lifts, or paging.
    @MainActor
    public enum PKYHaptics {
        /// An app-owned interaction event, used to prepare UIKit feedback or select SwiftUI feedback.
        public enum Event: CaseIterable, Sendable {
            /// A discrete selection changed, such as a segment, checkmark, chart value, or mode.
            case selectionChanged
            /// A regular button or gesture action took effect, such as marking, sharing, or adding.
            case actionTriggered
            /// A continuous gesture crossed the commit threshold and will perform its action when released.
            case thresholdCrossed
            /// An item reached a new position or fixed state, such as dropping a reordered item or pinning it.
            case itemPlaced
            /// A multistep task completed successfully, such as confirming deletion or finishing a batch.
            case succeeded
            /// The user confirmed an irreversible or data-clearing operation.
            case destructiveConfirmed
            /// A task failed for a reason other than explicit user cancellation.
            case failed
        }

        private static let selection = UISelectionFeedbackGenerator()
        private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
        private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
        private static let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
        private static let notification = UINotificationFeedbackGenerator()

        /// A discrete selection changed, such as a segment, checkmark, chart value, or mode.
        public static func selectionChanged() {
            selection.selectionChanged()
        }

        /// A regular button or gesture action took effect, such as marking, sharing, or adding.
        public static func actionTriggered() {
            lightImpact.impactOccurred()
        }

        /// A continuous gesture crossed the commit threshold and will perform its action when released.
        public static func thresholdCrossed() {
            mediumImpact.impactOccurred()
        }

        /// An item reached a new position or fixed state, such as dropping a reordered item or pinning it.
        public static func itemPlaced() {
            rigidImpact.impactOccurred()
        }

        /// A multistep task completed successfully, such as confirming deletion or finishing a batch.
        public static func succeeded() {
            notification.notificationOccurred(.success)
        }

        /// The user confirmed an irreversible or data-clearing operation.
        public static func destructiveConfirmed() {
            notification.notificationOccurred(.warning)
        }

        /// A task failed for a reason other than explicit user cancellation.
        public static func failed() {
            notification.notificationOccurred(.error)
        }

        /// Readies the feedback for an event expected shortly, reducing its latency.
        ///
        /// Call when the event becomes likely, such as when a drag begins before it can cross its threshold.
        /// Preparation lasts only a few seconds; prepare again for later events. SwiftUI's
        /// `sensoryFeedback(_:trigger:)` prepares automatically.
        ///
        /// - Parameter event: The event that may follow.
        public static func prepare(_ event: Event) {
            generator(for: event).prepare()
        }

        private static func generator(for event: Event) -> UIFeedbackGenerator {
            switch event {
            case .selectionChanged: selection
            case .actionTriggered: lightImpact
            case .thresholdCrossed: mediumImpact
            case .itemPlaced: rigidImpact
            case .succeeded, .destructiveConfirmed, .failed: notification
            }
        }
    }

    public extension PKYHaptics.Event {
        /// The matching SwiftUI feedback, for use with `View.sensoryFeedback(_:trigger:)`.
        var sensoryFeedback: SensoryFeedback {
            switch self {
            case .selectionChanged: .selection
            case .actionTriggered: .impact(weight: .light)
            case .thresholdCrossed: .impact(weight: .medium)
            case .itemPlaced: .impact(flexibility: .rigid)
            case .succeeded: .success
            case .destructiveConfirmed: .warning
            case .failed: .error
            }
        }
    }
#endif
