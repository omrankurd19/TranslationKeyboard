import Foundation

enum SharedConstants {
    static let appGroupID              = "group.com.translk.app"
    static let keychainAccessGroup     = "com.translk.app"
    static let apiKeyKeychainAccount   = "gemini_api_key"
    static let defaultLanguageKey      = "default_language_code"
    static let lastTargetLanguageKey   = "last_target_language_code"
    static let modelIDKey              = "model_id"
    static let defaultModelID          = "gemini-2.5-flash"

    static let availableModels: [(id: String, name: String)] = [
        ("gemini-3.5-flash",      "Gemini 3.5 Flash"),
        ("gemini-3-flash",        "Gemini 3 Flash"),
        ("gemini-3.1-flash-lite", "Gemini 3.1 Flash Lite"),
        ("gemini-2.5-flash",      "Gemini 2.5 Flash"),
        ("gemini-2.5-flash-lite", "Gemini 2.5 Flash Lite"),
    ]
}
