import Foundation
import Testing
@testable import PockyFoundation
#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

struct PKYAppearanceTests {
    static func isolatedStore() throws -> UserDefaults {
        let suiteName = "PKYAppearanceTests.\(UUID().uuidString)"
        let store = try #require(UserDefaults(suiteName: suiteName))
        store.removePersistentDomain(forName: suiteName)
        return store
    }

    static func localizedTitles(localization: String) throws -> [String] {
        let path = try #require(Bundle.module.path(forResource: localization, ofType: "lproj"))
        let bundle = try #require(Bundle(path: path))
        let keys = [PKYAppearance.titleKey] + PKYAppearance.Mode.allCases.map(\.titleKey)
        return keys.map { bundle.localizedString(forKey: $0, value: nil, table: nil) }
    }

    @Test("Mode raw values match stored GalleryX values and system removes the platform override")
    func modeRawValuesAndPlatformAppearance() {
        #expect(PKYAppearance.Mode.allCases.map(\.rawValue) == ["system", "light", "dark"])
        #if os(iOS)
            #expect(PKYAppearance.Mode.system.userInterfaceStyle == .unspecified)
            #expect(PKYAppearance.Mode.light.userInterfaceStyle == .light)
            #expect(PKYAppearance.Mode.dark.userInterfaceStyle == .dark)
        #elseif os(macOS)
            #expect(PKYAppearance.Mode.system.nsAppearance == nil)
            #expect(PKYAppearance.Mode.light.nsAppearance?.name == .aqua)
            #expect(PKYAppearance.Mode.dark.nsAppearance?.name == .darkAqua)
        #endif
    }

    @Test("A missing value uses the configurable default mode")
    func missingValueUsesDefaultMode() throws {
        let store = try Self.isolatedStore()

        #expect(PKYAppearance(store: store).storedMode() == .system)
        #expect(PKYAppearance(store: store, defaultMode: .dark).storedMode() == .dark)
    }

    @Test("An unrecognized stored value falls back to the default mode")
    func unrecognizedStoredValueFallsBackToDefault() throws {
        let store = try Self.isolatedStore()
        store.set("sepia", forKey: "Pocky.appearance")

        #expect(PKYAppearance(store: store, defaultMode: .light).storedMode() == .light)
    }

    @Test("Saving keeps the selection itself under the injected key, including system")
    func savePersistsSelectionUnderCustomKey() throws {
        let store = try Self.isolatedStore()
        let appearance = PKYAppearance(store: store, key: "pref.appearance", defaultMode: .dark)

        appearance.save(.system)

        #expect(store.string(forKey: "pref.appearance") == "system")
        #expect(appearance.storedMode() == .system)
    }

    @Test("Appearance title and mode names ship in English and Simplified Chinese")
    func titlesAreLocalizedInEnglishAndSimplifiedChinese() throws {
        let english = try Self.localizedTitles(localization: "en")
        let chinese = try Self.localizedTitles(localization: "zh-Hans")

        #expect(english == ["Appearance", "System", "Light", "Dark"])
        #expect(chinese == ["外观", "跟随系统", "浅色", "深色"])
        #expect(PKYAppearance.title == english[0] || PKYAppearance.title == chinese[0])
        #expect(
            PKYAppearance.Mode.allCases.map(\.title) == Array(english.dropFirst())
                || PKYAppearance.Mode.allCases.map(\.title) == Array(chinese.dropFirst())
        )
    }
}
