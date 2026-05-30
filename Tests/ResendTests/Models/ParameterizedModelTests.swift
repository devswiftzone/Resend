import Testing
import Foundation
@testable import ResendCore

// MARK: - EmailAttachment Tests

@Suite("EmailAttachment Tests")
struct EmailAttachmentTests {

    @Test("Basic initialization with content")
    func testBasic() {
        let attachment = EmailAttachment(content: "base64", filename: "doc.pdf")
        #expect(attachment.content == "base64")
        #expect(attachment.filename == "doc.pdf")
        #expect(attachment.path == nil)
        #expect(attachment.type == nil)
    }

    @Test("URL path attachment")
    func testURLPath() {
        let attachment = EmailAttachment(filename: "report.pdf", path: "https://example.com/report.pdf")
        #expect(attachment.content == nil)
        #expect(attachment.path == "https://example.com/report.pdf")
    }

    @Test("Full initialization with type")
    func testFull() {
        let attachment = EmailAttachment(content: "base64", filename: "doc.pdf", path: nil, type: "application/pdf")
        #expect(attachment.type == "application/pdf")
    }

    @Test("Encoding to JSON")
    func testEncoding() throws {
        let attachment = EmailAttachment(content: "base64", filename: "doc.pdf")
        let data = try JSONEncoder().encode(attachment)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: String]
        #expect(json?["content"] == "base64")
        #expect(json?["filename"] == "doc.pdf")
    }

    @Test("Decoding from JSON")
    func testDecoding() throws {
        let json = #"{"content":"base64","filename":"doc.pdf"}"#
        let data = json.data(using: .utf8)!
        let attachment = try JSONDecoder().decode(EmailAttachment.self, from: data)
        #expect(attachment.content == "base64")
        #expect(attachment.filename == "doc.pdf")
    }

    @Test("Empty content string")
    func testEmptyContent() {
        let attachment = EmailAttachment(content: "", filename: "doc.pdf")
        #expect(attachment.content == "")
    }

    @Test("Very long filename")
    func testLongFilename() {
        let long = String(repeating: "a", count: 500)
        let attachment = EmailAttachment(content: "base64", filename: long)
        #expect(attachment.filename?.count == 500)
    }

    @Test("Encode/decode roundtrip")
    func testRoundtrip() throws {
        let original = EmailAttachment(content: "dGVzdA==", filename: "test.txt")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(EmailAttachment.self, from: data)
        #expect(decoded.content == original.content)
        #expect(decoded.filename == original.filename)
    }

    @Test("Encode/decode path-based roundtrip")
    func testPathRoundtrip() throws {
        let original = EmailAttachment(filename: "report.pdf", path: "https://example.com/r.pdf")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(EmailAttachment.self, from: data)
        #expect(decoded.path == original.path)
        #expect(decoded.filename == original.filename)
    }
}

// MARK: - EmailTag Tests

@Suite("EmailTag Tests")
struct EmailTagTests {

    @Test("Name only")
    func testNameOnly() {
        let tag = EmailTag(name: "category")
        #expect(tag.name == "category")
        #expect(tag.value == nil)
    }

    @Test("Name and value")
    func testNameAndValue() {
        let tag = EmailTag(name: "category", value: "welcome")
        #expect(tag.name == "category")
        #expect(tag.value == "welcome")
    }

    @Test("Empty value string")
    func testEmptyValue() {
        let tag = EmailTag(name: "category", value: "")
        #expect(tag.value == "")
    }

    @Test("Encode/decode roundtrip")
    func testRoundtrip() throws {
        let original = EmailTag(name: "category", value: "test-value")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(EmailTag.self, from: data)
        #expect(decoded.name == original.name)
        #expect(decoded.value == original.value)
    }
}

// MARK: - ResendAudience Tests

@Suite("ResendAudience Tests")
struct ResendAudienceTests {

    @Test("Basic initialization")
    func testBasic() {
        let audience = ResendAudience(id: "aud_1", name: "Newsletter")
        #expect(audience.id == "aud_1")
        #expect(audience.name == "Newsletter")
        #expect(audience.object == nil)
        #expect(audience.createdAt == nil)
    }

    @Test("Full initialization")
    func testFull() {
        let audience = ResendAudience(object: "audience", id: "aud_1", name: "Newsletter", createdAt: "2025-01-01T00:00:00Z")
        #expect(audience.object == "audience")
        #expect(audience.createdAt == "2025-01-01T00:00:00Z")
    }

    @Test("Decoding from JSON")
    func testDecoding() throws {
        let data = TestData.audienceJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        let audience = try decoder.decode(ResendAudience.self, from: data)
        #expect(audience.id == "audience_123")
        #expect(audience.name == "Newsletter")
    }

    @Test("Encode/decode roundtrip")
    func testRoundtrip() throws {
        let original = ResendAudience(object: "audience", id: "aud_1", name: "Newsletter", createdAt: "2025-01-01T00:00:00Z")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ResendAudience.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
    }
}

// MARK: - ResendAPIKey Tests

@Suite("ResendAPIKey Tests")
struct ResendAPIKeyTests {

    @Test("Full initialization")
    func testFull() {
        let key = ResendAPIKey(id: "key_1", token: "re_abc123")
        #expect(key.id == "key_1")
        #expect(key.token == "re_abc123")
    }

    @Test("Decoding from JSON")
    func testDecoding() throws {
        let data = TestData.apiKeyJSON.data(using: .utf8)!
        let key = try JSONDecoder().decode(ResendAPIKey.self, from: data)
        #expect(key.id == "key_123")
        #expect(key.token == "re_test_token_abc123")
    }
}

// MARK: - ResendAPIKeyListItem Tests

@Suite("ResendAPIKeyListItem Tests")
struct ResendAPIKeyListItemTests {

    @Test("Basic initialization")
    func testBasic() {
        let item = ResendAPIKeyListItem(id: "key_1", name: "Prod")
        #expect(item.id == "key_1")
        #expect(item.name == "Prod")
        #expect(item.createdAt == nil)
    }

    @Test("Decoding from JSON")
    func testDecoding() throws {
        let data = TestData.apiKeyListJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        let list = try decoder.decode(ResendListResponse<ResendAPIKeyListItem>.self, from: data)
        #expect(list.data.count == 1)
        #expect(list.data[0].name == "Production Key")
    }

    @Test("Encode/decode roundtrip")
    func testRoundtrip() throws {
        let original = ResendAPIKeyListItem(id: "key_1", name: "Prod", createdAt: "2025-01-01T00:00:00Z")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ResendAPIKeyListItem.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
    }
}

// MARK: - ResendBroadcast Tests

@Suite("ResendBroadcast Tests")
struct ResendBroadcastTests {

    @Test("Basic initialization")
    func testBasic() {
        let bc = ResendBroadcast(id: "bc_1")
        #expect(bc.id == "bc_1")
    }

    @Test("Decoding from JSON")
    func testDecoding() throws {
        let data = TestData.broadcastJSON.data(using: .utf8)!
        let bc = try JSONDecoder().decode(ResendBroadcast.self, from: data)
        #expect(bc.id == "broadcast_123")
        #expect(bc.name == "Newsletter")
        #expect(bc.status == "draft")
    }

    @Test("Encode/decode roundtrip")
    func testRoundtrip() throws {
        let original = ResendBroadcast(
            object: "broadcast", id: "bc_1", name: "Test", audienceId: "aud_1",
            from: "test@test.com", subject: "Hello", replyTo: ["reply@test.com"],
            previewText: "Preview", status: "draft", createdAt: "2025-01-01T00:00:00Z",
            scheduledAt: nil, sentAt: nil
        )
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(ResendBroadcast.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
        #expect(decoded.from == original.from)
    }

    @Test("Decoding with null replyTo")
    func testDecodingWithNullReplyTo() throws {
        let json = """
        {"id": "bc_1", "reply_to": null}
        """
        let data = json.data(using: .utf8)!
        let bc = try JSONDecoder().decode(ResendBroadcast.self, from: data)
        #expect(bc.id == "bc_1")
        #expect(bc.replyTo == nil)
    }
}

// MARK: - ResendContact Tests

@Suite("ResendContact Tests")
struct ResendContactTests {

    @Test("Basic initialization")
    func testBasic() {
        let contact = ResendContact(id: "c_1", email: "user@test.com")
        #expect(contact.id == "c_1")
        #expect(contact.email == "user@test.com")
        #expect(contact.firstName == nil)
        #expect(contact.lastName == nil)
    }

    @Test("Decoding from JSON")
    func testDecoding() throws {
        let data = TestData.contactJSON.data(using: .utf8)!
        let contact = try JSONDecoder().decode(ResendContact.self, from: data)
        #expect(contact.id == "contact_123")
        #expect(contact.email == "user@test.com")
        #expect(contact.firstName == "John")
        #expect(contact.unsubscribed == false)
    }

    @Test("Encode/decode roundtrip")
    func testRoundtrip() throws {
        let original = ResendContact(
            object: "contact", id: "c_1", email: "user@test.com",
            firstName: "John", lastName: "Doe", createdAt: "2025-01-01T00:00:00Z",
            unsubscribed: false
        )
        // Models with custom CodingKeys use plain JSONEncoder/Decoder (no snake_case strategy)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ResendContact.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.email == original.email)
        #expect(decoded.firstName == original.firstName)
    }
}

// MARK: - ResendWebhook Tests

@Suite("ResendWebhook Tests")
struct ResendWebhookTests {

    @Test("Basic initialization")
    func testBasic() {
        let wh = ResendWebhook(id: "wh_1")
        #expect(wh.id == "wh_1")
        #expect(wh.endpoint == nil)
        #expect(wh.events == nil)
    }

    @Test("Encode/decode roundtrip with all fields")
    func testRoundtrip() throws {
        let original = ResendWebhook(
            object: "webhook", id: "wh_1", endpoint: "https://example.com/hook",
            events: ["email.sent", "email.bounced"], signingSecret: "whsec_abc",
            createdAt: "2025-01-01T00:00:00Z", disabled: false,
            updatedAt: "2025-01-02T00:00:00Z"
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ResendWebhook.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.endpoint == original.endpoint)
        #expect(decoded.events == original.events)
        #expect(decoded.disabled == original.disabled)
    }

    @Test("Decoding from JSON")
    func testDecoding() throws {
        let json = """
        {
            "id": "wh_1",
            "endpoint": "https://example.com/hook",
            "events": ["email.sent"],
            "signing_secret": "whsec_secret",
            "disabled": false
        }
        """
        let data = json.data(using: .utf8)!
        let wh = try JSONDecoder().decode(ResendWebhook.self, from: data)
        #expect(wh.id == "wh_1")
        #expect(wh.events == ["email.sent"])
        #expect(wh.disabled == false)
    }
}

// MARK: - DNSRecord Tests

@Suite("DNSRecord Tests")
struct DNSRecordTests {

    @Test("Basic initialization")
    func testBasic() {
        let record = DNSRecord(record: "MX", name: "test.com", type: "TXT", value: "v=spf1")
        #expect(record.record == "MX")
        #expect(record.value == "v=spf1")
        #expect(record.priority == nil)
    }

    @Test("With priority")
    func testWithPriority() {
        let record = DNSRecord(record: "MX", name: "test.com", type: "MX", value: "mail.test.com", priority: 10)
        #expect(record.priority == 10)
    }

    @Test("Encode/decode roundtrip")
    func testRoundtrip() throws {
        let original = DNSRecord(record: "SPF", name: "test.com", type: "TXT", ttl: "300", status: "verified", value: "v=spf1 include:resend.com", priority: nil)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DNSRecord.self, from: data)
        #expect(decoded.record == original.record)
        #expect(decoded.value == original.value)
    }
}

// MARK: - ResendEmailResponse Tests

@Suite("ResendEmailResponse Tests")
struct ResendEmailResponseTests {

    @Test("Basic initialization")
    func testBasic() {
        let resp = ResendEmailResponse(id: "email_123")
        #expect(resp.id == "email_123")
    }

    @Test("Decoding from JSON")
    func testDecoding() throws {
        let data = TestData.emailResponseJSON.data(using: .utf8)!
        let resp = try JSONDecoder().decode(ResendEmailResponse.self, from: data)
        #expect(resp.id == "email_123")
    }
}

// MARK: - ResendBroadcastSendResponse Tests

@Suite("ResendBroadcastSendResponse Tests")
struct ResendBroadcastSendResponseTests {

    @Test("Basic initialization")
    func testBasic() {
        let resp = ResendBroadcastSendResponse(id: "send_123")
        #expect(resp.id == "send_123")
    }

    @Test("Decoding from JSON")
    func testDecoding() throws {
        let data = TestData.broadcastSendResponseJSON.data(using: .utf8)!
        let resp = try JSONDecoder().decode(ResendBroadcastSendResponse.self, from: data)
        #expect(resp.id == "send_123")
    }
}

// MARK: - Parameterized Edge Cases

@Suite("ResendEmail Parameterized Edge Cases")
struct ResendEmailParameterizedTests {

    static let extremeSubjects = ["", "a", String(repeating: "x", count: 1000)]
    static let extremeRecipientCounts = [1, 50, 100]

    @Test("Empty from and subject", arguments: ["", "a", "valid@test.com"])
    func emptyFrom(from: String) {
        let email = ResendEmail(from: from, to: ["user@test.com"], subject: "Test", html: nil)
        #expect(email.from == from)
    }

    @Test("Various recipient counts", arguments: [1, 10, 50])
    func recipientCounts(count: Int) {
        let recipients = (0..<count).map { "user\($0)@test.com" }
        let email = ResendEmail(from: "a@b.com", to: recipients, subject: "Test", html: nil)
        #expect(email.to.count == count)
    }

    @Test("Empty attachments array")
    func emptyAttachments() {
        let email = ResendEmail(from: "a@b.com", to: ["user@test.com"], subject: "Test", attachments: [])
        #expect(email.attachments != nil)
        #expect(email.attachments?.isEmpty == true)
    }

    @Test("Empty tags array")
    func emptyTags() {
        let email = ResendEmail(from: "a@b.com", to: ["user@test.com"], subject: "Test", tags: [])
        #expect(email.tags != nil)
        #expect(email.tags?.isEmpty == true)
    }

    @Test("Empty headers dictionary")
    func emptyHeaders() {
        let email = ResendEmail(from: "a@b.com", to: ["user@test.com"], subject: "Test", headers: [:])
        #expect(email.headers != nil)
        #expect(email.headers?.isEmpty == true)
    }

    @Test("JSON with null optional fields")
    func nullOptionals() throws {
        let json = """
        {"from": "a@b.com", "to": ["user@test.com"], "subject": "Test", "bcc": null, "cc": null}
        """
        let data = json.data(using: .utf8)!
        let email = try JSONDecoder().decode(ResendEmail.self, from: data)
        #expect(email.bcc == nil)
        #expect(email.cc == nil)
    }

    @Test("JSON with extra unknown keys")
    func extraKeys() throws {
        let json = """
        {"from": "a@b.com", "to": ["user@test.com"], "subject": "Test", "unknown_key": "ignored"}
        """
        let data = json.data(using: .utf8)!
        let email = try JSONDecoder().decode(ResendEmail.self, from: data)
        #expect(email.from == "a@b.com")
    }

    @Test("Emoji in subject and content")
    func emojiContent() {
        let email = ResendEmail(from: "a@b.com", to: ["user@test.com"], subject: "Hello 👋", html: "<p>🔥</p>")
        #expect(email.subject == "Hello 👋")
        #expect(email.html == "<p>🔥</p>")
    }

    @Test("Very long html body")
    func longHtml() {
        let longHtml = "<p>" + String(repeating: "a", count: 10000) + "</p>"
        let email = ResendEmail(from: "a@b.com", to: ["user@test.com"], subject: "Test", html: longHtml)
        #expect(email.html?.count == 10007)
    }
}

// MARK: - ResendListResponse Parameterized Tests

@Suite("ResendListResponse Parameterized Tests")
struct ResendListResponseParameterizedTests {

    struct TestItem: Codable, Sendable {
        let id: String
    }

    @Test("Various data counts", arguments: [0, 1, 10])
    func dataCounts(count: Int) throws {
        let items = (0..<count).map { #"{"id": "item_\#($0)"}"# }.joined(separator: ",")
        let json = """
        {"object": "list", "data": [\(items)], "has_more": false}
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let response = try decoder.decode(ResendListResponse<TestItem>.self, from: data)
        #expect(response.data.count == count)
    }

    @Test("Has more flag", arguments: [true, false])
    func hasMoreFlag(flag: Bool) throws {
        let json = """
        {"object": "list", "data": [], "has_more": \(flag)}
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(ResendListResponse<TestItem>.self, from: data)
        #expect(response.hasMore == flag)
    }
}

// MARK: - ResendRetrieveError Edge Cases

@Suite("ResendRetrieveError Tests")
struct ResendRetrieveErrorTests {

    @Test("Initialization")
    func testInit() {
        let error = ResendRetrieveError(statusCode: 500, message: "Server error", name: "server_error")
        #expect(error.statusCode == 500)
        #expect(error.message == "Server error")
        #expect(error.name == "server_error")
    }

    @Test("Decoding with snake_case keys")
    func testDecoding() throws {
        let json = """
        {"statusCode": 403, "message": "Forbidden", "name": "permission_error"}
        """
        let data = json.data(using: .utf8)!
        let error = try JSONDecoder().decode(ResendRetrieveError.self, from: data)
        #expect(error.statusCode == 403)
        #expect(error.name == "permission_error")
    }

    @Test("Encode/decode roundtrip")
    func testRoundtrip() throws {
        let original = ResendRetrieveError(statusCode: 429, message: "Rate limited", name: "rate_limit")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ResendRetrieveError.self, from: data)
        #expect(decoded.statusCode == original.statusCode)
        #expect(decoded.message == original.message)
    }
}

// MARK: - HTTPRequest/HTTPResponse Tests

@Suite("HTTPRequest and HTTPResponse Tests")
struct HTTPTypesTests {

    @Test("HTTPRequest initialization")
    func testRequest() {
        let req = HTTPRequest(url: "https://api.test.com", method: .POST, headers: ["Auth": "Bearer x"], body: Data())
        #expect(req.url == "https://api.test.com")
        #expect(req.method == .POST)
        #expect(req.headers["Auth"] == "Bearer x")
    }

    @Test("HTTPResponse initialization")
    func testResponse() {
        let resp = HTTPResponse(statusCode: 200, headers: ["Content-Type": "application/json"], body: Data())
        #expect(resp.statusCode == 200)
        #expect(resp.headers["Content-Type"] == "application/json")
    }

    @Test("HTTPResponse with empty body")
    func testEmptyBody() {
        let resp = HTTPResponse(statusCode: 204)
        #expect(resp.body == nil)
    }

    @Test("HTTPMethod raw values")
    func testMethodRawValues() {
        #expect(HTTPMethod.GET.rawValue == "GET")
        #expect(HTTPMethod.POST.rawValue == "POST")
        #expect(HTTPMethod.PATCH.rawValue == "PATCH")
        #expect(HTTPMethod.DELETE.rawValue == "DELETE")
        #expect(HTTPMethod.PUT.rawValue == "PUT")
    }
}
