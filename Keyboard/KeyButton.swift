import UIKit

final class KeyButton: UIControl {

    let keyDef:   KeyDef
    let isSpecial: Bool
    var onTap: (() -> Void)?

    private let label   = UILabel()
    private let script: KeyboardLayout.Script

    // Light-mode key shadow
    private let shadowLayer = CALayer()

    // Reusable haptic generator — create once, use many times
    private static let haptics = UIImpactFeedbackGenerator(style: .light)

    init(keyDef: KeyDef, isSpecial: Bool = false,
         script: KeyboardLayout.Script = .english) {
        self.keyDef    = keyDef
        self.isSpecial = isSpecial
        self.script    = script
        super.init(frame: .zero)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 5
        layer.cornerCurve  = .continuous

        // Shadow sublayer (only visible in light mode)
        shadowLayer.cornerRadius  = 5
        shadowLayer.shadowColor   = UIColor(white: 0, alpha: 1).cgColor
        shadowLayer.shadowOffset  = CGSize(width: 0, height: 1)
        shadowLayer.shadowRadius  = 0
        shadowLayer.shadowOpacity = 0
        layer.insertSublayer(shadowLayer, at: 0)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment             = .center
        label.baselineAdjustment        = .alignCenters
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor        = 0.55
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 2),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -2)
        ])

        applyTheme()
        configureLabel()
        addTarget(self, action: #selector(touchDown),  for: .touchDown)
        addTarget(self, action: #selector(touchUp),    for: [.touchUpInside, .touchUpOutside, .touchCancel])
        addTarget(self, action: #selector(handleTap),  for: .touchUpInside)
    }

    // MARK: - Label content

    private func configureLabel() {
        // Use override label if provided (e.g. "123" / "١٢٣" / "ABC")
        if let override = keyDef.label {
            label.text = override
            label.font = .systemFont(ofSize: 16, weight: .semibold)
            return
        }
        switch keyDef.kind {
        case .character(let s):
            label.text = s
            // Arabic / emoji use slightly larger font
            let isArabicChar = s.unicodeScalars.first.map {
                $0.value >= 0x0600 && $0.value <= 0x06FF
            } ?? false
            let isEmoji = s.unicodeScalars.first.map { $0.properties.isEmoji } ?? false
            if isEmoji {
                label.font = .systemFont(ofSize: 24)
            } else if isArabicChar {
                label.font = .systemFont(ofSize: 22)
            } else {
                label.font = .systemFont(ofSize: 22, weight: .light)
            }
        case .shift:
            label.text = "\u{21E7}"          // ⇧
            label.font = .systemFont(ofSize: 18, weight: .regular)
        case .backspace:
            label.text = "\u{232B}"          // ⌫
            label.font = .systemFont(ofSize: 18)
        case .keyboardMode:
            label.text = "123"
            label.font = .systemFont(ofSize: 15, weight: .semibold)
        case .symbolsMode:
            label.text = "#+=";
            label.font = .systemFont(ofSize: 15, weight: .semibold)
        case .space:
            label.text = script == .arabic ? "مسافة" : "space"
            label.font = .systemFont(ofSize: 15, weight: .light)
        case .return:
            label.text = script == .arabic ? "إرجاع" : "return"
            label.font = .systemFont(ofSize: 15, weight: .light)
        case .switchKeyboard:
            label.text = "\u{1F310}"         // 🌐
            label.font = .systemFont(ofSize: 19)
        case .switchScript:
            // Show next script symbol so user knows what they'll switch to
            switch script {
            case .english: label.text = "ع"
            case .arabic:  label.text = "😀"
            case .emoji:   label.text = "A"
            }
            label.font = .systemFont(ofSize: 18, weight: .semibold)
        case .emoji:
            label.text = "\u{1F60A}"
            label.font = .systemFont(ofSize: 22)
        }
    }

    // MARK: - Theme (matches iOS native keys)

    private func applyTheme() {
        if isSpecial {
            backgroundColor = UIColor { t in
                t.userInterfaceStyle == .dark
                    ? UIColor(red: 0.255, green: 0.255, blue: 0.275, alpha: 1)
                    : UIColor(red: 0.686, green: 0.698, blue: 0.725, alpha: 1)
            }
            label.textColor = UIColor { t in
                t.userInterfaceStyle == .dark ? .white : .black
            }
        } else {
            backgroundColor = UIColor { t in
                t.userInterfaceStyle == .dark
                    ? UIColor(red: 0.239, green: 0.239, blue: 0.259, alpha: 1)
                    : .white
            }
            label.textColor = UIColor { t in
                t.userInterfaceStyle == .dark ? .white : .black
            }
        }
    }

    // MARK: - Touch handling

    @objc private func touchDown() {
        Self.haptics.prepare()
        Self.haptics.impactOccurred()
        UIView.animate(withDuration: 0.03) {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            self.alpha = 0.4
        }
    }

    @objc private func touchUp() {
        UIView.animate(withDuration: 0.06, delay: 0, options: .allowUserInteraction) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }

    // MARK: - Shadow (light mode only)

    override func layoutSubviews() {
        super.layoutSubviews()
        shadowLayer.frame = bounds
        shadowLayer.backgroundColor = backgroundColor?.cgColor
        shadowLayer.shadowPath = UIBezierPath(
            roundedRect: bounds, cornerRadius: layer.cornerRadius
        ).cgPath
    }

    override func traitCollectionDidChange(_ prev: UITraitCollection?) {
        super.traitCollectionDidChange(prev)
        let dark = traitCollection.userInterfaceStyle == .dark
        shadowLayer.shadowOpacity = dark ? 0 : 0.35
        // refresh dynamic colors
        applyTheme()
        shadowLayer.backgroundColor = backgroundColor?.cgColor
    }

    // MARK: - Public helpers

    func setShiftActive(_ active: Bool) {
        guard case .shift = keyDef.kind else { return }
        backgroundColor = active
            ? UIColor { $0.userInterfaceStyle == .dark
                ? .white
                : UIColor(white: 0.28, alpha: 1) }
            : UIColor { t in
                t.userInterfaceStyle == .dark
                    ? UIColor(red: 0.255, green: 0.255, blue: 0.275, alpha: 1)
                    : UIColor(red: 0.686, green: 0.698, blue: 0.725, alpha: 1)
            }
        label.textColor = active
            ? UIColor { $0.userInterfaceStyle == .dark ? .black : .white }
            : UIColor { t in t.userInterfaceStyle == .dark ? .white : .black }
    }

    // MARK: - Tap

    @objc private func handleTap() {
        onTap?()
    }
}
