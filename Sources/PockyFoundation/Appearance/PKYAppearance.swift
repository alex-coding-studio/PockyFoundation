import Foundation

public struct PKYAppearance {
    static let titleKey = "appearance.title"

    public static var title: String {
        String(localized: String.LocalizationValue(titleKey), bundle: .module)
    }

    public let store: UserDefaults

    public let key: String

    public let defaultMode: Mode

    public init(
        store: UserDefaults = .standard,
        key: String = "Pocky.appearance",
        defaultMode: Mode = .system
    ) {
        self.store = store
        self.key = key
        self.defaultMode = defaultMode
    }

    public func storedMode() -> Mode {
        store.string(forKey: key).flatMap(Mode.init(rawValue:)) ?? defaultMode
    }

    public func save(_ mode: Mode) {
        store.set(mode.rawValue, forKey: key)
    }
}
