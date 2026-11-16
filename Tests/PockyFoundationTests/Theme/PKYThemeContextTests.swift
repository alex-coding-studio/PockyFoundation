#if os(iOS)
    import Observation
    import PockyFoundation
    import SwiftUI
    import Testing
    import UIKit

    @MainActor
    struct PKYThemeContextTests {
        static func makeTheme(
            contentPrimary: UIColor,
            scaling: PKYTypographyTheme.Scaling = .fixed
        ) -> PKYTheme {
            PKYTheme(
                color: PKYColorThemeTests.makeColorTheme(contentPrimary: contentPrimary),
                typography: .system(scaling: scaling)
            )
        }

        @Test("S3-01/T01 Context activation atomically replaces the complete theme")
        func activationReplacesCurrentTheme() {
            let initial = Self.makeTheme(contentPrimary: .red)
            let replacement = Self.makeTheme(
                contentPrimary: .blue,
                scaling: .dynamic(maximum: .xxxLarge)
            )
            let context = PKYThemeContext(theme: initial)

            #expect(context.theme.color.content(.primary).isEqual(UIColor.red))

            context.activate(theme: replacement)

            #expect(context.theme.color.content(.primary).isEqual(UIColor.blue))
            guard case let .dynamic(maximum) = context.theme.typography.scaling else {
                Issue.record(
                    "Expected the complete replacement Theme to include dynamic Typography"
                )
                return
            }
            #expect(maximum == .xxxLarge)
        }

        @Test("S3-01/T02 Theme activation sends a scoped type-safe main-actor notification")
        func activationPostsScopedMainActorMessage() async {
            let context = PKYThemeContext(theme: Self.makeTheme(contentPrimary: .red))
            let replacement = Self.makeTheme(contentPrimary: .blue)

            await confirmation(expectedCount: 1) { received in
                let token = NotificationCenter.default.addObserver(
                    of: context,
                    for: .pkyThemeDidChange
                ) { _ in
                    #expect(context.theme.color.content(.primary).isEqual(UIColor.blue))
                    received()
                }

                context.activate(theme: replacement)
                withExtendedLifetime(token) {}
            }
        }

        @Test("S3-01/T03 Theme activation invalidates Swift Observation dependencies")
        func activationInvalidatesObservation() async {
            let context = PKYThemeContext(theme: Self.makeTheme(contentPrimary: .red))
            let replacement = Self.makeTheme(contentPrimary: .blue)

            await confirmation(expectedCount: 1) { changed in
                withObservationTracking {
                    _ = context.theme
                } onChange: {
                    changed()
                }

                context.activate(theme: replacement)
            }
        }

        @Test("S3-01/T04 The SwiftUI root injects the same context instance")
        func swiftUIRootModifierInjectsContext() async throws {
            let context = PKYThemeContext(theme: Self.makeTheme(contentPrimary: .label))
            let recorder = ThemeEnvironmentRecorder()
            let controller = UIHostingController(
                rootView: ThemeEnvironmentProbe(recorder: recorder).pkyTheme(context)
            )
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
            defer {
                window.isHidden = true
                window.rootViewController = nil
            }
            window.rootViewController = controller
            window.isHidden = false

            controller.view.layoutIfNeeded()

            for _ in 0 ..< 50 where recorder.context == nil {
                try await Task.sleep(for: .milliseconds(10))
            }

            #expect(recorder.context === context)
            #expect(recorder.dynamicTypeSize == .large)
        }

        @Test("S3-01/T05 The SwiftUI root clamps Dynamic Type to the explicit maximum")
        func swiftUIRootClampsDynamicTypeToMaximum() async throws {
            let context = PKYThemeContext(
                theme: Self.makeTheme(
                    contentPrimary: .label,
                    scaling: .dynamic(maximum: .xxxLarge)
                )
            )
            let recorder = ThemeEnvironmentRecorder()
            let controller = UIHostingController(
                rootView: ThemeEnvironmentProbe(recorder: recorder)
                    .pkyTheme(context)
                    .dynamicTypeSize(.accessibility5)
            )
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
            defer {
                window.isHidden = true
                window.rootViewController = nil
            }
            window.rootViewController = controller
            window.isHidden = false

            controller.view.layoutIfNeeded()

            for _ in 0 ..< 50 where recorder.dynamicTypeSize == nil {
                try await Task.sleep(for: .milliseconds(10))
            }

            #expect(recorder.dynamicTypeSize == .xxxLarge)
        }

        @Test(
            "S3-01/T06 Activating a different scaling policy updates the SwiftUI root environment"
        )
        func activationUpdatesSwiftUIDynamicTypePolicy() async throws {
            let context = PKYThemeContext(
                theme: Self.makeTheme(contentPrimary: .label, scaling: .fixed)
            )
            let recorder = ThemeEnvironmentRecorder()
            let controller = UIHostingController(
                rootView: ThemeEnvironmentProbe(recorder: recorder)
                    .pkyTheme(context)
                    .dynamicTypeSize(.accessibility5)
            )
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
            defer {
                window.isHidden = true
                window.rootViewController = nil
            }
            window.rootViewController = controller
            window.isHidden = false

            controller.view.layoutIfNeeded()

            for _ in 0 ..< 50 where recorder.dynamicTypeSize != .large {
                try await Task.sleep(for: .milliseconds(10))
            }
            #expect(recorder.dynamicTypeSize == .large)

            context.activate(
                theme: Self.makeTheme(
                    contentPrimary: .label,
                    scaling: .dynamic(maximum: .xxxLarge)
                )
            )

            for _ in 0 ..< 50 where recorder.dynamicTypeSize != .xxxLarge {
                try await Task.sleep(for: .milliseconds(10))
            }
            #expect(recorder.dynamicTypeSize == .xxxLarge)
        }
    }

    @MainActor
    private final class ThemeEnvironmentRecorder {
        var context: PKYThemeContext?
        var dynamicTypeSize: DynamicTypeSize?
    }

    private struct ThemeEnvironmentProbe: UIViewRepresentable {
        @Environment(PKYThemeContext.self) private var context
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        let recorder: ThemeEnvironmentRecorder

        func makeUIView(context _: Context) -> UIView {
            UIView()
        }

        func updateUIView(_: UIView, context _: Context) {
            recorder.context = context
            recorder.dynamicTypeSize = dynamicTypeSize
        }
    }
#endif
