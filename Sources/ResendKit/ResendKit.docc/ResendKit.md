# ``ResendKit``

Swift client for the Resend email API supporting iOS, macOS, tvOS, watchOS, and Linux.

## Overview

ResendKit provides a complete, type-safe Swift client for the Resend API. It uses URLSession for HTTP requests, making it compatible with all Apple platforms and Linux.

## Getting Started

### Installation

Add ResendKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Resend.git", from: "1.0.0")
]
```

### Basic Usage

```swift
import ResendKit

// Initialize the client
let resend = ResendClient(apiKey: "re_your_api_key")

// Send an email
let email = ResendEmail(
    from: "onboarding@resend.dev",
    to: ["user@example.com"],
    subject: "Hello World",
    html: "<p>Welcome!</p>"
)

let response = try await resend.email.send(email: email)
print("Email sent with ID: \(response.id)")
```

## Topics

### Client

- ``ResendClient``
- ``URLSessionHTTPClient``

### Email Operations

Send, retrieve, update, and cancel emails.

- ``EmailClient``

### Domain Management

Manage your sending domains.

- ``DomainClient``

### API Key Management

Create and manage API keys.

- ``APIKeyClient``

### Audience Management

Manage contact audiences.

- ``AudienceClient``

### Contact Management

Manage contacts within audiences.

- ``ContactClient``

### Broadcast Campaigns

Create and send broadcast email campaigns.

- ``BroadcastClient``
