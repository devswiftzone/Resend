# ``ResendVapor``

Vapor framework integration for the Resend email SDK.

## Overview

ResendVapor provides first‑class support for using the Resend API from Vapor applications. It uses Vapor’s `Client` for HTTP transport and provides a convenient `app.resend` API.

## Getting Started

### Installation

Add ResendVapor to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/devswiftzone/Resend.git", from: "1.0.0")
]
```

### Basic Usage

```swift
import Vapor
import ResendVapor

func configure(_ app: Application) throws {
    // Initialize with API key
    app.resend.initialize(apiKey: "re_your_api_key")

    // Or read from RESEND_API_KEY environment variable
    // app.resend.initialize()
}

func routes(_ app: Application) throws {
    app.post("send-email") { req async throws -> String in
        let email = ResendEmail(
            from: "noreply@example.com",
            to: ["user@example.com"],
            subject: "Hello from Vapor!",
            html: "<p>This email was sent from a Vapor app.</p>"
        )
        let response = try await req.resend.email.send(email: email)
        return "Email sent with ID: \(response.id)"
    }
}
```

## Topics

### Client

- ``VaporHTTPClient``

### Application Integration

- ``Application/resend``
- ``Application/Resend``
- ``Application/Resend/initialize(apiKey:)``

### Request Integration

- ``Request/resend``
