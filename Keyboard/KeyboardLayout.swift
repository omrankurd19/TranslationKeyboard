import UIKit

enum KeyKind {
    case character(String)
    case shift
    case backspace
    case keyboardMode
    case symbolsMode
    case emoji
    case space
    case `return`
    case switchKeyboard
}

struct KeyDef {
    let kind: KeyKind
    let width: CGFloat
}

enum KeyboardLayout {
    enum Page { case letters, numbers, symbols }

    static func rows(for page: Page, shiftOn: Bool) -> [[KeyDef]] {
        switch page {
        case .letters: return letters(shifted: shiftOn)
        case .numbers: return numbers()
        case .symbols: return symbols()
        }
    }

    private static func letters(shifted: Bool) -> [[KeyDef]] {
        let row1 = "qwertyuiop".map { KeyDef(kind: char($0, shifted), width: 1) }
        let row2 = "asdfghjkl".map  { KeyDef(kind: char($0, shifted), width: 1) }
        let row3: [KeyDef] = [
            KeyDef(kind: .shift,     width: 1.5),
            KeyDef(kind: char("z", shifted), width: 1),
            KeyDef(kind: char("x", shifted), width: 1),
            KeyDef(kind: char("c", shifted), width: 1),
            KeyDef(kind: char("v", shifted), width: 1),
            KeyDef(kind: char("b", shifted), width: 1),
            KeyDef(kind: char("n", shifted), width: 1),
            KeyDef(kind: char("m", shifted), width: 1),
            KeyDef(kind: .backspace, width: 1.5)
        ]
        let row4: [KeyDef] = [
            KeyDef(kind: .keyboardMode,   width: 1.5),
            KeyDef(kind: .switchKeyboard, width: 1),
            KeyDef(kind: .space,          width: 5),
            KeyDef(kind: .return,         width: 1.5)
        ]
        return [row1, row2, row3, row4]
    }

    private static func numbers() -> [[KeyDef]] {
        let row1 = "1234567890".map { KeyDef(kind: .character(String($0)), width: 1) }
        let row2 = "-/:;()$&@\"".map { KeyDef(kind: .character(String($0)), width: 1) }
        let row3: [KeyDef] = [
            KeyDef(kind: .symbolsMode, width: 1.5),
            KeyDef(kind: .character("."), width: 1),
            KeyDef(kind: .character(","), width: 1),
            KeyDef(kind: .character("?"), width: 1),
            KeyDef(kind: .character("!"), width: 1),
            KeyDef(kind: .character("'"), width: 1),
            KeyDef(kind: .backspace, width: 1.5)
        ]
        let row4: [KeyDef] = [
            KeyDef(kind: .keyboardMode,   width: 1.5),
            KeyDef(kind: .switchKeyboard, width: 1),
            KeyDef(kind: .space,          width: 5),
            KeyDef(kind: .return,         width: 1.5)
        ]
        return [row1, row2, row3, row4]
    }

    private static func symbols() -> [[KeyDef]] {
        let row1 = "[]{}#%^*+=".map { KeyDef(kind: .character(String($0)), width: 1) }
        let row2 = "_~|<>".map { KeyDef(kind: .character(String($0)), width: 1) }
            + [KeyDef(kind: .character("€"), width: 1),
               KeyDef(kind: .character("£"), width: 1),
               KeyDef(kind: .character("¥"), width: 1),
               KeyDef(kind: .character("•"), width: 1)]
        let row3: [KeyDef] = [
            KeyDef(kind: .symbolsMode, width: 1.5),
            KeyDef(kind: .character("."), width: 1),
            KeyDef(kind: .character(","), width: 1),
            KeyDef(kind: .character("?"), width: 1),
            KeyDef(kind: .character("!"), width: 1),
            KeyDef(kind: .character("'"), width: 1),
            KeyDef(kind: .backspace, width: 1.5)
        ]
        let row4: [KeyDef] = [
            KeyDef(kind: .keyboardMode,   width: 1.5),
            KeyDef(kind: .switchKeyboard, width: 1),
            KeyDef(kind: .space,          width: 5),
            KeyDef(kind: .return,         width: 1.5)
        ]
        return [row1, row2, row3, row4]
    }

    private static func char(_ c: Character, _ shifted: Bool) -> KeyKind {
        .character(shifted ? String(c).uppercased() : String(c))
    }
}
