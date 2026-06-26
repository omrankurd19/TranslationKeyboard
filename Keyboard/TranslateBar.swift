import UIKit

final class TranslateBar: UIView {

    var onPickLanguage: (() -> Void)?
    var onTranslate:    (() -> Void)?

    private let langButton      = UIButton(type: .system)
    private let translateButton = UIButton(type: .system)

    enum State { case idle, translating, message(String) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.16, green: 0.16, blue: 0.17, alpha: 1)
                : UIColor(red: 0.93, green: 0.93, blue: 0.95, alpha: 1)
        }
        translatesAutoresizingMaskIntoConstraints = false

        langButton.setTitle("-> Arabic v", for: .normal)
        langButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        langButton.addTarget(self, action: #selector(tapLang), for: .touchUpInside)
        langButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(langButton)

        var config = UIButton.Configuration.filled()
        config.title = "Translate"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemBlue
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        config.cornerStyle = .capsule
        translateButton.configuration = config
        translateButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        translateButton.addTarget(self, action: #selector(tapTranslate), for: .touchUpInside)
        translateButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(translateButton)

        NSLayoutConstraint.activate([
            langButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            langButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            translateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            translateButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    func updateLanguage(name: String) {
        langButton.setTitle("-> \(name) v", for: .normal)
    }

    func setTranslateState(_ state: State) {
        switch state {
        case .idle:
            var config = translateButton.configuration ?? .filled()
            config.title = "Translate"
            config.baseBackgroundColor = .systemBlue
            translateButton.configuration = config
            translateButton.isEnabled = true
        case .translating:
            var config = translateButton.configuration ?? .filled()
            config.title = "..."
            translateButton.configuration = config
            translateButton.isEnabled = false
        case .message(let text):
            var config = translateButton.configuration ?? .filled()
            config.title = text
            config.baseBackgroundColor = .systemOrange
            translateButton.configuration = config
            translateButton.isEnabled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                self?.setTranslateState(.idle)
            }
        }
    }

    @objc private func tapLang()      { onPickLanguage?() }
    @objc private func tapTranslate() { onTranslate?()    }
}
