#if os(iOS)
    import UIKit

    public typealias PKYColor = UIColor
#elseif os(macOS)
    import AppKit

    public typealias PKYColor = NSColor
#endif
