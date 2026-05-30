# Resend Swift SDK

[![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-blue.svg)](https://swift.org)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![SwiftLint](https://img.shields.io/badge/SwiftLint-passing-brightgreen.svg)](https://github.com/realm/SwiftLint)

A modern, type-safe Swift SDK for the [Resend](https://resend.com) email API with full platform support.

## Features

- ✅ **Complete API Coverage** — All Resend API endpoints implemented
- ✅ **Multi-Platform** — iOS, macOS, tvOS, watchOS, Mac Catalyst, visionOS, and Linux
- ✅ **Type-Safe** — Fully typed Swift interfaces with async/await
- ✅ **Modular Architecture** — Use only what you need
- ✅ **Vapor Integration** — First-class support for server-side Swift
- ✅ **Automatic Retry** — Configurable exponential backoff with jitter
- ✅ **Request Logging** — Optional swift-log integration
- ✅ **Cursor Pagination** — AsyncSequence-based `listAll()` on every resource
- ✅ **Webhook Verification** — Svix-compatible HMAC-SHA256 signature validation
- ✅ **Zero Dependencies** — Core package has no external dependencies

## Architecture

This package is organized into four modules:

### ResendCore
Core models and protocols with no dependencies. Contains all data models, request/response types, and protocol definitions.

```swift
import ResendCore
```

### ResendKit
URLSession-based HTTP client for iOS, macOS, and Linux. Complete implementation of the Resend API.

```swift
import ResendKit

let resend = ResendClient(apiKey: "re_your_api_key")
```

### ResendVapor
Vapor framework integration for server-side Swift applications.

```swift
import ResendVapor

app.resend.initialize(apiKey: "re_your_api_key")
```

### Resend
Convenience module that re-exports ResendCore and ResendKit.

```swift
import Resend
```

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Resend.git", from: "1.0.0")
]
```

Then add the appropriate module to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Resend", package: "Resend"),        // For iOS/macOS apps
        // or
        .product(name: "ResendVapor", package: "Resend"),   // For Vapor apps
    ]
)
```

## Quick Start

```swift
import Resend

let resend = ResendClient(apiKey: "re_your_api_key")

let email = ResendEmail(
    from: "onboarding@yourdomain.com",
    to: ["user@example.com"],
    subject: "Welcome!",
    html: "<h1>Welcome!</h1><p>Thanks for signing up.</p>"
)

do {
    let response = try await resend.email.send(email: email)
    print("Email sent! ID: \(response.id)")
} catch {
    print("Failed to send email: \(error)")
}
```

### With Vapor

```swift
import Vapor
import ResendVapor

func configure(_ app: Application) throws {
    app.resend.initialize(apiKey: "re_your_api_key")
}

func routes(_ app: Application) throws {
    app.post("send-email") { req async throws -> String in
        let email = ResendEmail(
            from: "noreply@yourdomain.com",
            to: ["user@example.com"],
            subject: "Hello from Vapor!",
            html: "<p>This email was sent from a Vapor app.</p>"
        )
        let response = try await req.resend.email.send(email: email)
        return "Email sent with ID: \(response.id)"
    }
}
```

## Advanced Features

### Automatic Retry with Exponential Backoff

Configure automatic retries for transient failures and rate limits:

```swift
let resend = ResendClient(
    apiKey: "re_your_api_key",
    retry: RetryConfiguration(
        maxRetries: 3,
        baseDelay: 1.0,
        maxDelay: 30.0,
        enableJitter: true,
        retryableStatusCodes: [429, 502, 503, 504]
    )
)
// Retries on 429/5xx and network errors with exponential backoff + jitter
```

### Request/Response Logging

Integrate with swift-log for observability:

```swift
import Logging

let logger = Logger(label: "resend")
let resend = ResendClient(apiKey: "re_your_api_key", logger: logger)
// Logs every request (method + URL), response (status + timing), and errors
```

### Cursor Pagination

Every list endpoint supports `listAll()` which returns an `AsyncSequence`:

```swift
let domains = resend.domains.listAll(limit: 10)

for try await domain in domains {
    print("Domain: \(domain.name)")
}

// Or use the iterator directly:
var iter = resend.domains.listAll().makeAsyncIterator()
while let domain = try await iter.next() {
    print("Domain: \(domain.name)")
}
```

### Webhook Signature Verification

Verify incoming webhooks using the Svix signing scheme:

```swift
do {
    let valid = try WebhookSignature.verify(
        payload: rawBody,                          // Raw request body as String
        id: req.headers["svix-id"] ?? "",
        timestamp: req.headers["svix-timestamp"] ?? "",
        signatureHeader: req.headers["svix-signature"] ?? "",
        secret: "whsec_your_signing_secret",       // From Resend dashboard
        tolerance: 300                              // Replay protection window (seconds)
    )
    // valid == true — process the webhook
} catch {
    // Invalid or expired — reject with 400
}
```

### Manage Webhooks via API

```swift
// Create a webhook
let webhook = try await resend.webhooks.create(
    endpoint: "https://example.com/handler",
    events: ["email.sent", "email.bounced"]
)

// List all webhooks
let list = try await resend.webhooks.list(limit: nil, after: nil, before: nil)

// Update a webhook
try await resend.webhooks.update(
    id: webhook.id,
    endpoint: "https://updated.com/handler",
    events: nil,
    disabled: true
)

// Delete a webhook
try await resend.webhooks.delete(id: webhook.id)
```

## API Coverage

### Emails (5/5 endpoints)
- Send email
- Send batch emails
- Retrieve email
- Update scheduled email
- Cancel scheduled email

### Domains (6/6 endpoints)
- Create domain
- Get domain
- List domains
- Verify domain
- Update domain
- Delete domain

### API Keys (3/3 endpoints)
- Create API key
- List API keys
- Delete API key

### Audiences (4/4 endpoints)
- Create audience
- Get audience
- List audiences
- Delete audience

### Contacts (5/5 endpoints)
- Create contact
- Get contact
- List contacts
- Update contact
- Delete contact

### Broadcasts (6/6 endpoints)
- Create broadcast
- Get broadcast
- List broadcasts
- Update broadcast
- Send broadcast
- Delete broadcast

### Webhooks (5/5 endpoints)
- Create webhook
- Get webhook
- List webhooks
- Update webhook
- Delete webhook

## Usage Examples

### Send Email with Attachments

```swift
let attachment = EmailAttachment(
    content: "base64_encoded_content",
    filename: "invoice.pdf"
)

let email = ResendEmail(
    from: "billing@yourdomain.com",
    to: ["customer@example.com"],
    subject: "Your Invoice",
    html: "<p>Please find your invoice attached.</p>",
    attachments: [attachment]
)

let response = try await resend.email.send(email: email)
```

### Manage Domains

```swift
let domain = try await resend.domains.create(
    name: "yourdomain.com",
    region: "us-east-1",
    customReturnPath: nil
)
let verified = try await resend.domains.verify(id: domain.id)
let updated = try await resend.domains.update(
    id: domain.id, clickTracking: true, openTracking: true, tls: "enforced"
)
```

### Paginate Through All Contacts

```swift
for try await contact in resend.contacts.listAll(audienceId: audienceId, limit: 50) {
    print("\(contact.email): \(contact.firstName ?? "") \(contact.lastName ?? "")")
}
```

### Create and Send a Broadcast

```swift
let broadcast = try await resend.broadcasts.create(
    audienceId: "audience_id",
    from: "newsletter@yourdomain.com",
    subject: "Monthly Newsletter",
    html: "<p>Check out our latest updates!</p>",
    name: "January Newsletter"
)
let sent = try await resend.broadcasts.send(id: broadcast.id, scheduledAt: nil)
```

### Custom HTTP Client

```swift
class MyHTTPClient: HTTPClientProtocol {
    func execute(_ request: HTTPRequest) async throws -> HTTPResponse {
        // Custom implementation
    }
}

let resend = ResendClient(
    apiKey: "re_your_api_key",
    httpClient: MyHTTPClient()
)
```

## Platform Support

| Platform | Minimum Version |
|----------|----------------|
| iOS | 16+ |
| macOS | 13+ |
| tvOS | 16+ |
| watchOS | 9+ |
| Mac Catalyst | 16+ |
| visionOS | 1+ |
| Linux | Swift 6.0+ |

## Requirements

- Swift 6.0+
- For Vapor integration: Vapor 4.66.1+

## Development

### Linting

This project uses [SwiftLint](https://github.com/realm/SwiftLint) to enforce code style.

```bash
# Install SwiftLint
brew install swiftlint

# Run lint
swiftlint lint

# Pre-commit hook (auto-installed)
# Runs SwiftLint on staged files before each commit
git config core.hooksPath .githooks
```

## Documentation

Full API documentation is available using DocC:

```bash
swift package generate-documentation
```

## Error Handling

All API methods throw errors that conform to Swift's `Error` protocol. The SDK provides `ResendRetrieveError` for API errors:

```swift
do {
    let response = try await resend.email.send(email: email)
} catch let error as ResendRetrieveError {
    print("API Error [\(error.statusCode)]: \(error.message)")
} catch {
    print("Unexpected error: \(error)")
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License — see the LICENSE file for details.

## Links

- [Resend Website](https://resend.com)
- [Resend API Documentation](https://resend.com/docs)
- [GitHub Repository](https://github.com/yourusername/Resend)

## Acknowledgments

Built with ❤️ for the Swift community.
