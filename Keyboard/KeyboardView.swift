import UIKit

final class KeyboardView: UIView {

    var onKey: ((KeyDef) -> Void)?

    private var page: KeyboardLayout.Page = .letters
    private enum ShiftState { case off, on, capsLocked }
    private var shiftState: ShiftState = .off
    private var rowStacks: [UIStackView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.12, blue: 0.13, alpha: 1)
                : UIColor(red: 0.85, green: 0.85, blue: 0.87, alpha: 1)
        }
        buildRows()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildRows() {
        let container = UIStackView()
        container.axis         = .vertical
        container.spacing      = 6
        container.distribution = .fillEqually
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3)
        ])
        for _ in 0..<4 {
            let row = UIStackView()
            row.axis         = .horizontal
            row.spacing      = 6
            row.distribution = .fill
            row.alignment    = .fill
            container.addArrangedSubview(row)
            rowStacks.append(row)
        }
        render()
    }

    private func render() {
        let shifted = shiftState != .off
        let rows = KeyboardLayout.rows(for: page, shiftOn: shifted)
        for (i, row) in rows.enumerated() {
            guard i < rowStacks.count else { continue }
            let stack = rowStacks[i]
            stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            for key in row {
                let btn = KeyButton(keyDef: key, isSpecial: isSpecialKey(key))
                btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
                btn.widthAnchor.constraint(greaterThanOrEqualToConstant: 28).isActive = true
                stack.addArrangedSubview(btn)
                if case .shift = key.kind { btn.setShiftActive(shiftState == .capsLocked) }
                btn.onTap = { [weak self] in self?.handle(key) }
            }
            // Proportional widths via compressionResistance ratio trick
            let totalWeight = row.reduce(0.0) { $0 + $1.width }
            let btns = stack.arrangedSubviews.compactMap { $0 as? KeyButton }
            guard let first = btns.first else { continue }
            for (idx, btn) in btns.enumerated() {
                if idx == 0 { continue }
                let ratio = row[idx].width / row[0].width
                btn.widthAnchor.constraint(equalTo: first.widthAnchor,
                                           multiplier: ratio).isActive = true
                _ = totalWeight // suppress warning
            }
        }
    }

    private func isSpecialKey(_ def: KeyDef) -> Bool {
        switch def.kind {
        case .character: return false
        default:         return true
        }
    }

    private func handle(_ def: KeyDef) {
        switch def.kind {
        case .shift:
            switch shiftState {
            case .off:        shiftState = .on
            case .on:         shiftState = .capsLocked
            case .capsLocked: shiftState = .off
            }
            render()
        case .keyboardMode:
            page = (page == .letters) ? .numbers : .letters
            render()
        case .symbolsMode:
            page = (page == .symbols) ? .numbers : .symbols
            render()
        case .character:
            if shiftState == .on { shiftState = .off; render() }
        default:
            break
        }
        onKey?(def)
    }
}
