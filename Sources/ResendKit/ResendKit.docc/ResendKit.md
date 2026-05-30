# ``ResendKit``

Swift client for the Resend email API supporting iOS, macOS, tvOS, watchOS, and Linux.

## Overview

ResendKit provides a complete, type-safe Swift client for the Resend API. It uses URLSession for HTTP requests, making it compatible with all Apple platforms and Linux.

## Getting Started

### Installation

Add ResendKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/devswiftzone/Resend.git", from: "1.0.0")
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

### With Retry and Logging

```swift
import Logging

let resend = ResendClient(
    apiKey: "re_your_api_key",
    retry: .default,
    logger: Logger(label: "resend")
)
```

## Topics

### Client

- ``ResendClient``
- ``URLSessionHTTPClient``

### Webhook Security

- ``WebhookSignature``
- ``WebhookVerificationError``

### Retry & Reliability

- ``RetryHTTPClient``
- ``RetryConfiguration``
