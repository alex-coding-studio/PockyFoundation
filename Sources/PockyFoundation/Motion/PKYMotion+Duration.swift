import Foundation

public extension PKYMotion {
    /// Animation durations in seconds, from immediate feedback to scene transitions.
    enum Duration {
        /// Immediate interaction feedback.
        public static let quick: TimeInterval = 0.15

        /// Ordinary changes within a view.
        public static let standard: TimeInterval = 0.25

        /// Deliberate changes in place.
        public static let slow: TimeInterval = 0.35

        /// Travel between interface regions.
        public static let long: TimeInterval = 0.45

        /// Complete scene transitions.
        public static let extended: TimeInterval = 0.6
    }
}
