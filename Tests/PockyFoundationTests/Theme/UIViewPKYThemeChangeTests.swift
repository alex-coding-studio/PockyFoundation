#if os(iOS)
    import Testing
    import UIKit
    @testable import PockyFoundation

    @MainActor
    struct UIViewPKYThemeChangeTests {
        static func makeThemes() -> (first: PKYThemeTraitValue, second: PKYThemeTraitValue) {
            let first = PKYTheme(
                color: .system(accent: .init(
                    primary: .systemBlue,
                    secondary: .systemTeal,
                    onAccent: .white
                )),
                typography: .system(scaling: .fixed)
            )
            let second = PKYTheme(
                color: .system(accent: .init(
                    primary: .systemRed,
                    secondary: .systemOrange,
                    onAccent: .black
                )),
                typography: .system(scaling: .dynamic(maximum: .xxxLarge))
            )
            return (PKYThemeTraitValue(theme: first), PKYThemeTraitValue(theme: second))
        }

        static func makeWindow(theme: PKYThemeTraitValue) -> UIWindow {
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
            window.traitOverrides.pkyTheme = theme
            window.traitOverrides.preferredContentSizeCategory = .extraExtraExtraLarge
            window.isHidden = false
            return window
        }

        @Test("Theme change callbacks run on mount and theme swaps, and the latest callback wins")
        func themeChangeCallbackFollowsSwapsAndReplacesEarlierCallbacks() throws {
            let themes = Self.makeThemes()
            let view = UIView()
            var stale = 0
            // Swift 6.2 crashes on these calls with untyped parameters or inside other closures.
            view.pkyOnThemeChange { (_: UIView) in stale += 1 }
            let original = try #require(pkyThemeChangeRegistration(on: view))
            var seen = [PKYThemeTraitValue?]()
            view.pkyOnThemeChange { (changed: UIView) in
                seen.append(changed.traitCollection.pkyTheme)
            }
            #expect(
                (pkyThemeChangeRegistration(on: view) as AnyObject?) === (original as AnyObject)
            )
            view.pkyOnThemeChange(observing: [HostTraitA.self]) { (_: UIView) in stale += 1 }
            let widened = try #require(pkyThemeChangeRegistration(on: view))
            #expect((widened as AnyObject?) !== (original as AnyObject))
            view.pkyOnThemeChange { (changed: UIView) in
                seen.append(changed.traitCollection.pkyTheme)
            }
            let window = Self.makeWindow(theme: themes.first)
            defer { window.isHidden = true }
            window.addSubview(view)
            window.updateTraitsIfNeeded()
            #expect(seen.last == themes.first)
            window.traitOverrides.pkyTheme = themes.second
            window.updateTraitsIfNeeded()
            #expect(seen.last == themes.second)
            #expect(stale == 0)
            let count = seen.count
            view.pkyCancelThemeChange()
            #expect(pkyThemeChangeRegistration(on: view) == nil)
            window.traitOverrides.pkyTheme = themes.first
            window.updateTraitsIfNeeded()
            #expect(seen.count == count)
        }

        @Test("Each theme binding responds only to the extra traits it observes")
        func themeBindingsRespondOnlyToTheirObservedTraits() {
            let root = UIView()
            let first = UIView()
            let second = UILabel()
            let third = UIView()
            root.addSubview(first)
            root.addSubview(second)
            root.addSubview(third)
            var firstValues = [Int]()
            var secondValues = [Int]()
            first.pkyOnThemeChange(observing: [HostTraitA.self]) { (view: UIView) in
                firstValues.append(view.traitCollection[HostTraitA.self])
            }
            second.pkyAttributedText(observing: [HostTraitB.self]) { traits in
                secondValues.append(traits[HostTraitB.self])
                return NSAttributedString(string: "Observed")
            }
            let border = UIColor { traits in traits[HostTraitA.self] == 0 ? .black : .white }
            third.pkyLayerBorderColor = border
            third.pkyLayerColorTraits = [HostTraitA.self]
            let window = Self.makeWindow(theme: Self.makeThemes().first)
            defer { window.isHidden = true }
            window.addSubview(root)
            window.updateTraitsIfNeeded()
            #expect(firstValues.last == 0)
            #expect(secondValues.last == 0)
            let initialBorder = third.layer.borderColor
            #expect(initialBorder == border.resolvedColor(with: third.traitCollection).cgColor)
            let firstCount = firstValues.count
            let secondCount = secondValues.count
            root.traitOverrides[HostTraitA.self] = 7
            root.updateTraitsIfNeeded()
            #expect(firstValues.count == firstCount + 1)
            #expect(firstValues.last == 7)
            #expect(secondValues.count == secondCount)
            let updatedBorder = border.resolvedColor(with: third.traitCollection).cgColor
            #expect(third.layer.borderColor == updatedBorder)
            #expect(updatedBorder != initialBorder)
            root.traitOverrides[HostTraitB.self] = 3
            root.updateTraitsIfNeeded()
            #expect(firstValues.count == firstCount + 1)
            #expect(secondValues.last == 3)
        }

        @Test(
            "Layer colors follow theme swaps through one registration and keep their last value when cleared"
        )
        func layerColorsFollowThemeSwaps() throws {
            let themes = Self.makeThemes()
            let view = UIView()
            view.pkyLayerBorderColor = .pkyAccent(.primary)
            let registration = try #require(pkyLayerColorRegistration(on: view))
            view.pkyLayerShadowColor = .pkyAccent(.secondary)
            view.pkyLayerBackgroundColor = .pkyOnAccent
            view.pkyLayerBorderColor = .pkyAccent(.primary)
            #expect(
                (pkyLayerColorRegistration(on: view) as AnyObject?) === (registration as AnyObject)
            )
            let window = Self.makeWindow(theme: themes.first)
            defer { window.isHidden = true }
            window.addSubview(view)
            window.updateTraitsIfNeeded()
            let first = layerColors(of: view)
            #expect(first == expectedLayerColors(for: view))
            window.traitOverrides.pkyTheme = themes.second
            window.updateTraitsIfNeeded()
            let second = layerColors(of: view)
            #expect(second == expectedLayerColors(for: view))
            #expect(zip(first, second).allSatisfy { $0 != $1 })
            view.pkyLayerBorderColor = nil
            view.pkyLayerShadowColor = nil
            view.pkyLayerBackgroundColor = nil
            #expect(view.pkyLayerBorderColor == nil)
            #expect(pkyLayerColorRegistration(on: view) == nil)
            window.traitOverrides.pkyTheme = themes.first
            window.updateTraitsIfNeeded()
            #expect(layerColors(of: view) == second)
        }

        @Test("Theme change callbacks and layer color bindings do not retain their view")
        func themeChangeBindingsReleaseTheirView() {
            weak var view: UIView?
            autoreleasepool {
                let value = UIView()
                installLayoutCallback(on: value)
                value.pkyLayerBorderColor = .pkySeparator(.standard)
                view = value
            }
            #expect(view == nil)
        }

        private func installLayoutCallback(on view: UIView) {
            view.pkyOnThemeChange { (changed: UIView) in changed.setNeedsLayout() }
        }

        private func layerColors(of view: UIView) -> [CGColor?] {
            [view.layer.borderColor, view.layer.shadowColor, view.layer.backgroundColor]
        }

        private func expectedLayerColors(for view: UIView) -> [CGColor?] {
            [UIColor.pkyAccent(.primary), .pkyAccent(.secondary), .pkyOnAccent].map { color in
                color.resolvedColor(with: view.traitCollection).cgColor
            }
        }
    }

    private struct HostTraitA: UITraitDefinition {
        static let defaultValue = 0
    }

    private struct HostTraitB: UITraitDefinition {
        static let defaultValue = 0
    }
#endif
