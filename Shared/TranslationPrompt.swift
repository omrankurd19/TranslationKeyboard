import Foundation

enum TranslationPrompt {
    static func userPrompt(text: String, targetLanguageName: String) -> String {
        """
        Translate the text below into \(targetLanguageName). \
        Detect the source language automatically. \
        Output ONLY the translation. Do not add quotes, explanations, notes, \
        or the original text.

        Text:
        \"\"\"
        \(text)
        \"\"\"
        """
    }
}
