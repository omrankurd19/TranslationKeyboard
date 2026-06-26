import SwiftUI

struct SettingsView: View {
    @State private var apiKey        = ""
    @State private var selectedModel = SharedConstants.defaultModelID
    @State private var defaultLang: Language = Languages.all.first!
    @State private var status        = ""
    @State private var isTesting     = false

    private let settings = AppGroupSettings()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gemini API Key")) {
                    SecureField("AIzaSy… or AQ.…", text: $apiKey)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Button("Save Key") { saveKey() }
                        .disabled(apiKey.isEmpty)
                }

                Section(header: Text("Default Target Language")) {
                    Picker("Language", selection: $defaultLang) {
                        ForEach(Languages.all, id: \.code) { lang in
                            Text(lang.name).tag(lang)
                        }
                    }
                    .onChange(of: defaultLang) { settings.defaultTargetLanguage = $0 }
                }

                Section(header: Text("Model"), footer: Text("Free tier supported on all models.").font(.caption)) {
                    Picker("Model", selection: $selectedModel) {
                        ForEach(SharedConstants.availableModels, id: \.id) { model in
                            Text(model.name).tag(model.id)
                        }
                    }
                    .onChange(of: selectedModel) { settings.modelID = $0 }
                }

                Section {
                    Button(isTesting ? "Testing…" : "Test API Key") { testKey() }
                        .disabled(isTesting || apiKey.isEmpty)
                    if !status.isEmpty {
                        Text(status)
                            .font(.caption)
                            .foregroundColor(status.hasPrefix("v") ? .green : .red)
                    }
                }

                Section(header: Text("Diagnostics")) {
                    HStack {
                        Text("Shared storage")
                        Spacer()
                        Text(settings.isAppGroupAvailable ? "OK ✓" : "NOT LINKED ✗")
                            .foregroundColor(settings.isAppGroupAvailable ? .green : .red)
                    }
                    HStack {
                        Text("Key stored")
                        Spacer()
                        Text((KeychainStore.loadAPIKey()?.isEmpty == false) ? "Yes ✓" : "No ✗")
                            .foregroundColor((KeychainStore.loadAPIKey()?.isEmpty == false) ? .green : .red)
                    }
                    Text("Both must be green for the keyboard to read your key.")
                        .font(.caption).foregroundColor(.secondary)
                }

                Section(header: Text("How to use")) {
                    Text("1. Save your API key above.\n2. Settings > General > Keyboard > Add New Keyboard > Translate.\n3. Enable Allow Full Access.\n4. Type, pick a language, press Translate.")
                        .font(.caption).foregroundColor(.secondary)
                }
            }
            .navigationTitle("Translation Keyboard")
            .onAppear(perform: load)
        }
    }

    private func load() {
        apiKey         = KeychainStore.loadAPIKey() ?? ""
        selectedModel  = settings.modelID
        defaultLang    = settings.defaultTargetLanguage
    }

    private func saveKey() {
        let ok = KeychainStore.saveAPIKey(apiKey)
        // Force write to disk immediately
        UserDefaults(suiteName: SharedConstants.appGroupID)?.synchronize()
        status = ok ? "v Key saved" : "Could not save key"
    }

    private func testKey() {
        isTesting = true; status = "Testing..."
        GeminiService(modelID: selectedModel, apiKey: apiKey)
            .translate(text: "hello",
                       targetLanguage: Language(code: "es", name: "Spanish")) { result in
                isTesting = false
                switch result {
                case .success(let out): status = "v Works! 'hello' = \(out)"
                case .failure(let e):   status = e.localizedDescription
                }
            }
    }
}
