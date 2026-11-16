import CoreGraphics

public extension PKYLayout {
    /// Minimum interaction dimensions for app-owned controls.
    enum Target {
        /// Minimum interaction dimension; callers still own accessibility and native control behavior.
        public static let minimum: CGFloat = 44
    }
}
