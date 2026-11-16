#if os(iOS)
    import UIKit

    /// The native color type used by foundation roles on iOS.
    public typealias PKYColor = UIColor
#elseif os(macOS)
    import AppKit

    /// The native color type used by foundation roles on macOS.
    public typealias PKYColor = NSColor
#endif
