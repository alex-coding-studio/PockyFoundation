import SwiftUI

public extension View {
    func pkyClipCapsule() -> some View {
        clipShape(Capsule())
    }

    @available(macOS 26.0, *)
    func pkyClipConcentric() -> some View {
        clipShape(ConcentricRectangle())
    }

    @available(macOS 26.0, *)
    func pkyClipConcentric(minimum: CGFloat) -> some View {
        clipShape(
            ConcentricRectangle(
                corners: .concentric(minimum: .fixed(minimum))
            )
        )
    }
}
