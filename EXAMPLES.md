# Ejemplos de Uso - Resend Swift SDK

Colección de ejemplos prácticos para casos de uso comunes.

## 📧 Ejemplos de Emails

### Email Simple

```swift
import Resend

let resend = ResendClient(apiKey: "re_your_api_key")

let email = ResendEmail(
    from: "hello@yourdomain.com",
    to: ["user@example.com"],
    subject: "Hello World",
    html: "<p>This is a test email</p>"
)

let response = try await resend.email.send(email: email)
print("Email sent with ID: \(response.id)")
```

### Email con CC y BCC

```swift
let email = ResendEmail(
    from: "notifications@yourdomain.com",
    to: ["primary@example.com"],
    subject: "Important Notice",
    bcc: ["archive@yourdomain.com"],
    cc: ["manager@yourdomain.com"],
    html: "<h1>Important Notice</h1><p>Please review...</p>"
)

try await resend.email.send(email: email)
```

### Email con Adjuntos

```swift
// Convertir archivo a Base64
let fileData = try Data(contentsOf: URL(fileURLWithPath: "invoice.pdf"))
let base64Content = fileData.base64EncodedString()

let attachment = EmailAttachment(
    content: base64Content,
    filename: "invoice.pdf"
)

let email = ResendEmail(
    from: "billing@yourdomain.com",
    to: ["customer@example.com"],
    subject: "Your Invoice",
    html: "<p>Please find your invoice attached.</p>",
    attachments: [attachment]
)

try await resend.email.send(email: email)
```

### Email con Headers Personalizados

```swift
let email = ResendEmail(
    from: "noreply@yourdomain.com",
    to: ["user@example.com"],
    subject: "Custom Headers Example",
    html: "<p>Email with custom headers</p>",
    headers: [
        "X-Entity-Ref-ID": "12345",
        "X-Priority": "1",
        "X-Custom-Header": "value"
    ]
)

try await resend.email.send(email: email)
```

### Email con Tags para Tracking

```swift
let email = ResendEmail(
    from: "marketing@yourdomain.com",
    to: ["subscriber@example.com"],
    subject: "Spring Sale!",
    html: "<h1>50% Off Everything!</h1>",
    tags: [
        EmailTag(name: "campaign", value: "spring_sale_2025"),
        EmailTag(name: "segment", value: "premium_customers"),
        EmailTag(name: "region", value: "us_west")
    ]
)

try await resend.email.send(email: email)
```

### Email Programado

```swift
// Primero enviar el email
let email = ResendEmail(
    from: "scheduler@yourdomain.com",
    to: ["user@example.com"],
    subject: "Scheduled Email",
    html: "<p>This will be sent later</p>"
)

let response = try await resend.email.send(email: email)

// Luego actualizar para programar
try await resend.email.update(
    id: response.id,
    scheduledAt: "2025-02-01T10:00:00Z"
)
```

### Cancelar Email Programado

```swift
let emailId = "email_123"
try await resend.email.cancel(id: emailId)
print("Scheduled email cancelled")
```

### Envío Batch de Emails

```swift
let emails = (1...50).map { i in
    ResendEmail(
        from: "batch@yourdomain.com",
        to: ["user\(i)@example.com"],
        subject: "Batch Email #\(i)",
        html: "<p>This is batch email number \(i)</p>",
        tags: [EmailTag(name: "batch", value: "january_2025")]
    )
}

let batchResponse = try await resend.email.sendBatch(emails: emails)

print("Successfully sent: \(batchResponse.data.count)")

if let errors = batchResponse.errors {
    print("Failed emails:")
    for error in errors {
        print("  Index \(error.index): \(error.message)")
    }
}
```

## 🌐 Ejemplos de Dominios

### Crear y Verificar Dominio

```swift
// Crear dominio
let domain = try await resend.domains.create(
    name: "mail.yourdomain.com",
    region: "us-east-1",
    customReturnPath: "bounce"
)

print("Domain created: \(domain.id)")
print("Add these DNS records:")
for record in domain.records ?? [] {
    print("  \(record.type): \(record.name) -> \(record.value)")
}

// Verificar después de configurar DNS
let verified = try await resend.domains.verify(id: domain.id)
print("Domain status: \(verified.status ?? "unknown")")
```

### Listar Todos los Dominios

```swift
let domains = try await resend.domains.list(limit: 50, after: nil, before: nil)

for domain in domains.data {
    print("\(domain.name) - Status: \(domain.status ?? "unknown")")
}

if domains.hasMore {
    print("There are more domains available")
}
```

### Configurar Tracking

```swift
let updated = try await resend.domains.update(
    id: "domain_id",
    clickTracking: true,
    openTracking: true,
    tls: "enforced"
)

print("Domain updated with tracking enabled")
```

### Eliminar Dominio

```swift
let deleted = try await resend.domains.delete(id: "domain_id")
print("Domain deleted: \(deleted.deleted)")
```

## 🔑 Ejemplos de API Keys

### Crear API Key con Permisos Específicos

```swift
// Full access key
let fullKey = try await resend.apiKeys.create(
    name: "Production Full Access",
    permission: "full_access",
    domainId: nil
)

print("API Key created: \(fullKey.token)")
print("Save this token securely!")

// Domain-specific sending key
let sendingKey = try await resend.apiKeys.create(
    name: "Domain Sender",
    permission: "sending_access",
    domainId: "domain_123"
)
```

### Rotar API Keys

```swift
// List existing keys
let keys = try await resend.apiKeys.list(limit: 100, after: nil, before: nil)

// Create new key
let newKey = try await resend.apiKeys.create(
    name: "Rotated Production Key",
    permission: "full_access",
    domainId: nil
)

// Update your app config with newKey.token
// Then delete old keys
for key in keys.data where key.name.contains("Old") {
    try await resend.apiKeys.delete(id: key.id)
}
```

## 👥 Ejemplos de Audiencias y Contactos

### Sistema Completo de Newsletter

```swift
// 1. Crear audiencia
let newsletter = try await resend.audiences.create(
    name: "Monthly Newsletter Subscribers"
)

print("Audience created: \(newsletter.id)")

// 2. Importar contactos
let contacts = [
    ("john@example.com", "John", "Doe"),
    ("jane@example.com", "Jane", "Smith"),
    ("bob@example.com", "Bob", "Johnson")
]

for (email, firstName, lastName) in contacts {
    let contact = try await resend.contacts.create(
        audienceId: newsletter.id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        unsubscribed: false
    )
    print("Added: \(contact.email)")
}

// 3. Listar todos los contactos
let allContacts = try await resend.contacts.list(
    audienceId: newsletter.id,
    limit: 50,
    after: nil,
    before: nil
)

print("Total contacts: \(allContacts.data.count)")
```

### Gestionar Suscripciones

```swift
// Suscribir usuario
let subscriber = try await resend.contacts.create(
    audienceId: "audience_id",
    email: "newuser@example.com",
    firstName: "New",
    lastName: "User",
    unsubscribed: false
)

// Desuscribir usuario
let unsubscribed = try await resend.contacts.update(
    audienceId: "audience_id",
    identifier: subscriber.email,
    firstName: nil,
    lastName: nil,
    unsubscribed: true
)

print("User unsubscribed: \(unsubscribed.email)")
```

### Actualizar Información de Contacto

```swift
let updated = try await resend.contacts.update(
    audienceId: "audience_id",
    identifier: "user@example.com",
    firstName: "UpdatedFirstName",
    lastName: "UpdatedLastName",
    unsubscribed: nil  // No cambiar estado de suscripción
)
```

### Eliminar Contacto

```swift
let deleted = try await resend.contacts.delete(
    audienceId: "audience_id",
    identifier: "user@example.com"
)

print("Contact deleted: \(deleted.deleted)")
```

## 📢 Ejemplos de Broadcasts

### Crear y Enviar Campaña

```swift
// 1. Crear broadcast
let campaign = try await resend.broadcasts.create(
    audienceId: "newsletter_audience",
    from: "newsletter@yourdomain.com",
    subject: "January 2025 Newsletter",
    replyTo: ["support@yourdomain.com"],
    html: """
        <h1>Welcome to January!</h1>
        <p>Hi {{{FIRST_NAME|there}}},</p>
        <p>Here are this month's updates...</p>
        <a href="{{{RESEND_UNSUBSCRIBE_URL}}}">Unsubscribe</a>
    """,
    text: "Welcome to January! Here are this month's updates...",
    name: "January Newsletter"
)

print("Campaign created: \(campaign.id)")

// 2. Enviar inmediatamente
let sent = try await resend.broadcasts.send(
    id: campaign.id,
    scheduledAt: nil
)

print("Campaign sent: \(sent.id)")
```

### Programar Campaña

```swift
let campaign = try await resend.broadcasts.create(
    audienceId: "audience_id",
    from: "marketing@yourdomain.com",
    subject: "Weekend Sale!",
    replyTo: nil,
    html: "<h1>50% OFF This Weekend!</h1>",
    text: nil,
    name: "Weekend Sale Campaign"
)

// Programar para el sábado a las 9am
let scheduled = try await resend.broadcasts.send(
    id: campaign.id,
    scheduledAt: "Saturday at 9am"
)

print("Campaign scheduled")
```

### Actualizar Borrador de Campaña

```swift
let updated = try await resend.broadcasts.update(
    id: "broadcast_id",
    audienceId: nil,  // No cambiar audiencia
    from: nil,  // No cambiar remitente
    subject: "Updated Subject Line",
    replyTo: nil,
    html: "<h1>Updated Content</h1>",
    text: nil,
    name: "Updated Campaign Name"
)
```

### Listar Campañas

```swift
let broadcasts = try await resend.broadcasts.list(
    limit: 20,
    after: nil,
    before: nil
)

for broadcast in broadcasts.data {
    print("\(broadcast.name ?? "Unnamed") - Status: \(broadcast.status ?? "unknown")")
}
```

## 🔄 Ejemplos con SwiftUI (iOS/macOS)

### View Model con Resend

```swift
import SwiftUI
import Resend

@MainActor
class EmailViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var message: String?
    @Published var emailSent = false

    private let resend: ResendClient

    init() {
        self.resend = ResendClient(apiKey: "re_your_api_key")
    }

    func sendWelcomeEmail(to email: String, name: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let email = ResendEmail(
                from: "welcome@yourdomain.com",
                to: [email],
                subject: "Welcome, \(name)!",
                html: """
                    <h1>Welcome to our app!</h1>
                    <p>Hi \(name),</p>
                    <p>Thanks for joining us.</p>
                """
            )

            let response = try await resend.email.send(email: email)
            message = "Email sent successfully!"
            emailSent = true
        } catch {
            message = "Failed to send email: \(error.localizedDescription)"
            emailSent = false
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = EmailViewModel()
    @State private var emailAddress = ""
    @State private var userName = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Name", text: $userName)
                .textFieldStyle(.roundedBorder)

            TextField("Email", text: $emailAddress)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)

            Button("Send Welcome Email") {
                Task {
                    await viewModel.sendWelcomeEmail(
                        to: emailAddress,
                        name: userName
                    )
                }
            }
            .disabled(viewModel.isLoading || emailAddress.isEmpty)

            if viewModel.isLoading {
                ProgressView()
            }

            if let message = viewModel.message {
                Text(message)
                    .foregroundColor(viewModel.emailSent ? .green : .red)
            }
        }
        .padding()
    }
}
```

### Servicio de Email Singleton

```swift
import Resend

final class EmailService {
    static let shared = EmailService()

    private let resend: ResendClient

    private init() {
        guard let apiKey = ProcessInfo.processInfo.environment["RESEND_API_KEY"] else {
            fatalError("RESEND_API_KEY not set in environment")
        }
        self.resend = ResendClient(apiKey: apiKey)
    }

    func sendPasswordReset(to email: String, token: String) async throws {
        let resetURL = "https://yourapp.com/reset?token=\(token)"

        let email = ResendEmail(
            from: "security@yourdomain.com",
            to: [email],
            subject: "Password Reset Request",
            html: """
                <h2>Reset Your Password</h2>
                <p>Click the link below to reset your password:</p>
                <a href="\(resetURL)">Reset Password</a>
                <p>This link expires in 1 hour.</p>
            """
        )

        _ = try await resend.email.send(email: email)
    }

    func sendVerificationEmail(to email: String, code: String) async throws {
        let email = ResendEmail(
            from: "verify@yourdomain.com",
            to: [email],
            subject: "Verify Your Email - Code: \(code)",
            html: """
                <h1>Verify Your Email</h1>
                <p>Your verification code is:</p>
                <h2 style="font-size: 32px; letter-spacing: 5px;">\(code)</h2>
                <p>This code expires in 10 minutes.</p>
            """
        )

        _ = try await resend.email.send(email: email)
    }
}

// Uso:
Task {
    try await EmailService.shared.sendPasswordReset(
        to: "user@example.com",
        token: "abc123"
    )
}
```

## 🧪 Ejemplos de Testing

### Mock HTTP Client

```swift
import XCTest
@testable import ResendKit
@testable import ResendCore

class MockHTTPClient: HTTPClientProtocol {
    var shouldFail = false
    var response: HTTPResponse?

    func execute(_ request: HTTPRequest) async throws -> HTTPResponse {
        if shouldFail {
            throw URLError(.badServerResponse)
        }

        return response ?? HTTPResponse(
            statusCode: 200,
            headers: [:],
            body: """
            {"id": "test_email_id"}
            """.data(using: .utf8)
        )
    }
}

class ResendClientTests: XCTestCase {
    func testSendEmail() async throws {
        let mockClient = MockHTTPClient()
        let resend = ResendClient(
            apiKey: "test_key",
            httpClient: mockClient
        )

        let email = ResendEmail(
            from: "test@test.com",
            to: ["user@test.com"],
            subject: "Test",
            html: "<p>Test</p>"
        )

        let response = try await resend.email.send(email: email)
        XCTAssertEqual(response.id, "test_email_id")
    }

    func testSendEmailFailure() async {
        let mockClient = MockHTTPClient()
        mockClient.shouldFail = true

        let resend = ResendClient(
            apiKey: "test_key",
            httpClient: mockClient
        )

        let email = ResendEmail(
            from: "test@test.com",
            to: ["user@test.com"],
            subject: "Test",
            html: "<p>Test</p>"
        )

        do {
            _ = try await resend.email.send(email: email)
            XCTFail("Should have thrown an error")
        } catch {
            // Expected
        }
    }
}
```

## 🎯 Best Practices

### 1. Usar Variables de Entorno

```swift
// ❌ Mal - API key hardcodeada
let resend = ResendClient(apiKey: "re_abc123...")

// ✅ Bien - API key desde environment
guard let apiKey = ProcessInfo.processInfo.environment["RESEND_API_KEY"] else {
    fatalError("RESEND_API_KEY not configured")
}
let resend = ResendClient(apiKey: apiKey)
```

### 2. Manejo de Errores Completo

```swift
do {
    let response = try await resend.email.send(email: email)
    print("Success: \(response.id)")
} catch let error as ResendRetrieveError {
    // Error específico de la API de Resend
    print("API Error [\(error.statusCode)]: \(error.message)")

    switch error.statusCode {
    case 401:
        // API key inválida
        break
    case 429:
        // Rate limit excedido
        break
    default:
        break
    }
} catch {
    // Otros errores (network, etc)
    print("Unexpected error: \(error)")
}
```

### 3. Retry Logic

```swift
func sendEmailWithRetry(
    email: ResendEmail,
    maxRetries: Int = 3
) async throws -> ResendEmailResponse {
    var lastError: Error?

    for attempt in 1...maxRetries {
        do {
            return try await resend.email.send(email: email)
        } catch {
            lastError = error

            if attempt < maxRetries {
                // Exponential backoff
                let delay = UInt64(pow(2.0, Double(attempt)))
                try await Task.sleep(nanoseconds: delay * 1_000_000_000)
            }
        }
    }

    throw lastError ?? URLError(.unknown)
}
```

---

¿Necesitas más ejemplos? ¡Abre un issue en GitHub!
