#if os(iOS)
    import SwiftUI

    public extension View {
        /// Clips an elongated custom control or surface to a capsule that tracks its own size,
        /// suitable for tags and progress tracks.
        ///
        /// - Returns: A view clipped to a `Capsule`.
        func pkyClipCapsule() -> some View {
            clipShape(Capsule())
        }

        /// Clips a nested surface concentrically from container geometry; the system may resolve
        /// to square corners when far from a container corner.
        ///
        /// Use the minimum-radius overload when corners must remain rounded.
        ///
        /// - Returns: A view clipped by its container relationship.
        @available(iOS 26.0, *)
        func pkyClipConcentric() -> some View {
            clipShape(ConcentricRectangle())
        }

        /// Computes concentric corners from the container while enforcing a minimum corner radius
        /// required by the component.
        ///
        /// - Parameter minimum: A `PKYShape.Radius` role matching the surface purpose, or a local
        ///   minimum for a dedicated component.
        /// - Returns: A concentrically clipped view that preserves the minimum corner radius.
        @available(iOS 26.0, *)
        func pkyClipConcentric(minimum: CGFloat) -> some View {
            clipShape(
                ConcentricRectangle(
                    corners: .concentric(minimum: .fixed(minimum))
                )
            )
        }
    }
#endif
