#if os(iOS)
    import Testing
    import UIKit
    @testable import PockyFoundation

    @MainActor
    struct PKYThemeBindingTests {
        @Test("Bindings wait for a visible update and release registrations when stopped")
        func bindingWaitsAndReleasesItsRegistration() {
            let view = UIView()
            let binding = PKYThemeBinding(owner: view, resolvesTheme: true)
            var events = 0
            binding.onUpdate = { _ in events += 1 }
            #expect(binding.resolvesTheme)
            #expect(binding.observes([]))
            #expect(!binding.observes([UITraitUserInterfaceStyle.self]))
            #expect(binding.registration != nil)
            binding.refresh()
            #expect(events == 0)
            #expect(binding.mountLink != nil)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            window.isHidden = false
            defer {
                binding.stop()
                window.isHidden = true
            }
            binding.performVisibleUpdate()
            #expect(events == 0)
            #expect(binding.mountLink != nil)
            window.addSubview(view)
            binding.refresh()
            #expect(events == 0)
            binding.performVisibleUpdate()
            #expect(events == 1)
            #expect(binding.mountLink == nil)
            binding.performVisibleUpdate()
            #expect(events == 1)
            binding.stop()
            #expect(binding.registration == nil)
            #expect(!binding.observes([]))
        }

        @Test("Stopping a detached binding cancels its pending visible update")
        func stoppingCancelsPendingVisibleUpdate() {
            let view = UIView()
            let binding = PKYThemeBinding(owner: view)
            var events = 0
            binding.onUpdate = { _ in events += 1 }
            binding.refresh()
            #expect(events == 0)
            #expect(binding.mountLink != nil)
            #expect(binding.registration != nil)
            binding.stop()
            #expect(binding.mountLink == nil)
            #expect(binding.registration == nil)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            window.isHidden = false
            defer { window.isHidden = true }
            window.addSubview(view)
            window.updateTraitsIfNeeded()
            binding.performVisibleUpdate()
            #expect(events == 0)
        }

        @Test("Many detached bindings receive no visible update callbacks while frames render")
        func detachedBindingsReceiveNoFrameCallbacks() async throws {
            let labels = (0 ..< 200).map { _ in UILabel() }
            var callbacks = 0
            let bindings = try labels.map { label in
                let binding = PKYThemeBinding(owner: label)
                binding.refresh()
                let link = try #require(binding.mountLink)
                link.addAction { _, _ in callbacks += 1 }
                return binding
            }
            let counter = FrameCounter()
            let displayLink = CADisplayLink(
                target: counter,
                selector: #selector(FrameCounter.tick)
            )
            displayLink.add(to: .main, forMode: .common)
            defer {
                displayLink.invalidate()
                for binding in bindings {
                    binding.stop()
                }
            }
            let deadline = ContinuousClock.now + .seconds(20)
            while counter.frames < 20, ContinuousClock.now < deadline {
                try await Task.sleep(for: .milliseconds(10))
            }
            #expect(counter.frames >= 20)
            #expect(callbacks == 0)
            withExtendedLifetime(labels) {}
        }
    }

    @MainActor
    private final class FrameCounter: NSObject {
        private(set) var frames = 0

        @objc func tick() {
            frames += 1
        }
    }
#endif
