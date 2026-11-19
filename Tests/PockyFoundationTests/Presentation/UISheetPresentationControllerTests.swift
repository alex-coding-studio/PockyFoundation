#if os(iOS)
    import PockyFoundation
    import Testing
    import UIKit

    @MainActor
    struct UISheetPresentationControllerTests {
        static let colorTheme = PKYColorTheme.system(
            accent: .init(primary: .systemBlue, secondary: .systemTeal, onAccent: .white)
        )

        @Test(
            "S4-01/T01 Standard style applies detents, a grabber, and compact-height edge attachment"
        )
        func appliesStandardPresentation() throws {
            let sheet = try makeSheet()
            sheet.pkyApplyStandardStyle(detents: [.medium(), .large()])
            #expect(sheet.detents.map(\.identifier) == [.medium, .large])
            #expect(sheet.prefersGrabberVisible)
            #expect(sheet.prefersEdgeAttachedInCompactHeight)
            #if compiler(>=6.2.1)
                if #available(iOS 26.1, *) {
                    #expect(sheet.backgroundEffect is UIColorEffect)
                }
            #endif
        }

        @Test(
            "S4-01/T02 Full-width landscape keeps the caller's edge attachment",
            arguments: [false, true]
        )
        func fullWidthPreservesEdgeAttachment(_ attached: Bool) throws {
            let sheet = try makeSheet()
            sheet.prefersEdgeAttachedInCompactHeight = attached
            sheet.pkyApplyStandardStyle(detents: [.large()], fillsWidthInLandscape: true)
            #expect(sheet.prefersEdgeAttachedInCompactHeight == attached)
        }

        @Test("S4-01/T03 Paper background alone keeps sheet geometry and grabber")
        func paperBackgroundPreservesPresentation() throws {
            let sheet = try makeSheet()
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.prefersEdgeAttachedInCompactHeight = false
            sheet.pkyUsePaperBackground()
            #expect(sheet.detents.map(\.identifier) == [.medium])
            #expect(!sheet.prefersGrabberVisible)
            #expect(!sheet.prefersEdgeAttachedInCompactHeight)
        }

        #if compiler(>=6.2.1)
            @available(iOS 26.1, *)
            @Test(
                "S4-01/T04 Paper background is reapplied when the presented controller's theme changes"
            )
            func paperBackgroundFollowsPresentedTheme() throws {
                let controller = UIViewController()
                controller.modalPresentationStyle = .pageSheet
                let sheet = try #require(controller.sheetPresentationController)
                let initial = PKYThemeTraitValue(theme: PKYThemeFallback.system)
                let replacement = PKYThemeTraitValue(theme: PKYTheme(
                    color: Self.colorTheme,
                    typography: .system(scaling: .fixed)
                ))
                controller.traitOverrides.pkyTheme = initial
                controller.updateTraitsIfNeeded()
                sheet.pkyApplyStandardStyle(detents: [.large()])
                sheet.pkyUsePaperBackground()
                let first = try #require(sheet.backgroundEffect as? UIColorEffect)
                controller.traitOverrides.pkyTheme = replacement
                controller.updateTraitsIfNeeded()
                let second = try #require(sheet.backgroundEffect as? UIColorEffect)
                #expect(second !== first)
                #expect(sheet.detents.map(\.identifier) == [.large])
            }
        #endif

        private func makeSheet() throws -> UISheetPresentationController {
            let controller = UIViewController()
            controller.modalPresentationStyle = .pageSheet
            return try #require(controller.sheetPresentationController)
        }
    }
#endif
