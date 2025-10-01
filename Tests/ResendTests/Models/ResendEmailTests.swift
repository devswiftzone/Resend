//
//  ResendEmailTests.swift
//  ResendTests
//
//  Created by Test Suite
//

import Testing
import Foundation
@testable import ResendCore

@Suite("ResendEmail Tests")
struct ResendEmailTests {

    // MARK: - Initialization Tests

    @Test("Basic email initialization")
    func testBasicInitialization() {
        let email = ResendEmail(
            from: "sender@test.com",
            to: ["recipient@test.com"],
            subject: "Test Subject",
            html: "<p>Test</p>"
        )

        #expect(email.from == "sender@test.com")
        #expect(email.to == ["recipient@test.com"])
        #expect(email.subject == "Test Subject")
        #expect(email.html == "<p>Test</p>")
        #expect(email.object == nil)
        #expect(email.id == nil)
        #expect(email.bcc == nil)
        #expect(email.cc == nil)
    }

    @Test("Full email initialization with all fields")
    func testFullInitialization() {
        let attachment = EmailAttachment(
            content: "base64content",
            filename: "test.pdf",
            path: "test.pdf"
        )

        let tag = EmailTag(name: "category", value: "test")

        let email = ResendEmail(
            object: "email",
            id: "email_123",
            createAt: "2025-01-01T00:00:00Z",
            from: "sender@test.com",
            to: ["recipient@test.com"],
            subject: "Test Subject",
            bcc: ["bcc@test.com"],
            cc: ["cc@test.com"],
            replyTo: ["reply@test.com"],
            html: "<p>Test</p>",
            text: "Test",
            headers: ["X-Custom": "value"],
            attachments: [attachment],
            tags: [tag]
        )

        #expect(email.object == "email")
        #expect(email.id == "email_123")
        #expect(email.createdAt == "2025-01-01T00:00:00Z")
        #expect(email.from == "sender@test.com")
        #expect(email.to == ["recipient@test.com"])
        #expect(email.subject == "Test Subject")
        #expect(email.bcc == ["bcc@test.com"])
        #expect(email.cc == ["cc@test.com"])
        #expect(email.replyTo == ["reply@test.com"])
        #expect(email.html == "<p>Test</p>")
        #expect(email.text == "Test")
        #expect(email.headers?["X-Custom"] == "value")
        #expect(email.attachments?.count == 1)
        #expect(email.tags?.count == 1)
    }

    // MARK: - Encoding Tests

    @Test("Basic email encoding")
    func testBasicEmailEncoding() throws {
        let email = ResendEmail(
            from: "sender@test.com",
            to: ["recipient@test.com"],
            subject: "Test Subject",
            html: "<p>Test</p>"
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(email)

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json != nil)
        #expect(json?["from"] as? String == "sender@test.com")
        #expect(json?["subject"] as? String == "Test Subject")
    }

    @Test("Email encoding with snake_case conversion")
    func testEmailEncodingWithSnakeCase() throws {
        let email = ResendEmail(
            object: "email",
            id: "email_123",
            createAt: "2025-01-01T00:00:00Z",
            from: "sender@test.com",
            to: ["recipient@test.com"],
            subject: "Test",
            replyTo: ["reply@test.com"]
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(email)

        let jsonString = String(data: data, encoding: .utf8)!
        #expect(jsonString.contains("reply_to"))
        #expect(jsonString.contains("created_at"))
    }

    // MARK: - Decoding Tests

    @Test("Email decoding from JSON")
    func testEmailDecoding() throws {
        let json = TestData.emailJSON
        let data = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let email = try decoder.decode(ResendEmail.self, from: data)

        #expect(email.id == "email_123")
        #expect(email.from == "sender@test.com")
        #expect(email.to == ["recipient@test.com"])
        #expect(email.subject == "Test Email")
        #expect(email.html == "<p>Test</p>")
        #expect(email.text == "Test")
    }

    @Test("Email decoding with missing optional fields")
    func testEmailDecodingWithMissingOptionalFields() throws {
        let json = """
        {
            "from": "sender@test.com",
            "to": ["recipient@test.com"],
            "subject": "Test"
        }
        """
        let data = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let email = try decoder.decode(ResendEmail.self, from: data)

        #expect(email.from == "sender@test.com")
        #expect(email.html == nil)
        #expect(email.text == nil)
        #expect(email.bcc == nil)
    }

    // MARK: - Edge Cases

    @Test("Multiple recipients")
    func testMultipleRecipients() {
        let email = ResendEmail(
            from: "sender@test.com",
            to: ["user1@test.com", "user2@test.com", "user3@test.com"],
            subject: "Test",
            html: "<p>Test</p>"
        )

        #expect(email.to.count == 3)
    }

    @Test("Empty optional arrays")
    func testEmptyOptionalArrays() {
        let email = ResendEmail(
            from: "sender@test.com",
            to: ["recipient@test.com"],
            subject: "Test",
            bcc: [],
            cc: [],
            replyTo: []
        )

        #expect(email.bcc != nil)
        #expect(email.bcc?.count == 0)
    }
}
