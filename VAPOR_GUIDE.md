# Resend Vapor Integration Guide

Complete guide for using Resend with Vapor server-side Swift applications.

## Installation

Add ResendVapor to your Vapor project's `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.66.1"),
    .package(url: "https://github.com/devswiftzone/Resend.git", from: "1.0.0")
],
targets: [
    .target(
        name: "App",
        dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "ResendVapor", package: "Resend")
        ]
    )
]
```

## Configuration

### Option 1: Environment Variable

Set the `RESEND_API_KEY` environment variable and initialize:

```swift
import Vapor
import ResendVapor

public func configure(_ app: Application) throws {
    // Initialize Resend from environment variable
    app.resend.initialize()

    // Your other configuration...
    try routes(app)
}
```

### Option 2: Direct API Key

```swift
import Vapor
import ResendVapor

public func configure(_ app: Application) throws {
    // Initialize with API key directly
    app.resend.initialize(apiKey: "re_your_api_key")

    try routes(app)
}
```

## Basic Usage

### Sending Email in Routes

```swift
import Vapor
import ResendVapor

func routes(_ app: Application) throws {
    app.post("send-welcome-email") { req async throws -> Response in
        struct EmailRequest: Content {
            let userEmail: String
            let userName: String
        }

        let emailReq = try req.content.decode(EmailRequest.self)

        let email = ResendEmail(
            from: "welcome@yourdomain.com",
            to: [emailReq.userEmail],
            subject: "Welcome, \(emailReq.userName)!",
            html: """
                <h1>Welcome to our platform!</h1>
                <p>Hi \(emailReq.userName),</p>
                <p>Thanks for joining us. We're excited to have you!</p>
                """
        )

        let response = try await req.resend.email.send(email: email)

        return Response(
            status: .ok,
            body: .init(string: "Email sent with ID: \(response.id)")
        )
    }
}
```

## Advanced Examples

### Transactional Email Service

Create a reusable email service:

```swift
import Vapor
import ResendVapor

struct EmailService {
    let resend: ResendClient

    func sendPasswordReset(to email: String, token: String) async throws {
        let resetLink = "https://yourdomain.com/reset-password?token=\(token)"

        let emailContent = ResendEmail(
            from: "security@yourdomain.com",
            to: [email],
            subject: "Password Reset Request",
            html: """
                <h2>Password Reset</h2>
                <p>Click the link below to reset your password:</p>
                <a href="\(resetLink)">Reset Password</a>
                <p>This link expires in 1 hour.</p>
                """
        )

        _ = try await resend.email.send(email: emailContent)
    }

    func sendOrderConfirmation(to email: String, orderNumber: String, total: Double) async throws {
        let emailContent = ResendEmail(
            from: "orders@yourdomain.com",
            to: [email],
            subject: "Order Confirmation #\(orderNumber)",
            html: """
                <h2>Thank you for your order!</h2>
                <p>Order #\(orderNumber)</p>
                <p>Total: $\(String(format: "%.2f", total))</p>
                """,
            tags: [
                EmailTag(name: "category", value: "order_confirmation"),
                EmailTag(name: "order_number", value: orderNumber)
            ]
        )

        _ = try await resend.email.send(email: emailContent)
    }
}

// Use in routes
func routes(_ app: Application) throws {
    let emailService = EmailService(resend: app.resend.client)

    app.post("request-password-reset") { req async throws -> HTTPStatus in
        struct ResetRequest: Content {
            let email: String
        }

        let reset = try req.content.decode(ResetRequest.self)
        let token = // generate token...

        try await emailService.sendPasswordReset(to: reset.email, token: token)
        return .ok
    }
}
```

### Background Email Queue

Process emails in the background:

```swift
import Vapor
import ResendVapor
import Queues

struct SendEmailJob: AsyncJob {
    struct Payload: Codable {
        let from: String
        let to: [String]
        let subject: String
        let html: String
    }

    func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
        let email = ResendEmail(
            from: payload.from,
            to: payload.to,
            subject: payload.subject,
            html: payload.html
        )

        _ = try await context.application.resend.client.email.send(email: email)
    }
}

// Register job
app.queues.add(SendEmailJob())

// Queue an email
try await req.queue.dispatch(
    SendEmailJob.self,
    .init(
        from: "noreply@yourdomain.com",
        to: ["user@example.com"],
        subject: "Queued Email",
        html: "<p>This was sent via a queue</p>"
    )
)
```

### Scheduled Email Campaigns

```swift
app.get("schedule-campaign") { req async throws -> String in
    // Create broadcast
    let broadcast = try await req.resend.broadcasts.create(
        audienceId: "audience_123",
        from: "newsletter@yourdomain.com",
        subject: "Weekly Newsletter",
        replyTo: nil,
        html: "<h1>This week's updates</h1>",
        text: nil,
        name: "Weekly Newsletter"
    )

    // Schedule for later
    _ = try await req.resend.broadcasts.send(
        id: broadcast.id,
        scheduledAt: "tomorrow at 9am"
    )

    return "Campaign scheduled!"
}
```

### Domain Management API

```swift
struct DomainController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let domains = routes.grouped("domains")
        domains.get(use: list)
        domains.post(use: create)
        domains.post(":id", "verify", use: verify)
        domains.delete(":id", use: delete)
    }

    func list(req: Request) async throws -> [ResendDomain] {
        let response = try await req.resend.domains.list(
            limit: 50,
            after: nil,
            before: nil
        )
        return response.data
    }

    func create(req: Request) async throws -> ResendDomain {
        struct CreateDomain: Content {
            let name: String
            let region: String?
        }

        let domain = try req.content.decode(CreateDomain.self)
        return try await req.resend.domains.create(
            name: domain.name,
            region: domain.region,
            customReturnPath: nil
        )
    }

    func verify(req: Request) async throws -> ResendDomain {
        guard let domainId = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }

        return try await req.resend.domains.verify(id: domainId)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let domainId = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }

        _ = try await req.resend.domains.delete(id: domainId)
        return .noContent
    }
}

// Register
try app.register(collection: DomainController())
```

### Email Templates with Leaf

```swift
import Vapor
import ResendVapor
import Leaf

app.get("send-templated-email") { req async throws -> String in
    struct EmailContext: Encodable {
        let userName: String
        let verificationLink: String
    }

    let context = EmailContext(
        userName: "John Doe",
        verificationLink: "https://yourdomain.com/verify/token123"
    )

    // Render Leaf template
    let html = try await req.view.render("emails/verification", context).get()

    let email = ResendEmail(
        from: "verify@yourdomain.com",
        to: ["user@example.com"],
        subject: "Verify Your Email",
        html: html.data.getString(at: 0, length: html.data.readableBytes)
    )

    let response = try await req.resend.email.send(email: email)
    return "Email sent: \(response.id)"
}
```

### Newsletter Subscription Flow

```swift
struct NewsletterController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let newsletter = routes.grouped("newsletter")
        newsletter.post("subscribe", use: subscribe)
        newsletter.post("unsubscribe", use: unsubscribe)
    }

    func subscribe(req: Request) async throws -> HTTPStatus {
        struct Subscription: Content {
            let email: String
            let firstName: String?
            let lastName: String?
        }

        let sub = try req.content.decode(Subscription.self)

        // Add to audience
        _ = try await req.resend.contacts.create(
            audienceId: "newsletter_audience_id",
            email: sub.email,
            firstName: sub.firstName,
            lastName: sub.lastName,
            unsubscribed: false
        )

        // Send welcome email
        let welcomeEmail = ResendEmail(
            from: "newsletter@yourdomain.com",
            to: [sub.email],
            subject: "Welcome to our newsletter!",
            html: "<h1>Thanks for subscribing!</h1>"
        )

        _ = try await req.resend.email.send(email: welcomeEmail)

        return .ok
    }

    func unsubscribe(req: Request) async throws -> HTTPStatus {
        struct Unsubscribe: Content {
            let email: String
        }

        let unsub = try req.content.decode(Unsubscribe.self)

        _ = try await req.resend.contacts.update(
            audienceId: "newsletter_audience_id",
            identifier: unsub.email,
            firstName: nil,
            lastName: nil,
            unsubscribed: true
        )

        return .ok
    }
}
```

## Error Handling

```swift
app.post("send-email") { req async throws -> Response in
    let email = // ... create email

    do {
        let response = try await req.resend.email.send(email: email)
        return Response(status: .ok, body: .init(string: response.id))
    } catch let error as ResendRetrieveError {
        // Handle Resend API errors
        req.logger.error("Resend API error: \(error.message)")
        throw Abort(.badRequest, reason: error.message)
    } catch {
        // Handle other errors
        req.logger.error("Unexpected error: \(error)")
        throw Abort(.internalServerError)
    }
}
```

## Testing

```swift
@testable import App
import XCTVapor
import ResendVapor

final class EmailTests: XCTestCase {
    func testSendEmail() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        try configure(app)

        try app.test(.POST, "send-email") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
}
```

## Best Practices

1. **Use Environment Variables**: Store API keys in environment variables, not in code
2. **Queue Long Operations**: Use Vapor Queues for batch emails or heavy operations
3. **Template Emails**: Use Leaf templates for maintainable email content
4. **Add Logging**: Log email sends for debugging and monitoring
5. **Handle Errors Gracefully**: Always catch and handle API errors
6. **Use Tags**: Tag emails for better tracking and analytics
7. **Rate Limiting**: Respect Resend's rate limits (2 requests/second default)

## Migration from Old API

If you're migrating from the old static API:

### Before:
```swift
app.resend.initialize()
let response = try await ResendClient.email.send(email: email)
```

### After:
```swift
app.resend.initialize()
let response = try await req.resend.email.send(email: email)
// or
let response = try await app.resend.client.email.send(email: email)
```

## Resources

- [Vapor Documentation](https://docs.vapor.codes)
- [Resend API Documentation](https://resend.com/docs)
- [Main README](./README.md)
