import UIKit

final class KeyboardViewController: UIInputViewController {

    private let settings      = AppGroupSettings()
    private var gemini:        GeminiService?
    private var targetLanguage = Language(code: "ar", name: "Arabic")

    private let toolbar       = TranslateBar()
    private let keyboardView  = KeyboardView()
    private var pickerOverlay: LanguagePickerView?

    // Characters inserted this keyboard session (used for delete-replace on translate).
    private var typedThisSession = 0

    // Hold timer for rapid backspace.
    private var backspaceTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        targetLanguage   = settings.lastTargetLanguage
        toolbar.updateLanguage(name: targetLanguage.name)
        let key          = KeychainStore.loadAPIKey() ?? ""
        gemini           = GeminiService(modelID: settings.modelID, apiKey: key)
    }

    private func setupViews() {
        let root = UIStackView()
        root.axis         = .vertical
        root.spacing      = 0
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.topAnchor),
            root.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        toolbar.onPickLanguage = { [weak self] in self?.showPicker() }
        toolbar.onTranslate    = { [weak self] in self?.translate()   }
        root.addArrangedSubview(toolbar)
        keyboardView.onKey = { [weak self] def in self?.handleKey(def) }
        root.addArrangedSubview(keyboardView)
    }

    // MARK: - Keys

    private func handleKey(_ def: KeyDef) {
        let proxy = textDocumentProxy
        switch def.kind {
        case .character(let s):
            proxy.insertText(s)
            typedThisSession += s.count
        case .space:
            proxy.insertText(" ")
            typedThisSession += 1
        case .return:
            proxy.insertText("\n")
            typedThisSession = 0   // new line = new session
        case .backspace:
            proxy.deleteBackward()
            if typedThisSession > 0 { typedThisSession -= 1 }
        case .switchKeyboard:
            advanceToNextInputMode()
        default:
            break   // shift/page changes handled inside KeyboardView
        }
    }

    // MARK: - Language Picker

    private func showPicker() {
        let overlay = LanguagePickerView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.onSelect = { [weak self] lang in
            guard let self = self else { return }
            self.targetLanguage            = lang
            self.settings.lastTargetLanguage = lang
            self.toolbar.updateLanguage(name: lang.name)
            self.hidePicker()
        }
        overlay.onClose = { [weak self] in self?.hidePicker() }
        view.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        pickerOverlay = overlay
    }

    private func hidePicker() {
        pickerOverlay?.removeFromSuperview()
        pickerOverlay = nil
    }

    // MARK: - Translate

    private func translate() {
        guard let gemini = gemini else {
            toolbar.setTranslateState(.message("Set API key in Settings app"))
            return
        }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let text   = currentLine(from: before)
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            toolbar.setTranslateState(.message("Type something first"))
            return
        }
        toolbar.setTranslateState(.translating)
        gemini.translate(text: text, targetLanguageName: targetLanguage.name) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let translated):
                self.replaceTypedText(with: translated)
                self.toolbar.setTranslateState(.idle)
            case .failure(let error):
                self.toolbar.setTranslateState(.message(error.localizedDescription))
            }
        }
    }

    private func currentLine(from text: String) -> String {
        if let nl = text.lastIndex(of: "\n") {
            return String(text[text.index(after: nl)...])
        }
        return text
    }

    private func replaceTypedText(with translation: String) {
        let proxy = textDocumentProxy
        for _ in 0..<typedThisSession { proxy.deleteBackward() }
        typedThisSession = 0
        proxy.insertText(translation)
        typedThisSession = translation.count
    }
}
