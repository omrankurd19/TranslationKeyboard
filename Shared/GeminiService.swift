import Foundation

final class GeminiService {

    enum GeminiError: Error, LocalizedError {
        case noAPIKey
        case badResponse(String)
        case noContent
        case http(Int, String)

        var errorDescription: String? {
            switch self {
            case .noAPIKey:              return "No API key set. Open the Settings app."
            case .badResponse(let m):    return "Bad response: \(m)"
            case .noContent:             return "Empty translation from Gemini."
            case .http(let code, let b): return "HTTP \(code): \(b)"
            }
        }
    }

    private let session: URLSession
    private let modelID: String
    private let apiKey: String

    init(modelID: String, apiKey: String, session: URLSession = .shared) {
        self.modelID = modelID
        self.apiKey  = apiKey
        self.session = session
    }

    /// Translate `text` into `targetLanguage`, using dialect-aware prompting.
    func translate(text: String,
                   targetLanguage: Language,
                   completion: @escaping (Result<String, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            deliver(completion, .failure(GeminiError.noAPIKey)); return
        }
        let prompt = TranslationPrompt.userPrompt(text: text, targetLanguage: targetLanguage)
        let urlStr = "https://generativelanguage.googleapis.com/v1beta/models/\(modelID):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlStr) else {
            deliver(completion, .failure(GeminiError.badResponse("invalid url"))); return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 20
        let body: [String: Any] = [
            "contents": [["role": "user", "parts": [["text": prompt]]]],
            "generationConfig": ["temperature": 0.2]
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        session.dataTask(with: req) { [weak self] data, response, error in
            guard let self = self else { return }
            if let e = error { self.deliver(completion, .failure(e)); return }
            self.handleResponse(data: data, response: response, completion: completion)
        }.resume()
    }

    private func handleResponse(data: Data?, response: URLResponse?,
                                completion: @escaping (Result<String, Error>) -> Void) {
        guard let http = response as? HTTPURLResponse else {
            deliver(completion, .failure(GeminiError.badResponse("no http response"))); return
        }
        let bodyStr = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
        guard (200...299).contains(http.statusCode) else {
            deliver(completion, .failure(GeminiError.http(http.statusCode, bodyStr))); return
        }
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let first = candidates.first,
              let content = first["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let textPart = parts.first,
              var text = textPart["text"] as? String else {
            if let fb = (try? JSONSerialization.jsonObject(
                            with: data ?? Data()) as? [String: Any])?["promptFeedback"]
                            as? [String: Any],
               let reason = fb["blockReason"] as? String {
                deliver(completion, .failure(GeminiError.badResponse("blocked: \(reason)"))); return
            }
            deliver(completion, .failure(GeminiError.noContent)); return
        }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("\"") && text.hasSuffix("\"") && text.count >= 2 {
            text = String(text.dropFirst().dropLast())
        }
        deliver(completion, .success(text))
    }

    private func deliver(_ completion: @escaping (Result<String, Error>) -> Void,
                         _ result: Result<String, Error>) {
        DispatchQueue.main.async { completion(result) }
    }
}
