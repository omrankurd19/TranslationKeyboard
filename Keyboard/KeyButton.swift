import UIKit

final class KeyButton: UIControl {

    private let label = UILabel()
    let keyDef: KeyDef
    let isSpecial: Bool
    var onTap: (() -> Void)?

    init(keyDef: KeyDef, isSpecial: Bool = false) {
        self.keyDef    = keyDef
        self.isSpecial = isSpecial
        super.init(frame: .zero)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        layer.cornerRadius = 6
        layer.cornerCurve  = .continuous
        translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment         = .center
        label.baselineAdjustment    = .alignCenters
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor    = 0.6
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1)
        ])
        applyTheme()
        configureTitle()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    private func configureTitle() {
        switch keyDef.kind {
        case .character(let s):
            label.text = s
            label.font = .systemFont(ofSize: 22, weight: .light)
        case .shift:
            label.text = "\u{21E7}"
            label.font = .systemFont(ofSize: 20)
        case .backspace:
            label.text = "\u{232B}"
            label.font = .systemFont(ofSize: 20)
        case .keyboardMode:
            label.text = "123"
            label.font = .systemFont(ofSize: 16, weight: .semibold)
        case .symbolsMode:
            label.text = "#+=";
            label.font = .systemFont(ofSize: 16, weight: .semibold)
        case .emoji:
            label.text = "\u{1F60A}"
            label.font = .systemFont(ofSize: 22)
        case .space:
            label.text = "space"
            label.font = .systemFont(ofSize: 16, weight: .light)
        case .return:
            label.text = "return"
            label.font = .systemFont(ofSize: 16, weight: .light)
        case .switchKeyboard:
            label.text = "\u{1F310}"
            label.font = .systemFont(ofSize: 20)
        }
    }

    private func applyTheme() {
        if isSpecial {
            backgroundColor = UIColor { t in
                t.userInterfaceStyle == .dark
                    ? UIColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1)
                    : UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1)
            }
            label.textColor = .white
        } else {
            backgroundColor = UIColor { t in
                t.userInterfaceStyle == .dark
                    ? UIColor(red: 0.18, green: 0.18, blue: 0.20, alpha: 1)
                    : .white
            }
            label.textColor = UIColor { t in
                t.userInterfaceStyle == .dark ? .white : .black
            }
        }
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = CGSize(width: 0, height: 1)
        layer.shadowRadius  = 0
        layer.shadowOpacity = 0
    }

    override func traitCollectionDidChange(_ prev: UITraitCollection?) {
        super.traitCollectionDidChange(prev)
        layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.25 : 0
    }

    func refresh(shifted: Bool) {
        if case .character(let s) = keyDef.kind {
            label.text = shifted ? s.uppercased() : s.lowercased()
        }
    }

    func setShiftActive(_ active: Bool) {
        guard case .shift = keyDef.kind else { return }
        backgroundColor = active
            ? UIColor { $0.userInterfaceStyle == .dark ? .white : UIColor(white: 0.3, alpha: 1) }
            : UIColor { t in
                t.userInterfaceStyle == .dark
                    ? UIColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1)
                    : UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1)
            }
        label.textColor = active
            ? UIColor { $0.userInterfaceStyle == .dark ? .black : .white }
            : .white
    }

    @objc private func handleTap() {
        // Haptics require Allow Full Access in keyboard extensions; guard silently.
        if UIApplication.shared.isProtectedDataAvailable {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            // Attempt anyway — works when full access is granted, silently skipped if not.
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }
        onTap?()
    }
}
