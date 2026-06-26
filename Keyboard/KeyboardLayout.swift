import UIKit

enum KeyKind {
    case character(String)
    case shift
    case backspace
    case keyboardMode   // toggles 123 / ABC
    case symbolsMode    // toggles #+= / 123
    case space
    case `return`
    case switchKeyboard // globe — advance to next system keyboard
    case switchScript   // switch between English / Arabic / Emoji inside this keyboard
    case emoji          // open emoji (kept for layout use)
}

struct KeyDef {
    let kind:  KeyKind
    let width: CGFloat   // relative unit
    var label: String?   // optional override label
}

enum KeyboardLayout {

    enum Page   { case letters, numbers, symbols }
    enum Script { case english, arabic, emoji }

    // MARK: - Public entry point

    static func rows(for page: Page, script: Script, shiftOn: Bool) -> [[KeyDef]] {
        switch page {
        case .letters:
            switch script {
            case .english: return englishLetters(shifted: shiftOn)
            case .arabic:  return arabicLetters()
            case .emoji:   return emojiPage()
            }
        case .numbers: return numbers(script: script)
        case .symbols: return symbols()
        }
    }

    // MARK: - English QWERTY

    private static func englishLetters(shifted: Bool) -> [[KeyDef]] {
        let row1 = "qwertyuiop".map { KeyDef(kind: char($0, shifted), width: 1) }
        let row2 = "asdfghjkl".map  { KeyDef(kind: char($0, shifted), width: 1) }
        let row3: [KeyDef] = [
            KeyDef(kind: .shift,              width: 1.5),
            KeyDef(kind: char("z", shifted),  width: 1),
            KeyDef(kind: char("x", shifted),  width: 1),
            KeyDef(kind: char("c", shifted),  width: 1),
            KeyDef(kind: char("v", shifted),  width: 1),
            KeyDef(kind: char("b", shifted),  width: 1),
            KeyDef(kind: char("n", shifted),  width: 1),
            KeyDef(kind: char("m", shifted),  width: 1),
            KeyDef(kind: .backspace,          width: 1.5)
        ]
        let row4 = bottomRow(modeLabel: "123")
        return [row1, row2, row3, row4]
    }

    // MARK: - Arabic keyboard (RTL layout, standard Arabic QWERTY mapping)

    private static func arabicLetters() -> [[KeyDef]] {
        // Standard Arabic keyboard row order (same finger positions as QWERTY)
        let row1chars = ["ض","ص","ث","ق","ف","غ","ع","ه","خ","ح","ج","د"]
        let row2chars = ["ش","س","ي","ب","ل","ا","ت","ن","م","ك","ط"]
        let row3chars = ["ئ","ء","ؤ","ر","لا","ى","ة","و","ز","ظ"]

        let row1 = row1chars.map { KeyDef(kind: .character($0), width: 1) }
        let row2 = row2chars.map { KeyDef(kind: .character($0), width: 1) }
        let row3: [KeyDef] = [KeyDef(kind: .shift, width: 1.5)]
            + row3chars.map { KeyDef(kind: .character($0), width: 1) }
            + [KeyDef(kind: .backspace, width: 1.5)]
        let row4 = bottomRow(modeLabel: "١٢٣")
        return [row1, row2, row3, row4]
    }

    // MARK: - Emoji page (3 rows of common emoji + bottom bar)

    private static func emojiPage() -> [[KeyDef]] {
        let row1 = ["😀","😂","😍","🥰","😎","🤔","😢","😡","🤣","👍"].map {
            KeyDef(kind: .character($0), width: 1)
        }
        let row2 = ["❤️","🔥","✨","🎉","👏","🙏","💪","🤝","👀","💯"].map {
            KeyDef(kind: .character($0), width: 1)
        }
        let row3 = ["🌍","🎵","🍕","☕","🚀","💡","📱","💬","🏆","🌟"].map {
            KeyDef(kind: .character($0), width: 1)
        }
        let row4 = bottomRow(modeLabel: "ABC")
        return [row1, row2, row3, row4]
    }

    // MARK: - Numbers

    private static func numbers(script: Script) -> [[KeyDef]] {
        let digits   = script == .arabic ? "١٢٣٤٥٦٧٨٩٠" : "1234567890"
        let row1 = digits.map { KeyDef(kind: .character(String($0)), width: 1) }
        let row2 = "-/:;()$&@\"".map { KeyDef(kind: .character(String($0)), width: 1) }
        let row3: [KeyDef] = [
            KeyDef(kind: .symbolsMode,       width: 1.5),
            KeyDef(kind: .character("."),    width: 1),
            KeyDef(kind: .character(","),    width: 1),
            KeyDef(kind: .character("?"),    width: 1),
            KeyDef(kind: .character("!"),    width: 1),
            KeyDef(kind: .character("'"),    width: 1),
            KeyDef(kind: .backspace,         width: 1.5)
        ]
        let row4 = bottomRow(modeLabel: "ABC")
        return [row1, row2, row3, row4]
    }

    // MARK: - Symbols

    private static func symbols() -> [[KeyDef]] {
        let row1 = "[]{}#%^*+=".map { KeyDef(kind: .character(String($0)), width: 1) }
        let row2 = "_~|<>€£¥•".map { KeyDef(kind: .character(String($0)), width: 1) }
        let row3: [KeyDef] = [
            KeyDef(kind: .symbolsMode,    width: 1.5),
            KeyDef(kind: .character("."), width: 1),
            KeyDef(kind: .character(","), width: 1),
            KeyDef(kind: .character("?"), width: 1),
            KeyDef(kind: .character("!"), width: 1),
            KeyDef(kind: .character("'"), width: 1),
            KeyDef(kind: .backspace,      width: 1.5)
        ]
        let row4 = bottomRow(modeLabel: "ABC")
        return [row1, row2, row3, row4]
    }

    // MARK: - Shared bottom row
    // Layout: [123/ABC] [🌐 globe] [space × 5] [return]
    private static func bottomRow(modeLabel: String) -> [KeyDef] {
        [
            KeyDef(kind: .keyboardMode,   width: 1.5, label: modeLabel),
            KeyDef(kind: .switchKeyboard, width: 1.2),
            KeyDef(kind: .switchScript,   width: 1.2),
            KeyDef(kind: .space,          width: 4.6),
            KeyDef(kind: .return,         width: 1.5)
        ]
    }

    // MARK: - Helpers

    private static func char(_ c: Character, _ shifted: Bool) -> KeyKind {
        .character(shifted ? String(c).uppercased() : String(c))
    }
}
