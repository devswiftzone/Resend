import Foundation
import Logging
import Crypto
import Resend

// Configuración desde variables de entorno
guard let apiKey = ProcessInfo.processInfo.environment["RESEND_API_KEY"], !apiKey.isEmpty else {
    fatalError("RESEND_API_KEY environment variable is required")
}
let fromEmail = ProcessInfo.processInfo.environment["FROM_EMAIL"] ?? "hello@swiftzone.dev"
let toEmail = ProcessInfo.processInfo.environment["TO_EMAIL"] ?? "cabrerasiel@gmail.com"
let domainName = ProcessInfo.processInfo.environment["DOMAIN"] ?? "swiftzone.dev"

let resend = ResendClient(
    apiKey: apiKey,
    retry: RetryConfiguration(maxRetries: 3),
    logger: Logger(label: "com.resend.example")
)

// MARK: - 1. Send a Simple Email
print("\n─── 1. Send Email ───")
var lastEmailId: String?
do {
    let email = ResendEmail(
        from: fromEmail,
        to: [toEmail],
        subject: "Hello from Resend Swift SDK",
        html: "<strong>Welcome!</strong>",
        text: "Welcome to Resend!"
    )
    let r = try await resend.email.send(email: email)
    lastEmailId = r.id
    print("  Sent: \(r.id)")
} catch {
    print("  Error: \(error)")
}

// MARK: - 2. Send with Attachment
print("\n─── 2. Send with Attachment ───")
do {
    let attachment = EmailAttachment(
        content: Data("Hello, world!".utf8).base64EncodedString(),
        filename: "hello.txt"
    )
    let email = ResendEmail(
        from: fromEmail,
        to: [toEmail],
        subject: "With Attachment",
        html: "<p>See attached file.</p>",
        attachments: [attachment]
    )
    let r = try await resend.email.send(email: email)
    print("  Sent with attachment: \(r.id)")
} catch {
    print("  Error: \(error)")
}

// MARK: - 3. Send with Tags and Headers
print("\n─── 3. Send with Tags and Headers ───")
do {
    let email = ResendEmail(
        from: fromEmail,
        to: [toEmail],
        subject: "Tracked Email",
        html: "<p>Track this email.</p>",
        headers: ["X-Custom": "value"],
        tags: [
            EmailTag(name: "category", value: "welcome"),
            EmailTag(name: "user_id", value: "42")
        ]
    )
    let r = try await resend.email.send(email: email)
    print("  Sent with tags: \(r.id)")
} catch {
    print("  Error: \(error)")
}

// MARK: - 4. Retrieve an Email
print("\n─── 4. Retrieve Email ───")
if let id = lastEmailId {
    do {
        let email = try await resend.email.retrieve(id: id)
        print("  Subject: \(email.subject), From: \(email.from)")
    } catch {
        print("  Error: \(error)")
    }
} else {
    print("  Skip: no sent email ID available")
}

// MARK: - 5. List Emails
print("\n─── 5. List Emails ───")
do {
    let list = try await resend.email.list(limit: 10, after: nil, before: nil)
    print("  Page items: \(list.data.count), hasMore: \(list.hasMore)")
} catch {
    print("  Error: \(error)")
}

// MARK: - 6. Auto Pagination
print("\n─── 6. Auto Pagination ───")
do {
    for try await email in resend.email.listAll(limit: 5) {
        print("  - \(email.id ?? "?"): \(email.subject)")
    }
} catch {
    print("  Error: \(error)")
}

// MARK: - 7. Batch Send
print("\n─── 7. Batch Send ───")
do {
    let emails = [
        ResendEmail(from: fromEmail, to: [toEmail], subject: "Hi A", html: "<p>Hi</p>"),
        ResendEmail(from: fromEmail, to: [toEmail], subject: "Hi B", html: "<p>Hi</p>")
    ]
    let r = try await resend.email.sendBatch(emails: emails)
    print("  Sent \(r.data.count) emails")
    if let errors = r.errors {
        for e in errors { print("  Error at \(e.index): \(e.message)") }
    }
} catch {
    print("  Error: \(error)")
}

// MARK: - 8. Update Scheduled Email
print("\n─── 8. Update Scheduled Email ───")
if let id = lastEmailId {
    do {
        let r = try await resend.email.update(id: id, scheduledAt: "2026-06-01T10:00:00Z")
        print("  Updated: \(r.id)")
    } catch {
        print("  Error: \(error)")
    }
} else {
    print("  Skip: no sent email ID available")
}

// MARK: - 9. Cancel Scheduled Email
print("\n─── 9. Cancel Scheduled Email ───")
if let id = lastEmailId {
    do {
        let r = try await resend.email.cancel(id: id)
        print("  Canceled: \(r.id)")
    } catch {
        print("  Error: \(error)")
    }
} else {
    print("  Skip: no sent email ID available")
}

// MARK: - 10. Domain Management
print("\n─── 10. Domain Management ───")
do {
    // Create domain (needs DNS verification in dashboard)
    let d = try await resend.domains.create(name: domainName, region: "us-east-1", customReturnPath: nil)
    print("  Created: \(d.id)")

    let g = try await resend.domains.get(id: d.id)
    print("  Status: \(g.status ?? "unknown")")

    let v = try await resend.domains.verify(id: d.id)
    print("  Verified: \(v.status ?? "unknown")")

    if let records = d.records {
        print("  DNS records to configure:")
        for record in records {
            print("    \(record.record): \(record.name) \(record.type) → \(record.value)")
        }
    }

    _ = try await resend.domains.update(id: d.id, clickTracking: true, openTracking: true, tls: "enforce")
    print("  Tracking updated")

    let del = try await resend.domains.delete(id: d.id)
    print("  Deleted: \(del.deleted)")
} catch {
    print("  Error: \(error)")
}

// MARK: - 11. List All Domains
print("\n─── 11. List All Domains ───")
do {
    for try await domain in resend.domains.listAll(limit: 10) {
        print("  \(domain.name) [\(domain.status ?? "?")]")
    }
} catch {
    print("  Error: \(error)")
}

// MARK: - 12. API Key Management
print("\n─── 12. API Key Management ───")
do {
    let k = try await resend.apiKeys.create(name: "Example Key", permission: "full_access", domainId: nil)
    print("  Created: \(k.id), Token: \(k.token)")

    let del = try await resend.apiKeys.delete(id: k.id)
    print("  Deleted: \(del.deleted)")
} catch {
    print("  Error: \(error)")
}

// MARK: - 13. Audience + Contact Management
print("\n─── 13. Audience + Contact Management ───")
do {
    let audience = try await resend.audiences.create(name: "Newsletter")
    print("  Audience: \(audience.id)")

    let contact = try await resend.contacts.create(
        audienceId: audience.id,
        email: toEmail,
        firstName: "User",
        lastName: "Test",
        unsubscribed: false
    )
    print("  Contact: \(contact.id)")

    let updated = try await resend.contacts.update(
        audienceId: audience.id,
        identifier: toEmail,
        firstName: "Updated",
        lastName: nil,
        unsubscribed: nil
    )
    print("  Updated: \(updated.firstName ?? "")")

    let renamed = try await resend.audiences.update(id: audience.id, name: "Premium Newsletter")
    print("  Renamed: \(renamed.name)")

    let delContact = try await resend.contacts.delete(audienceId: audience.id, identifier: toEmail)
    print("  Contact deleted: \(delContact.deleted)")

    let delAudience = try await resend.audiences.delete(id: audience.id)
    print("  Audience deleted: \(delAudience.deleted)")
} catch {
    print("  Error: \(error)")
}

// MARK: - 14. Broadcast Campaign
print("\n─── 14. Broadcast Campaign ───")
do {
    let audience = try await resend.audiences.create(name: "Campaign")
    let broadcast = try await resend.broadcasts.create(
        audienceId: audience.id,
        from: fromEmail,
        subject: "Monthly Newsletter",
        replyTo: [fromEmail],
        html: "<h1>Newsletter</h1>",
        text: "Newsletter text",
        name: "March Newsletter"
    )
    print("  Broadcast: \(broadcast.id)")

    let updated = try await resend.broadcasts.update(
        id: broadcast.id,
        audienceId: nil, from: nil,
        subject: "Updated Newsletter",
        replyTo: nil, html: nil, text: nil, name: nil
    )
    print("  Updated subject: \(updated.subject ?? "?")")

    let sent = try await resend.broadcasts.send(id: broadcast.id, scheduledAt: nil)
    print("  Sent: \(sent.id)")

    let del = try await resend.broadcasts.delete(id: broadcast.id)
    print("  Deleted: \(del.deleted)")

    _ = try await resend.audiences.delete(id: audience.id)
} catch {
    print("  Error: \(error)")
}

// MARK: - 15. Webhook Management
print("\n─── 15. Webhook Management ───")
do {
    let wh = try await resend.webhooks.create(
        endpoint: "https://myapp.com/webhooks/resend",
        events: ["email.sent", "email.delivered", "email.bounced"]
    )
    print("  Created: \(wh.id)")

    let g = try await resend.webhooks.get(id: wh.id)
    print("  Endpoint: \(g.endpoint ?? "")")

    let u = try await resend.webhooks.update(id: wh.id, endpoint: nil, events: ["email.sent"], disabled: false)
    print("  Events: \(u.events ?? [])")

    let del = try await resend.webhooks.delete(id: wh.id)
    print("  Deleted: \(del.deleted)")
} catch {
    print("  Error: \(error)")
}

// MARK: - 16. Webhook Signature Verification
print("\n─── 16. Webhook Signature Verification ───")
do {
    let rawKey = "test-secret-key-12345"
    let base64Secret = "whsec_" + Data(rawKey.utf8).base64EncodedString()
    let whId = "wh_123"
    let ts = String(Int(Date().timeIntervalSince1970))
    let payload = #"{"type":"email.sent","data":{"id":"email_123"}}"#

    let signedContent = "\(whId).\(ts).\(payload)"
    let key = SymmetricKey(data: Data(rawKey.utf8))
    let code = HMAC<SHA256>.authenticationCode(for: Data(signedContent.utf8), using: key)
    let base64sig = Data(code).base64EncodedString()
    let header = "v1,\(base64sig)"

    let valid = try WebhookSignature.verify(
        payload: payload,
        id: whId,
        timestamp: ts,
        signatureHeader: header,
        secret: base64Secret
    )
    print("  Signature valid: \(valid)")
} catch {
    print("  Error: \(error)")
}

// MARK: - 17. Custom Configuration
print("\n─── 17. Custom Configuration ───")
let custom = RetryConfiguration(maxRetries: 5, baseDelay: 0.5, maxDelay: 30, enableJitter: true)
let euClient = ResendClient(apiKey: apiKey, retry: custom, baseURL: "https://api.eu.resend.com")
_ = euClient

print("\n─── Example Complete ───")
