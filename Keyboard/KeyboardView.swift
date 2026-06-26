import UIKit

final class KeyboardView: UIView {

    var onKey: ((KeyDef) -> Void)?

    // Current state
    private var page:       KeyboardLayout.Page   = .letters
    private var script:     KeyboardLayout.Script = .english
    private enum ShiftState { case off, on, capsLocked }
    private var shiftState: ShiftState = .off

    private var rowStacks: [UIStackView] = []
    private let container = UIStackView()

    // iPhone native keyboard metrics
    private let keyHeight:    CGFloat = 42
    private let rowSpacing:   CGFloat = 12
    private let sideMargin:   CGFloat = 3
    private let topPad:       CGFloat = 10
    private let bottomPad:    CGFloat = 4

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.107, green: 0.107, blue: 0.118, alpha: 1)
                : UIColor(red: 0.847, green: 0.851, blue: 0.867, alpha: 1)
        }
        buildContainer()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Build skeleton

    private func buildContainer() {
        container.axis         = .vertical
        container.spacing      = rowSpacing
        container.distribution = .fill
        container.alignment    = .fill
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor, constant: topPad),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomPad),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: sideMargin),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -sideMargin)
        ])
        render()
    }

    // MARK: - Render rows

    func render() {
        container.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rowStacks.removeAll()

        let shifted = shiftState != .off
        let rows = KeyboardLayout.rows(for: page, script: script, shiftOn: shifted)

        for row in rows {
            let stack = UIStackView()
            stack.axis         = .horizontal
            stack.spacing      = 6
            stack.distribution = .fill
            stack.alignment    = .fill
            container.addArrangedSubview(stack)
            rowStacks.append(stack)

            // Fixed height for every row
            stack.heightAnchor.constraint(equalToConstant: keyHeight).isActive = true

            for key in row {
                let isSpecial: Bool
                switch key.kind {
                case .character: isSpecial = false
                default:         isSpecial = true
                }
                let btn = KeyButton(keyDef: key, isSpecial: isSpecial, script: script)
                btn.translatesAutoresizingMaskIntoConstraints = false
                if case .shift = key.kind { btn.setShiftActive(shiftState == .capsLocked) }
                btn.onTap = { [weak self] in self?.handle(key) }
                stack.addArrangedSubview(btn)
            }

            // Proportional widths — anchor all to the first key
            let btns = stack.arrangedSubviews.compactMap { $0 as? KeyButton }
            guard let first = btns.first else { continue }
            for (idx, btn) in btns.enumerated() {
                if idx == 0 { continue }
                let ratio = rows[rowStacks.count - 1][idx].width
                           / rows[rowStacks.count - 1][0].width
                btn.widthAnchor.constraint(equalTo: first.widthAnchor,
                                           multiplier: ratio).isActive = true
            }
        }
    }

    // MARK: - Handle key events

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
            if page == .letters {
                page = .numbers
            } else {
                page = .letters
                shiftState = .off
            }
            render()

        case .symbolsMode:
            page = (page == .symbols) ? .numbers : .symbols
            render()

        case .switchScript:
            switch script {
            case .english: script = .arabic
            case .arabic:  script = .emoji
            case .emoji:   script = .english
            }
            page = .letters
            shiftState = .off
            render()

        case .character:
            // Auto-shift off after one character
            if shiftState == .on { shiftState = .off; render() }

        default:
            break
        }

        onKey?(def)
    }
}
