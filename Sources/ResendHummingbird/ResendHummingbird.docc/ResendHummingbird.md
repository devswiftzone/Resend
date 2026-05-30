# ``ResendHummingbird``

Hummingbird framework integration for the Resend email SDK.

## Overview

ResendHummingbird provides support for using the Resend API from Hummingbird-based applications. It uses `AsyncHTTPClient` for HTTP transport and offers two integration styles:

- **`HummingbirdHTTPClient`**: A lightweight adapter wrapping `AsyncHTTPClient.HTTPClient` for manual setup with dependency injection.
- **`Application.resend`**: A convenience extension for quick setup via `app.resend.initialize(apiKey:)`.

## Getting Started

### Installation

Add ResendHummingbird to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/devswiftzone/Resend.git", from: "1.0.0")
]
```

### Manual Setup (Dependency Injection)

```swift
import Hummingbird
import AsyncHTTPClient
import ResendHummingbird

let router = Router()
let resend = ResendClient(
    apiKey: "re_your_api_key",
    httpClient: HummingbirdHTTPClient()
)
// Pass `resend` to your route handlers via struct initializers
let controller = EmailController(resend: resend)
controller.addRoutes(to: &router)
var app = Application(router: router)
```

### Application Extension Setup

```swift
import Hummingbird
import ResendHummingbird

var app = Application(router: router)
app.resend.initialize(apiKey: "re_your_api_key")
// Or read from RESEND_API_KEY environment variable:
// app.resend.initialize()

// Use in route handlers via dependency injection
let controller = EmailController(resend: app.resend.client)
controller.addRoutes(to: &router)
```

## Topics

### Client

- ``HummingbirdHTTPClient``

### Application Integration

- ``Application/resend``
- ``Application/Resend``
- ``Application/Resend/initialize(apiKey:)``
