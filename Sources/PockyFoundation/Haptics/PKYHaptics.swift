#if os(iOS)
    import UIKit

    /// Maps app-owned interaction events to consistent haptic feedback. Callers describe the event; Pocky chooses its intensity.
    ///
    /// Do not add feedback to system interactions that already provide it, such as switches, context menus, drag lifts, or paging.
    @MainActor
    public enum PKYHaptics {
        /// A discrete selection changed, such as a segment, checkmark, chart value, or mode.
        public static func selectionChanged() {
            UISelectionFeedbackGenerator().selectionChanged()
        }

        /// A regular button or gesture action took effect, such as marking, sharing, or adding.
        public static func actionTriggered() {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        /// A continuous gesture crossed the commit threshold and will perform its action when released.
        public static func thresholdCrossed() {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }

        /// An item reached a new position or fixed state, such as dropping a reordered item or pinning it.
        public static func itemPlaced() {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }

        /// A multistep task completed successfully, such as confirming deletion or finishing a batch.
        public static func succeeded() {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        /// The user confirmed an irreversible or data-clearing operation.
        public static func destructiveConfirmed() {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }

        /// A task failed for a reason other than explicit user cancellation.
        public static func failed() {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
#endif
