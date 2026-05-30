import Foundation
import Hummingbird
import ResendCore
import ResendKit
import ResendHummingbird

guard let apiKey = ProcessInfo.processInfo.environment["RESEND_API_KEY"], !apiKey.isEmpty else {
    fatalError("RESEND_API_KEY environment variable is required")
}
let fromEmail = ProcessInfo.processInfo.environment["FROM_EMAIL"] ?? "hello@swiftzone.dev"
let port = ProcessInfo.processInfo.environment["PORT"].flatMap(Int.init) ?? 3000

var router = Router()
var app = Application(router: router)
app.configuration.address = .hostname("0.0.0.0", port: port)

app.resend.initialize(apiKey: apiKey)
let resend = app.resend.client

// MARK: - POST /send — Send a simple email
router.post("send") { _, _ -> String in
    let email = ResendEmail(
        from: fromEmail,
        to: [fromEmail],
        subject: "Hello from Hummingbird + Resend",
        html: "<strong>Sent via Hummingbird server!</strong>"
    )
    do {
        let response = try await resend.email.send(email: email)
        return "Sent: \(response.id)"
    } catch {
        throw HTTPError(.internalServerError, message: "\(error)")
    }
}

// MARK: - GET /emails — List recent emails
router.get("emails") { _, _ -> String in
    do {
        let list = try await resend.email.list(limit: 5, after: nil, before: nil)
        let items = list.data.map { "  \($0.id ?? "?") - \($0.subject)" }.joined(separator: "\n")
        return "Recent emails:\n\(items)"
    } catch {
        throw HTTPError(.internalServerError, message: "\(error)")
    }
}

// MARK: - GET /domains — List verified domains
router.get("domains") { _, _ -> String in
    do {
        let list = try await resend.domains.list(limit: 10, after: nil, before: nil)
        let items = list.data.map { "  \($0.name) [\($0.status ?? "unknown")]" }.joined(separator: "\n")
        return "Domains:\n\(items)"
    } catch {
        throw HTTPError(.internalServerError, message: "\(error)")
    }
}

// MARK: - GET /health — Health check
router.get("health") { _, _ -> HTTPResponse.Status in
    return .ok
}

print("🚀 Hummingbird + Resend server starting on http://localhost:\(port)")
print("   POST /send    — Send an email")
print("   GET  /emails  — List recent emails")
print("   GET  /domains — List domains")
print("   GET  /health  — Health check")

try await app.runService()
