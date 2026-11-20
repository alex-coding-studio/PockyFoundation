import CoreGraphics
import PockyFoundation
import SwiftUI
import Testing

@MainActor
struct PKYShapeSwiftUITests {
    @Test("SHAPE-03/T01 SwiftUI shape utilities clip content without changing layout size")
    func swiftUIUtilitiesPreserveLayoutSize() {
        let content = Color.red.frame(width: 100, height: 40)
        let expected = renderedSize(content)

        #expect(expected != .zero)
        #expect(renderedSize(content.pkyClipCapsule()) == expected)
        if #available(macOS 26.0, *) {
            #expect(renderedSize(content.pkyClipConcentric()) == expected)
            #expect(
                renderedSize(
                    content.pkyClipConcentric(minimum: PKYShape.Radius.content)
                ) == expected
            )
        }
    }

    private func renderedSize(_ view: some View) -> CGSize {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        guard let image = renderer.cgImage else {
            return .zero
        }
        return CGSize(width: image.width, height: image.height)
    }
}
