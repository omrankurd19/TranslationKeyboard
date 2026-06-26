import UIKit

final class TranslateBar: UIView {

    var onPickLanguage: (() -> Void)?
    var onTranslate:    (() -> Void)?

    enum State { case idle, translating, message(String) }

    // "Auto → Arabic ▾"
    private let langButton = UIButton(type: .system)

    // "Translate" pill button
    private let translateButton: UIButton = {
        let b = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title              = "Translate"
        cfg.baseForegroundColor = .white
        cfg.baseBackgroundColor = UIColor.systemBlue
        cfg.cornerStyle        = .capsule
        cfg.contentInsets      = NSDirectionalEdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14)
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var a = attr; a.font = .systemFont(ofSize: 15, weight: .semibold); return a
        }
        b.configuration = cfg
        return b
    }()

    // Divider line at bottom
    private let divider: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.separator
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.122, green: 0.122, blue: 0.133, alpha: 1)
                : UIColor(red: 0.949, green: 0.949, blue: 0.969, alpha: 1)
        }

        // Lang button — left side, "Auto → Arabic ▾"
        langButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        langButton.tintColor = UIColor { t in
            t.userInterfaceStyle == .dark ? .white : UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        }
        langButton.contentHorizontalAlignment = .left
        langButton.translatesAutoresizingMaskIntoConstraints = false
        langButton.addTarget(self, action: #selector(tapLang), for: .touchUpInside)
        addSubview(langButton)

        translateButton.translatesAutoresizingMaskIntoConstraints = false
        translateButton.addTarget(self, action: #selector(tapTranslate), for: .touchUpInside)
        addSubview(translateButton)

        addSubview(divider)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 46),

            langButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            langButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            langButton.trailingAnchor.constraint(lessThanOrEqualTo: translateButton.leadingAnchor, constant: -8),

            translateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            translateButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5)
        ])

        // Default label
        setLangLabel(target: "Arabic")
    }

    // MARK: - Public API

    /// Call this whenever the target language changes.
    func updateLanguage(name: String) {
        if name == Languages.autoDetect.name {
            setAutoLabel()
        } else {
            setLangLabel(target: name)
        }
    }

    private func setAutoLabel() {
        let attr = NSMutableAttributedString(string: "Auto  ↔  Auto-detect  ▾")
        attr.addAttribute(.foregroundColor, value: UIColor.secondaryLabel,
                          range: NSRange(location: 0, length: attr.length))
        langButton.setAttributedTitle(attr, for: .normal)
    }

    func setTranslateState(_ state: State) {
        switch state {
        case .idle:
            var cfg = translateButton.configuration ?? .filled()
            cfg.title = "Translate"
            cfg.baseBackgroundColor = .systemBlue
            translateButton.configuration = cfg
            translateButton.isEnabled = true

        case .translating:
            var cfg = translateButton.configuration ?? .filled()
            cfg.title = "···"
            translateButton.configuration = cfg
            translateButton.isEnabled = false

        case .message(let text):
            var cfg = translateButton.configuration ?? .filled()
            cfg.title = text
            cfg.baseBackgroundColor = .systemOrange
            translateButton.configuration = cfg
            translateButton.isEnabled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                self?.setTranslateState(.idle)
            }
        }
    }

    // MARK: - Private

    private func setLangLabel(target: String) {
        // "Auto  →  Arabic  ▾"
        let full = "Auto  →  \(target)  ▾"
        let attr = NSMutableAttributedString(string: full)

        // Color "Auto" grey
        if let autoRange = full.range(of: "Auto") {
            let ns = NSRange(autoRange, in: full)
            attr.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: ns)
        }
        // Color "→" grey
        if let arrowRange = full.range(of: "→") {
            let ns = NSRange(arrowRange, in: full)
            attr.addAttribute(.foregroundColor, value: UIColor.tertiaryLabel, range: ns)
        }
        // Color language name blue
        if let langRange = full.range(of: target) {
            let ns = NSRange(langRange, in: full)
            attr.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: ns)
        }
        langButton.setAttributedTitle(attr, for: .normal)
    }

    @objc private func tapLang()      { onPickLanguage?() }
    @objc private func tapTranslate() { onTranslate?()    }
}
