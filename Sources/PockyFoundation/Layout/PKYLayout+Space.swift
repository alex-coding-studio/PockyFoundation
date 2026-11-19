import CoreGraphics

public extension PKYLayout {
    /// A point-based primitive spacing scale; prefer semantic gap and inset roles.
    enum Space {
        /// The smallest step, used by compact content gaps and compact vertical control and row padding.
        public static let s4: CGFloat = 4
        /// Standard content gaps, compact page and container padding, and standard vertical padding.
        public static let s8: CGFloat = 8
        /// Wide content gaps, compact group gaps, and standard horizontal control padding.
        public static let s12: CGFloat = 12
        /// Standard group gaps, compact section gaps, and standard page and container padding.
        public static let s16: CGFloat = 16
        /// Wide group gaps, standard section gaps, and wide page and container padding.
        public static let s24: CGFloat = 24
        /// The largest step, used by wide section gaps.
        public static let s32: CGFloat = 32
    }
}
