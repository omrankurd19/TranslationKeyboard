import Foundation

final class AppGroupSettings {
    private let defaults: UserDefaults

    init() {
        self.defaults = UserDefaults(suiteName: SharedConstants.appGroupID) ?? .standard
    }

    /// True when the shared App Group container is actually available.
    var isAppGroupAvailable: Bool {
        UserDefaults(suiteName: SharedConstants.appGroupID) != nil
    }

    var defaultTargetLanguage: Language {
        get {
            let code = defaults.string(forKey: SharedConstants.defaultLanguageKey) ?? "ar"
            return Languages.find(code: code) ?? Languages.all.first!
        }
        set { defaults.set(newValue.code, forKey: SharedConstants.defaultLanguageKey) }
    }

    var lastTargetLanguage: Language {
        get {
            let code = defaults.string(forKey: SharedConstants.lastTargetLanguageKey)
                ?? defaultTargetLanguage.code
            return Languages.find(code: code) ?? defaultTargetLanguage
        }
        set { defaults.set(newValue.code, forKey: SharedConstants.lastTargetLanguageKey) }
    }

    var modelID: String {
        get { defaults.string(forKey: SharedConstants.modelIDKey) ?? SharedConstants.defaultModelID }
        set { defaults.set(newValue, forKey: SharedConstants.modelIDKey) }
    }
}
