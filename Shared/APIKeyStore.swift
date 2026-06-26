import Foundation

/// Stores the Gemini API key in shared UserDefaults (App Group).
/// We use UserDefaults (not Keychain) because TrollStore-signed apps don't
/// have a proper team signing identity, so Keychain access groups don't work.
/// On a jailbroken personal device this is acceptable.
enum APIKeyStore {

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: SharedConstants.appGroupID) ?? .standard
    }

    @discardableResult
    static func saveAPIKey(_ apiKey: String) -> Bool {
        defaults.set(apiKey, forKey: SharedConstants.apiKeyKeychainAccount)
        return true
    }

    static func loadAPIKey() -> String? {
        let v = defaults.string(forKey: SharedConstants.apiKeyKeychainAccount)
        return (v?.isEmpty == false) ? v : nil
    }

    @discardableResult
    static func deleteAPIKey() -> Bool {
        defaults.removeObject(forKey: SharedConstants.apiKeyKeychainAccount)
        return true
    }
}

// Backward-compatible typealias so existing call sites don't need changes yet.
typealias KeychainStore = APIKeyStore
