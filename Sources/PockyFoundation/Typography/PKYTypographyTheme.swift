import SwiftUI

public struct PKYTypographyTheme: Sendable {
    public enum Scaling: Hashable, Sendable {
        case fixed

        case dynamic(maximum: DynamicTypeSize)
    }

    public let family: PKYFontFamily

    public let scaling: Scaling

    public init(family: PKYFontFamily, scaling: Scaling) {
        self.family = family
        self.scaling = scaling
    }
}
