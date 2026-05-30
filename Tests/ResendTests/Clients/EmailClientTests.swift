//
//  EmailClientTests.swift
//  ResendTests
//
//  Created by Test Suite
//

import Testing
import Foundation
@testable import ResendKit
@testable import ResendCore

@Suite("EmailClient Tests")
struct EmailClientTests {

    // MARK: - Send Email Tests

    @Test("Send email successfully")
    func sendEmailSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.emailResponseJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let email = ResendEmail(
            from: "sender@test.com",
            to: ["recipient@test.com"],
            subject: "Test Email",
            html: "<p>Test</p>"
        )

        let response = try await resendClient.email.send(email: email)

        #expect(response.id == "email_123")
        #expect(mockHTTPClient.requests.count == 1)

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .POST)
        #expect(request.url.contains("/emails"))
        #expect(request.headers["Authorization"] == "Bearer test_api_key")
        #expect(request.headers["Content-Type"] == "application/json")
    }

    @Test("Send email with all fields")
    func sendEmailWithAllFields() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.emailResponseJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let email = ResendEmail(
            from: "sender@test.com",
            to: ["recipient@test.com"],
            subject: "Test",
            bcc: ["bcc@test.com"],
            cc: ["cc@test.com"],
            replyTo: ["reply@test.com"],
            html: "<p>Test</p>",
            text: "Test",
            headers: ["X-Custom": "value"],
            tags: [EmailTag(name: "campaign", value: "test")]
        )

        let response = try await resendClient.email.send(email: email)
        #expect(response.id == "email_123")
    }

    @Test("Send email failure with API error")
    func sendEmailFailureWithAPIError() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 400, body: TestData.errorJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let email = ResendEmail(
            from: "invalid",
            to: ["recipient@test.com"],
            subject: "Test",
            html: "<p>Test</p>"
        )

        await #expect(throws: ResendRetrieveError.self) {
            try await resendClient.email.send(email: email)
        }
    }

    @Test("Send email network error")
    func sendEmailNetworkError() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addError(URLError(.notConnectedToInternet))

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let email = ResendEmail(
            from: "sender@test.com",
            to: ["recipient@test.com"],
            subject: "Test",
            html: "<p>Test</p>"
        )

        await #expect(throws: URLError.self) {
            try await resendClient.email.send(email: email)
        }
    }

    // MARK: - Retrieve Email Tests

    @Test("Retrieve email successfully")
    func retrieveEmailSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.emailJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let email = try await resendClient.email.retrieve(id: "email_123")

        #expect(email.id == "email_123")
        #expect(email.from == "sender@test.com")
        #expect(email.to == ["recipient@test.com"])

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .GET)
        #expect(request.url.contains("/emails/email_123"))
    }

    @Test("Retrieve email not found")
    func retrieveEmailNotFound() async throws {
        let mockHTTPClient = MockHTTPClient()
        let errorJSON = """
        {
            "status_code": 404,
            "message": "Email not found",
            "name": "not_found"
        }
        """
        mockHTTPClient.addResponse(statusCode: 404, body: errorJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        await #expect(throws: ResendRetrieveError.self) {
            try await resendClient.email.retrieve(id: "invalid_id")
        }
    }

    // MARK: - Update Email Tests

    @Test("Update email successfully")
    func updateEmailSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.emailResponseJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.email.update(
            id: "email_123",
            scheduledAt: "2025-02-01T10:00:00Z"
        )

        #expect(response.id == "email_123")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .PATCH)
        #expect(request.url.contains("/emails/email_123"))
    }

    // MARK: - Cancel Email Tests

    @Test("Cancel email successfully")
    func cancelEmailSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.emailResponseJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.email.cancel(id: "email_123")

        #expect(response.id == "email_123")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .POST)
        #expect(request.url.contains("/emails/email_123/cancel"))
    }

    // MARK: - Batch Send Tests

    @Test("Send batch emails successfully")
    func sendBatchSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.batchResponseJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let emails = [
            ResendEmail(from: "sender@test.com", to: ["user1@test.com"], subject: "Test 1", html: "<p>1</p>"),
            ResendEmail(from: "sender@test.com", to: ["user2@test.com"], subject: "Test 2", html: "<p>2</p>")
        ]

        let response = try await resendClient.email.sendBatch(emails: emails)

        #expect(response.data.count == 2)
        #expect(response.data[0].id == "email_1")
        #expect(response.data[1].id == "email_2")
        #expect(response.errors?.count == 1)
        #expect(response.errors?[0].index == 2)

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .POST)
        #expect(request.url.contains("/emails/batch"))
    }

    @Test("Send batch with no errors")
    func sendBatchWithNoErrors() async throws {
        let mockHTTPClient = MockHTTPClient()
        let successJSON = """
        {
            "data": [
                {"id": "email_1"},
                {"id": "email_2"}
            ]
        }
        """
        mockHTTPClient.addResponse(statusCode: 200, body: successJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let emails = [
            ResendEmail(from: "sender@test.com", to: ["user1@test.com"], subject: "Test 1", html: "<p>1</p>"),
            ResendEmail(from: "sender@test.com", to: ["user2@test.com"], subject: "Test 2", html: "<p>2</p>")
        ]

        let response = try await resendClient.email.sendBatch(emails: emails)

        #expect(response.data.count == 2)
        #expect(response.errors == nil)
    }
}
