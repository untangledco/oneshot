import Foundation

let userAgentCurl = "curl/8.9.0"

let groq = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

enum model: String {
    case llama3 = "llama3-8b-8192"
    case llama3big = "llama3-70b-8192"
}

struct Message: Codable {
    let role: String
    let content: String
}

struct Completion: Codable {
    let messages: [Message]?
    let model: String
    let choices: [Choice]?
    let error: apiError?
}

struct apiError: Codable {
    let message: String
    let type: String
}

enum completionError: Error {
    case internalServerError(message: String)
    case unauthorized
    case unknown(message: String)
}

struct Choice: Codable {
    let message: Message
}

func complete(apiRoot: URL, key: String, prompt: Completion) async throws -> Completion {
    var req = URLRequest(url: apiRoot)
    req.httpMethod = "POST"
    // req.setValue(userAgentCurl, forHTTPHeaderField: "User-Agent")
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.setValue("Bearer "+key, forHTTPHeaderField: "Authorization")
    let body = try JSONEncoder().encode(prompt)
    let (data, resp) = try await URLSession.shared.upload(for: req, from: body)
    if let hresp = resp as? HTTPURLResponse {
        if hresp.statusCode == 401 {
            throw completionError.unauthorized
        }
    }
    let reply = try JSONDecoder().decode(Completion.self, from: data)
    if reply.error != nil {
        let err = reply.error
        switch err?.type {
        case "internal_server_error":
            throw completionError.internalServerError(message: err?.message ?? "internal server error")
        default:
            throw completionError.unknown(message: err?.message ?? "\(err?.type ?? "unknown error")")
        }
    }
    return reply
}
