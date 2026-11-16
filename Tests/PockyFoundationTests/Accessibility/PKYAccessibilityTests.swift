#if os(iOS)
    import PockyFoundation
    import Testing
    import UIKit

    @MainActor
    struct PKYAccessibilityTests {
        private enum FeatureID: String, PKYAccessibilityIdentifier {
            case delete = "test.feature.delete"
        }

        private struct FullDescription: PKYAccessibility {
            let identifier = "test.feature.photo"
            let label: String? = "Photo"
            let hint: String? = "Opens the photo"
            let value: String? = "Selected"
            let traits: UIAccessibilityTraits? = [.button, .selected]
        }

        private enum BareDescription: PKYAccessibility {
            case delete

            var identifier: String {
                FeatureID.delete.identifier
            }
        }

        @Test("String-backed enums supply identifiers and pkyA11y only changes the identifier")
        func stringEnumSuppliesIdentifier() {
            let action = UIAction(title: "Delete") { _ in }
            let identified: UIAction = action.pkyA11y(FeatureID.delete)

            #expect(identified === action)
            #expect(action.accessibilityIdentifier == "test.feature.delete")
        }

        @Test(
            "Full descriptions replace all fields, clear reused text, and preserve unspecified traits"
        )
        func fullDescriptionReplacesEveryField() {
            let view = UIView()
            let configured: UIView = view.pkyA11y(FullDescription())

            #expect(configured === view)
            #expect(view.accessibilityIdentifier == "test.feature.photo")
            #expect(view.accessibilityLabel == "Photo")
            #expect(view.accessibilityHint == "Opens the photo")
            #expect(view.accessibilityValue == "Selected")
            #expect(view.accessibilityTraits == [.button, .selected])

            view.pkyA11y(BareDescription.delete)

            #expect(view.accessibilityIdentifier == "test.feature.delete")
            #expect(view.accessibilityLabel == nil)
            #expect(view.accessibilityHint == nil)
            #expect(view.accessibilityValue == nil)
            #expect(view.accessibilityTraits == [.button, .selected])
        }
    }
#endif
