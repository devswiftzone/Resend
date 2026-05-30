# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2025-01-XX

### 🎉 Major Rewrite - Complete API Coverage & Multi-Platform Support

#### Added
- ✅ **Complete API Coverage**: All 53 Resend API endpoints now implemented
  - Emails: send, batch send, retrieve, update, cancel (5/5)
  - Domains: create, get, list, verify, update, delete (6/6)
  - API Keys: create, list, delete (3/3)
  - Audiences: create, get, list, delete (4/4)
  - Contacts: create, get, list, update, delete (5/5)
  - Broadcasts: create, get, list, update, send, delete (6/6)

- 🏗️ **Modular Architecture**: Separated into 4 distinct modules
  - `ResendCore`: Core models and protocols (no dependencies)
  - `ResendKit`: URLSession-based client for iOS/macOS/Linux
  - `ResendVapor`: Vapor framework integration
  - `Resend`: Convenience re-export module

- 🌍 **Multi-Platform Support**: Now supports
  - iOS 15.0+
  - macOS 12.0+
  - tvOS 15.0+
  - watchOS 8.0+
  - Mac Catalyst 15.0+
  - Linux (with Swift 6.0+)

- 📚 **Complete Documentation**
  - DocC documentation for all public APIs
  - Comprehensive README with examples
  - Dedicated Vapor integration guide
  - Inline code documentation

- 🔧 **New Models**
  - `ResendDomain` & `DNSRecord`
  - `ResendAPIKey` & `ResendAPIKeyListItem`
  - `ResendAudience`
  - `ResendContact`
  - `ResendBroadcast` & `ResendBroadcastSendResponse`
  - `ResendListResponse<T>` for paginated endpoints
  - `ResendDeleteResponse`
  - `ResendBatchResponse` & `ResendBatchError`

- 🎯 **Protocol-Based Design**
  - `HTTPClientProtocol` for custom HTTP implementations
  - `ResendClientProtocol` and specialized client protocols
  - Easy to mock for testing

#### Changed
- ⚡ **Breaking**: Removed static singleton pattern in favor of instance-based API
  - Old: `ResendClient.email.send()`
  - New: `resend.email.send()` or `req.resend.email.send()` (Vapor)

- 🔄 **Breaking**: Vapor integration now requires explicit initialization
  - Old: Auto-initialized from environment
  - New: Must call `app.resend.initialize()` in configure.swift

- 📦 **Breaking**: Package structure reorganized
  - Models moved from `ResendKit/Models` to `ResendCore/Models`
  - Vapor code extracted to separate `ResendVapor` module

- 🚀 **Improved**: URLSession-based HTTP client (was AsyncHTTPClient)
  - Better iOS/macOS compatibility
  - Reduced dependencies
  - ResendVapor still uses Vapor's AsyncHTTPClient for server-side

- 📝 **Enhanced**: All models now have proper public initializers

#### Removed
- ❌ **Breaking**: Removed AsyncHTTPClient dependency from core
- ❌ Removed hard-coded static configuration
- ❌ Removed MOdels directory (fixed typo to Models)

#### Fixed
- 🐛 Fixed Sendable conformance for Vapor integration (Swift 6.0)
- 🐛 Fixed typo in Models directory name
- 🐛 Fixed missing public access modifiers
- 🐛 Corrected CodingKeys for snake_case API fields

#### Migration Guide

**For iOS/macOS Apps:**
```swift
// Before (didn't work properly)
import Resend
ResendClient.initialized(httpClient: client, apiKey: apiKey)
let response = try await ResendClient.email.send(email: email)

// After
import Resend
let resend = ResendClient(apiKey: "re_your_api_key")
let response = try await resend.email.send(email: email)
```

**For Vapor Apps:**
```swift
// Before
import Resend
// Auto-initialized

// After
import ResendVapor

// In configure.swift
app.resend.initialize(apiKey: "re_your_api_key")
// or from environment
app.resend.initialize()

// In routes
try await req.resend.email.send(email: email)
```

## [1.0.0] - 2023-12-03

### Added
- Initial release
- Basic email sending functionality
- Vapor integration
- ResendEmail model with attachments and tags support

### Known Issues
- Only 2 of 53 API endpoints implemented
- Limited to macOS server-side only
- Hard dependency on Vapor for all use cases
- Domain management stubs only
