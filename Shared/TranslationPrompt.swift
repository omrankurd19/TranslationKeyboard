import Foundation

enum TranslationPrompt {

    static func userPrompt(text: String, targetLanguage: Language) -> String {
        let langInstruction = dialectInstruction(for: targetLanguage)
        return """
        \(langInstruction)\
        Output ONLY the translation — no quotes, no explanations, no original text.

        Text:
        \"\"\"
        \(text)
        \"\"\"
        """
    }

    // MARK: - Per-language instructions

    private static func dialectInstruction(for language: Language) -> String {
        switch language.code {

        case "auto":
            return "Detect the language of the text below and translate it into the most appropriate language. " +
                   "If the text is in English translate to Arabic, if Arabic translate to English. "

        case "ku-bad":
            // Badini Kurdish — Arabic script, Zakho/Duhok dialect
            return """
            Translate the text below into Kurdish Badini dialect \
            (the dialect spoken in Zakho and Duhok, northern Iraq). \
            Write the translation using Arabic script (not Latin). \
            Use vocabulary and pronunciation typical of the Zakho/Duhok Badini dialect. \
            Detect the source language automatically. \

            """

        case "ku-ckb":
            return """
            Translate the text below into Central Kurdish (Sorani), \
            written in Arabic-Kurdish script as used in Sulaymaniyah and Erbil. \
            Detect the source language automatically. \

            """

        case "ku":
            return """
            Translate the text below into Northern Kurdish (Kurmanji), \
            written in Latin script. \
            Detect the source language automatically. \

            """

        default:
            return "Translate the text below into \(language.name). " +
                   "Detect the source language automatically. "
        }
    }
}
