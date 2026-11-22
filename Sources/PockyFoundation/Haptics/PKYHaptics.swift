#if os(iOS)
    import SwiftUI
    import UIKit

    @MainActor
    public enum PKYHaptics {
        public enum Event: CaseIterable, Sendable {
            case selectionChanged
            case actionTriggered
            case thresholdCrossed
            case itemPlaced
            case succeeded
            case destructiveConfirmed
            case failed
        }

        private static let selection = UISelectionFeedbackGenerator()
        private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
        private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
        private static let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
        private static let notification = UINotificationFeedbackGenerator()

        public static func selectionChanged() {
            selection.selectionChanged()
        }

        public static func actionTriggered() {
            lightImpact.impactOccurred()
        }

        public static func thresholdCrossed() {
            mediumImpact.impactOccurred()
        }

        public static func itemPlaced() {
            rigidImpact.impactOccurred()
        }

        public static func succeeded() {
            notification.notificationOccurred(.success)
        }

        public static func destructiveConfirmed() {
            notification.notificationOccurred(.warning)
        }

        public static func failed() {
            notification.notificationOccurred(.error)
        }

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
