#if os(iOS)
    import PockyFoundation
    import Testing
    import UIKit

    @MainActor
    struct UIAccessibilityIdentificationTests {
        @Test("Chained identifiers preserve object identity and concrete types")
        func identifiesUIKitObjectsWithoutChangingTheirTypes() {
            let action = UIAction(title: "Action") { _ in }
            let identifiedAction: UIAction = action.pkyA11yID("action")
            #expect(identifiedAction === action)
            #expect(action.accessibilityIdentifier == "action")

            let menu = UIMenu(children: [action])
            let identifiedMenu: UIMenu = menu.pkyA11yID("menu")
            #expect(identifiedMenu === menu)
            #expect(menu.accessibilityIdentifier == "menu")

            let alert = UIAlertAction(title: "Confirm", style: .default)
            let identifiedAlert: UIAlertAction = alert.pkyA11yID("alert")
            #expect(identifiedAlert === alert)
            #expect(alert.accessibilityIdentifier == "alert")

            let button = UIButton()
            let identifiedButton: UIButton = button.pkyA11yID("button")
            #expect(identifiedButton === button)
            #expect(button.accessibilityIdentifier == "button")

            let item = UIBarButtonItem()
            let identifiedItem: UIBarButtonItem = item.pkyA11yID("item")
            #expect(identifiedItem === item)
            #expect(item.accessibilityIdentifier == "item")
            #expect(item.pkyA11yID("replacement").accessibilityIdentifier == "replacement")

            let clearedItem: UIBarButtonItem = item.pkyA11yID(nil)
            #expect(clearedItem === item)
            #expect(item.accessibilityIdentifier == nil)
        }
    }
#endif
