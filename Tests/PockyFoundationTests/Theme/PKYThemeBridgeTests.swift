#if os(iOS)
    import PockyFoundation
    import SwiftUI
    import Testing
    import UIKit

    @MainActor
    struct PKYThemeBridgeTests {
        @Test("UIKit theme overrides reach SwiftUI without creating a context")
        func uiKitOverrideReachesEnvironment() async throws {
            let recorder = Recorder()
            let initial = PKYThemeTraitValue(theme: PKYThemeFallback.system)
            let replacement = PKYThemeTraitValue(theme: PKYThemeFallback.system)
            let controller = UIHostingController(rootView: Probe(recorder: recorder))
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
            window.traitOverrides.pkyTheme = initial
            window.rootViewController = controller
            window.isHidden = false
            defer { window.isHidden = true
                window.rootViewController = nil
            }
            controller.view.layoutIfNeeded()
            try await wait { recorder.snapshot == initial }
            #expect(recorder.context == nil)
            window.traitOverrides.pkyTheme = replacement
            controller.view.layoutIfNeeded()
            try await wait { recorder.snapshot == replacement }
            #expect(recorder.snapshot == replacement)
        }

        @Test("Context snapshots bridge to UIKit without replacing the native view")
        func contextInjectionBridgesToUIView() async throws {
            let recorder = Recorder()
            let context = PKYThemeContext(theme: PKYThemeFallback.system)
            let controller = UIHostingController(
                rootView: Probe(recorder: recorder).pkyTheme(context)
            )
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
            window.rootViewController = controller
            window.isHidden = false
            defer { window.isHidden = true
                window.rootViewController = nil
            }
            controller.view.layoutIfNeeded()
            try await wait { recorder.view?.traitCollection.pkyTheme == context.themeTraitValue }
            let original = recorder.view
            context.activate(theme: PKYThemeFallback.system)
            controller.view.layoutIfNeeded()
            try await wait { recorder.snapshot == context.themeTraitValue
                && recorder.view?.traitCollection.pkyTheme == context.themeTraitValue
            }
            #expect(recorder.context === context)
            #expect(recorder.view === original)
        }

        private func wait(_ condition: () -> Bool) async throws {
            let clock = ContinuousClock()
            let deadline = clock.now + .seconds(3)
            while !condition(), clock.now < deadline {
                try await Task.sleep(for: .milliseconds(10))
            }
            #expect(condition())
        }
    }

    @MainActor
    private final class Recorder {
        var snapshot: PKYThemeTraitValue?
        var context: PKYThemeContext?
        weak var view: UIView?
    }

    private struct Probe: UIViewRepresentable {
        @Environment(\.pkyTheme) private var snapshot
        @Environment(PKYThemeContext.self) private var themeContext: PKYThemeContext?

        let recorder: Recorder

        func makeUIView(context _: Context) -> UIView {
            let view = UIView()
            recorder.view = view
            return view
        }

        func updateUIView(_: UIView, context _: Context) {
            recorder.snapshot = snapshot
            recorder.context = themeContext
        }
    }
#endif
