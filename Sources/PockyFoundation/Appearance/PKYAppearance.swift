import Foundation

/// Stores the user's appearance choice and the mode used before one is saved.
///
/// Appearance is independent of the product theme. The app owns the settings entry;
/// the caller restores and saves the mode. `UserDefaults.standard` is the default store,
/// and an App Group store or an existing key can be injected.
public struct PKYAppearance {
    static let titleKey = "appearance.title"

    /// The localized appearance title for a settings row or menu.
    public static var title: String {
        String(localized: String.LocalizationValue(titleKey), bundle: .module)
    }

    /// The preference store that keeps the selection.
    public let store: UserDefaults

    /// The preference key that stores the ``Mode`` raw value.
    public let key: String

    /// The mode used when nothing is saved or the stored value is not recognized.
    public let defaultMode: Mode

    /// Configures where the appearance selection persists.
    ///
    /// - Parameters:
    ///   - store: The defaults that keep the selection, such as an App Group or an isolated test suite.
    ///   - key: The key holding the mode raw value; an existing app can keep its original key.
    ///   - defaultMode: The selection used when no valid mode is saved.
    public init(
        store: UserDefaults = .standard,
        key: String = "Pocky.appearance",
        defaultMode: Mode = .system
    ) {
        self.store = store
        self.key = key
        self.defaultMode = defaultMode
    }

    /// Returns the saved mode, or ``defaultMode`` when the stored value is missing or unrecognized.
    public func storedMode() -> Mode {
        store.string(forKey: key).flatMap(Mode.init(rawValue:)) ?? defaultMode
    }

    /// Saves the selection itself; `system` stays `system` instead of the currently resolved style.
    public func save(_ mode: Mode) {
        store.set(mode.rawValue, forKey: key)
    }
}
