#if os(iOS)
    @_spi(Pocky) import PockyFoundation
    import Testing
    import UIKit

    @MainActor
    struct PKYThemeBindingTests {
        @Test("SPI bindings wait for a visible update and release registrations when stopped")
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
    }
#endif
