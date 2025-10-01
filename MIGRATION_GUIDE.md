# Migration Guide: v1.x to v2.0

This guide will help you migrate from Resend Swift SDK v1.x to v2.0.

## Overview of Changes

Version 2.0 is a complete rewrite with:
- ✅ Full API coverage (53 endpoints)
- ✅ Multi-platform support (iOS, macOS, tvOS, watchOS, Linux)
- ✅ Modular architecture
- ✅ Protocol-based design
- ⚠️ Breaking API changes

## Breaking Changes

### 1. Package Structure

**Before (v1.x):**
```swift
.package(url: "https://github.com/yourusername/Resend.git", from: "1.0.0")

// In target dependencies
.product(name: "Resend", package: "Resend")
```

**After (v2.0):**
```swift
.package(url: "https://github.com/yourusername/Resend.git", from: "2.0.0")

// For iOS/macOS apps
.product(name: "Resend", package: "Resend")
// OR for Vapor apps
.product(name: "ResendVapor", package: "Resend")
```

### 2. API Client Initialization

#### For iOS/macOS Apps

**Before (v1.x - didn't work properly):**
```swift
import Resend

// Static initialization
ResendClient.initialized(httpClient: someClient, apiKey: "re_xxx")

// Or attempted direct use (didn't work)
let email = ResendEmail(...)
try await ResendClient.email.send(email: email)
```

**After (v2.0):**
```swift
import Resend

// Instance-based
let resend = ResendClient(apiKey: "re_your_api_key")

let email = ResendEmail(
    from: "onboarding@yourdomain.com",
    to: ["user@example.com"],
    subject: "Hello",
    html: "<p>Welcome!</p>"
)

let response = try await resend.email.send(email: email)
```

#### For Vapor Apps

**Before (v1.x):**
```swift
import Vapor
import Resend

// In configure.swift
// Auto-initialized from environment variable

// In routes
let response = try await ResendClient.email.send(email: email)
```

**After (v2.0):**
```swift
import Vapor
import ResendVapor  // Note: Different import!

// In configure.swift
public func configure(_ app: Application) throws {
    // Option 1: From environment variable
    app.resend.initialize()

    // Option 2: Direct API key
    app.resend.initialize(apiKey: "re_your_api_key")

    try routes(app)
}

// In routes
func routes(_ app: Application) throws {
    app.post("send-email") { req async throws -> String in
        let email = ResendEmail(...)

        // Use req.resend instead of static ResendClient
        let response = try await req.resend.email.send(email: email)

        return "Email sent: \(response.id)"
    }
}
```

### 3. Accessing the Client

**Before (v1.x):**
```swift
// Static access
ResendClient.email.send(...)
ResendClient.domains.create(...) // Wasn't implemented
```

**After (v2.0):**
```swift
// iOS/macOS: Instance-based
let resend = ResendClient(apiKey: "...")
resend.email.send(...)
resend.domains.create(...)
resend.audiences.create(...)
resend.broadcasts.send(...)

// Vapor: Via request
req.resend.email.send(...)
req.resend.domains.create(...)

// Or via application
app.resend.client.email.send(...)
```

## New Features Available

### 1. Domain Management (NEW)

```swift
// Create domain
let domain = try await resend.domains.create(
    name: "yourdomain.com",
    region: "us-east-1",
    customReturnPath: nil
)

// List domains
let domains = try await resend.domains.list(limit: 10, after: nil, before: nil)

// Verify domain
let verified = try await resend.domains.verify(id: domain.id)

// Update settings
let updated = try await resend.domains.update(
    id: domain.id,
    clickTracking: true,
    openTracking: true,
    tls: "enforced"
)

// Delete domain
let deleted = try await resend.domains.delete(id: domain.id)
```

### 2. API Key Management (NEW)

```swift
// Create API key
let apiKey = try await resend.apiKeys.create(
    name: "Production Key",
    permission: "full_access",
    domainId: nil
)

// List API keys
let keys = try await resend.apiKeys.list(limit: 10, after: nil, before: nil)

// Delete API key
try await resend.apiKeys.delete(id: "key_id")
```

### 3. Audiences & Contacts (NEW)

```swift
// Create audience
let audience = try await resend.audiences.create(name: "Newsletter")

// Add contact
let contact = try await resend.contacts.create(
    audienceId: audience.id,
    email: "subscriber@example.com",
    firstName: "John",
    lastName: "Doe",
    unsubscribed: false
)

// List contacts
let contacts = try await resend.contacts.list(
    audienceId: audience.id,
    limit: 50,
    after: nil,
    before: nil
)

// Update contact
let updated = try await resend.contacts.update(
    audienceId: audience.id,
    identifier: contact.id,
    firstName: "Jane",
    lastName: nil,
    unsubscribed: nil
)
```

### 4. Broadcast Campaigns (NEW)

```swift
// Create broadcast
let broadcast = try await resend.broadcasts.create(
    audienceId: "audience_id",
    from: "newsletter@yourdomain.com",
    subject: "Monthly Newsletter",
    replyTo: nil,
    html: "<p>Newsletter content</p>",
    text: nil,
    name: "January Newsletter"
)

// Send broadcast
let sent = try await resend.broadcasts.send(
    id: broadcast.id,
    scheduledAt: "tomorrow at 9am"
)
```

### 5. Batch Email Sending (NEW)

```swift
let emails = [
    ResendEmail(from: "...", to: ["user1@example.com"], subject: "...", html: "..."),
    ResendEmail(from: "...", to: ["user2@example.com"], subject: "...", html: "...")
]

let response = try await resend.email.sendBatch(emails: emails)

// Check for errors
if let errors = response.errors {
    for error in errors {
        print("Error at index \(error.index): \(error.message)")
    }
}
```

### 6. Email Update & Cancel (NEW)

```swift
// Update scheduled email
let updated = try await resend.email.update(
    id: "email_id",
    scheduledAt: "2025-02-01T10:00:00Z"
)

// Cancel scheduled email
let cancelled = try await resend.email.cancel(id: "email_id")
```

## Step-by-Step Migration

### Step 1: Update Package.swift

```swift
// Update version
.package(url: "https://github.com/yourusername/Resend.git", from: "2.0.0")

// For Vapor apps, change import
.product(name: "ResendVapor", package: "Resend")  // was "Resend"
```

### Step 2: Update Imports

```swift
// iOS/macOS apps
import Resend  // Same

// Vapor apps
import ResendVapor  // Was: import Resend
```

### Step 3: Initialize Client

**iOS/macOS:**
```swift
// Add at app startup
let resend = ResendClient(apiKey: "re_your_api_key")
// Store in your app's dependency container
```

**Vapor:**
```swift
// In configure.swift
app.resend.initialize()
```

### Step 4: Update All API Calls

Find and replace:

**iOS/macOS:**
```swift
// Find: ResendClient.email.send
// Replace: resend.email.send

// Find: ResendClient.email.retrieve
// Replace: resend.email.retrieve
```

**Vapor:**
```swift
// Find: ResendClient.email.send
// Replace: req.resend.email.send

// Find: ResendClient.email.retrieve
// Replace: req.resend.email.retrieve
```

### Step 5: Test Thoroughly

Run your test suite to ensure everything works:

```bash
swift test
```

## Common Issues

### Issue 1: "Cannot find 'ResendClient' in scope" (Vapor)

**Problem:** Using old static access pattern in Vapor app.

**Solution:**
```swift
// ❌ Wrong
try await ResendClient.email.send(email: email)

// ✅ Correct
try await req.resend.email.send(email: email)
```

### Issue 2: "Module 'Resend' has no member 'email'" (Vapor)

**Problem:** Wrong import in Vapor app.

**Solution:**
```swift
// ❌ Wrong
import Resend

// ✅ Correct
import ResendVapor
```

### Issue 3: "Resend not initialized" (Vapor)

**Problem:** Forgot to call initialize in configure.swift.

**Solution:**
```swift
public func configure(_ app: Application) throws {
    app.resend.initialize()  // Add this
    try routes(app)
}
```

### Issue 4: iOS app won't compile

**Problem:** Vapor dependency leak.

**Solution:**
```swift
// ❌ Wrong (v1.x had this issue)
.product(name: "Resend", package: "Resend")  // Included Vapor

// ✅ Correct (v2.0 fixed this)
.product(name: "Resend", package: "Resend")  // No Vapor dependency
```

## Benefits of Upgrading

1. **53 API endpoints** vs 2 in v1.x
2. **Multi-platform support** - Now works on iOS, macOS, watchOS, tvOS, Linux
3. **Better architecture** - Modular, testable, maintainable
4. **Full documentation** - DocC, README, guides
5. **Protocol-based** - Easy to mock for testing
6. **Type-safe** - Comprehensive models for all API responses
7. **Modern Swift** - Swift 6.0, async/await throughout

## Need Help?

- Check the [README](./README.md) for comprehensive examples
- See [VAPOR_GUIDE.md](./VAPOR_GUIDE.md) for Vapor-specific usage
- Review the [CHANGELOG](./CHANGELOG.md) for all changes
- Open an issue on GitHub for support

## Rollback Plan

If you encounter issues, you can rollback to v1.x:

```swift
.package(url: "https://github.com/yourusername/Resend.git", from: "1.0.0")
```

However, note that v1.x is no longer maintained and has limited functionality.
