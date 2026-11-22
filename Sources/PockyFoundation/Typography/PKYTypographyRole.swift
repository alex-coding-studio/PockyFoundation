import CoreGraphics

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

public struct PKYTypographyRole: Hashable, Sendable {
    enum Kind: Hashable, Sendable {
        case display
        case pageTitle
        case title
        case heading
        case body
        case supporting
        case caption
        case action

        var customSize: CGFloat {
            switch self {
            case .display: 32
            case .pageTitle: 28
            case .title: 24
            case .heading: 18
            case .body: 16
            case .supporting: 15
            case .caption: 14
            case .action: 16
            }
        }

        var standardWeight: PKYFontWeight {
            switch self {
            case .display, .pageTitle: .bold
            case .title, .heading, .action: .semibold
            case .body, .supporting, .caption: .regular
            }
        }

        #if os(iOS)
            var uiKitTextStyle: UIFont.TextStyle {
                switch self {
                case .display: .largeTitle
                case .pageTitle: .title1
                case .title: .title2
                case .heading: .headline
                case .body, .action: .body
                case .supporting: .subheadline
                case .caption: .footnote
                }
            }
        #elseif os(macOS)
            var nsFontTextStyle: NSFont.TextStyle {
                switch self {
                case .display: .largeTitle
                case .pageTitle: .title1
                case .title: .title2
                case .heading: .headline
                case .body, .action: .body
                case .supporting: .subheadline
                case .caption: .footnote
                }
            }
        #endif
    }

    public static let display = Self(kind: .display)
    public static let pageTitle = Self(kind: .pageTitle)
    public static let title = Self(kind: .title)
    public static let heading = Self(kind: .heading)
    public static let body = Self(kind: .body)
    public static let supporting = Self(kind: .supporting)
    public static let caption = Self(kind: .caption)
    public static let action = Self(kind: .action)

    let kind: Kind
    private(set) var weight: PKYFontWeight?
    private(set) var isItalic = false
    private(set) var isRounded = false
    private(set) var isMonospaced = false
    private(set) var usesMonospacedDigits = false
    private(set) var referenceSize: CGFloat?

    public var regular: Self {
        withWeight(.regular)
    }

    public var medium: Self {
        withWeight(.medium)
    }

    public var semibold: Self {
        withWeight(.semibold)
    }

    public var bold: Self {
        withWeight(.bold)
    }

    public var italic: Self {
        var copy = self
        copy.isItalic = true
        return copy
    }

    public var rounded: Self {
        var copy = self
        copy.isRounded = true
        return copy
    }

    public var monospaced: Self {
        var copy = self
        copy.isMonospaced = true
        return copy
    }

    public var monospacedDigits: Self {
        var copy = self
        copy.usesMonospacedDigits = true
        return copy
    }

    private init(kind: Kind) {
        self.kind = kind
    }

    public func withReferenceSize(_ size: CGFloat) -> Self {
        var copy = self
        copy.referenceSize = size
        return copy
    }

    private func withWeight(_ weight: PKYFontWeight) -> Self {
        var copy = self
        copy.weight = weight
        return copy
    }
}
