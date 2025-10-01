# Resend Swift SDK

[![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-blue.svg)](https://swift.org)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)

A modern, type-safe Swift SDK for the [Resend](https://resend.com) email API with full platform support.

## Features

- ✅ **Complete API Coverage** - All 53 Resend API endpoints implemented
- ✅ **Multi-Platform** - iOS, macOS, tvOS, watchOS, Mac Catalyst, and Linux
- ✅ **Type-Safe** - Fully typed Swift interfaces with async/await support
- ✅ **Modular Architecture** - Use only what you need
- ✅ **Vapor Integration** - First-class support for server-side Swift
- ✅ **Zero Dependencies** - Core package has no external dependencies

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

### iOS/macOS Application

```swift
import Resend

// Initialize the client
let resend = ResendClient(apiKey: "re_your_api_key")

// Send an email
let email = ResendEmail(
    from: "onboarding@yourdomain.com",
    to: ["user@example.com"],
    subject: "Welcome to our app!",
    html: "<h1>Welcome!</h1><p>Thanks for signing up.</p>"
)

do {
    let response = try await resend.email.send(email: email)
    print("Email sent! ID: \(response.id)")
} catch {
    print("Failed to send email: \(error)")
}
```

### Vapor Application

```swift
import Vapor
import ResendVapor

// Configure in configure.swift
func configure(_ app: Application) throws {
    app.resend.initialize(apiKey: "re_your_api_key")
    // or use environment variable RESEND_API_KEY
    app.resend.initialize()
}

// Use in routes
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

## API Coverage

### Emails (5/5 endpoints)
- ✅ Send email
- ✅ Send batch emails
- ✅ Retrieve email
- ✅ Update scheduled email
- ✅ Cancel scheduled email

### Domains (6/6 endpoints)
- ✅ Create domain
- ✅ Get domain
- ✅ List domains
- ✅ Verify domain
- ✅ Update domain
- ✅ Delete domain

### API Keys (3/3 endpoints)
- ✅ Create API key
- ✅ List API keys
- ✅ Delete API key

### Audiences (4/4 endpoints)
- ✅ Create audience
- ✅ Get audience
- ✅ List audiences
- ✅ Delete audience

### Contacts (5/5 endpoints)
- ✅ Create contact
- ✅ Get contact
- ✅ List contacts
- ✅ Update contact
- ✅ Delete contact

### Broadcasts (6/6 endpoints)
- ✅ Create broadcast
- ✅ Get broadcast
- ✅ List broadcasts
- ✅ Update broadcast
- ✅ Send broadcast
- ✅ Delete broadcast

## Usage Examples

### Send Email with Attachments

```swift
let attachment = EmailAttachment(
    content: "base64_encoded_content",
    filename: "invoice.pdf",
    path: "invoice.pdf"
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
// Create a domain
let domain = try await resend.domains.create(
    name: "yourdomain.com",
    region: "us-east-1",
    customReturnPath: nil
)

// List all domains
let domains = try await resend.domains.list(limit: 10, after: nil, before: nil)

// Verify domain DNS records
let verified = try await resend.domains.verify(id: domain.id)

// Update domain settings
let updated = try await resend.domains.update(
    id: domain.id,
    clickTracking: true,
    openTracking: true,
    tls: "enforced"
)
```

### Create and Manage Audiences

```swift
// Create an audience
let audience = try await resend.audiences.create(name: "Newsletter Subscribers")

// Add a contact
let contact = try await resend.contacts.create(
    audienceId: audience.id,
    email: "subscriber@example.com",
    firstName: "John",
    lastName: "Doe",
    unsubscribed: false
)

// List all contacts in audience
let contacts = try await resend.contacts.list(
    audienceId: audience.id,
    limit: 50,
    after: nil,
    before: nil
)
```

### Send Broadcast Campaign

```swift
// Create a broadcast
let broadcast = try await resend.broadcasts.create(
    audienceId: "audience_id",
    from: "newsletter@yourdomain.com",
    subject: "Monthly Newsletter",
    replyTo: nil,
    html: "<p>Check out our latest updates!</p>",
    text: nil,
    name: "January Newsletter"
)

// Send immediately
let sent = try await resend.broadcasts.send(id: broadcast.id, scheduledAt: nil)

// Or schedule for later
let scheduled = try await resend.broadcasts.send(
    id: broadcast.id,
    scheduledAt: "in 2 hours"
)
```

### Batch Email Sending

```swift
let emails = [
    ResendEmail(
        from: "noreply@yourdomain.com",
        to: ["user1@example.com"],
        subject: "Welcome!",
        html: "<p>Welcome user 1!</p>"
    ),
    ResendEmail(
        from: "noreply@yourdomain.com",
        to: ["user2@example.com"],
        subject: "Welcome!",
        html: "<p>Welcome user 2!</p>"
    )
]

let batchResponse = try await resend.email.sendBatch(emails: emails)

for email in batchResponse.data {
    print("Sent email with ID: \(email.id)")
}

if let errors = batchResponse.errors {
    for error in errors {
        print("Error at index \(error.index): \(error.message)")
    }
}
```

### Custom HTTP Client

You can provide your own HTTP client implementation:

```swift
class MyHTTPClient: HTTPClientProtocol {
    func execute(_ request: HTTPRequest) async throws -> HTTPResponse {
        // Your custom implementation
    }
}

let customClient = MyHTTPClient()
let resend = ResendClient(
    apiKey: "re_your_api_key",
    httpClient: customClient
)
```

## Platform Support

| Platform | Minimum Version |
|----------|----------------|
| iOS | 15.0+ |
| macOS | 12.0+ |
| tvOS | 15.0+ |
| watchOS | 8.0+ |
| Mac Catalyst | 15.0+ |
| Linux | Swift 6.0+ |

## Requirements

- Swift 6.0+
- For Vapor integration: Vapor 4.66.1+

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

This project is licensed under the MIT License - see the LICENSE file for details.

## Links

- [Resend Website](https://resend.com)
- [Resend API Documentation](https://resend.com/docs)
- [GitHub Repository](https://github.com/yourusername/Resend)

## Acknowledgments

Built with ❤️ for the Swift community.
