//
//  IntegrationTests.swift
//  ResendTests
//
//  Created by Test Suite
//

import Testing
import Foundation
@testable import ResendKit
@testable import ResendCore

@Suite("Integration Tests")
struct IntegrationTests {

    /// Test complete flow: create audience, add contact, send broadcast
    @Test("Complete workflow")
    func testCompleteWorkflow() async throws {
        let mockClient = MockHTTPClient()
        let resend = ResendClient(apiKey: "test_key", httpClient: mockClient)

        // Step 1: Create audience
        mockClient.addResponse(statusCode: 200, body: TestData.audienceJSON)
        let audience = try await resend.audiences.create(name: "Test Audience")
        #expect(audience.id == "audience_123")

        // Step 2: Add contact
        mockClient.addResponse(statusCode: 200, body: TestData.contactJSON)
        let contact = try await resend.contacts.create(
            audienceId: audience.id,
            email: "user@test.com",
            firstName: "John",
            lastName: "Doe",
            unsubscribed: false
        )
        #expect(contact.email == "user@test.com")

        // Step 3: Create broadcast
        mockClient.addResponse(statusCode: 200, body: TestData.broadcastJSON)
        let broadcast = try await resend.broadcasts.create(
            audienceId: audience.id,
            from: "newsletter@test.com",
            subject: "Test",
            replyTo: nil,
            html: "<p>Test</p>",
            text: nil,
            name: "Test Broadcast"
        )
        #expect(broadcast.id == "broadcast_123")

        // Step 4: Send broadcast
        mockClient.addResponse(statusCode: 200, body: TestData.broadcastSendResponseJSON)
        let sent = try await resend.broadcasts.send(id: broadcast.id, scheduledAt: nil)
        #expect(sent.id == "send_123")

        // Verify all requests were made
        #expect(mockClient.requests.count == 4)
    }

    /// Test domain creation and verification workflow
    @Test("Domain workflow")
    func testDomainWorkflow() async throws {
        let mockClient = MockHTTPClient()
        let resend = ResendClient(apiKey: "test_key", httpClient: mockClient)

        // Create domain
        mockClient.addResponse(statusCode: 200, body: TestData.domainJSON)
        let domain = try await resend.domains.create(
            name: "test.com",
            region: "us-east-1",
            customReturnPath: nil
        )
        #expect(domain.id == "domain_123")

        // Verify domain
        mockClient.addResponse(statusCode: 200, body: TestData.domainJSON)
        let verified = try await resend.domains.verify(id: domain.id)
        #expect(verified.status == "verified")

        // Update settings
        mockClient.addResponse(statusCode: 200, body: TestData.domainJSON)
        let updated = try await resend.domains.update(
            id: domain.id,
            clickTracking: true,
            openTracking: true,
            tls: "enforced"
        )
        #expect(updated.id == domain.id)

        #expect(mockClient.requests.count == 3)
    }

    /// Test error handling across different clients
    @Test("Error handling across clients")
    func testErrorHandlingAcrossClients() async throws {
        let mockClient = MockHTTPClient()
        let resend = ResendClient(apiKey: "test_key", httpClient: mockClient)

        let errorJSON = """
        {
            "statusCode": 401,
            "message": "Invalid API key",
            "name": "unauthorized"
        }
        """

        // Test email client error
        mockClient.addResponse(statusCode: 401, body: errorJSON)
        await #expect(throws: ResendRetrieveError.self) {
            let email = ResendEmail(
                from: "test@test.com",
                to: ["user@test.com"],
                subject: "Test",
                html: "<p>Test</p>"
            )

            return try await resend.email.send(email: email)
        }

        // Test domain client error
        mockClient.addResponse(statusCode: 401, body: errorJSON)
        await #expect(throws: ResendRetrieveError.self) {
            try await resend.domains.get(id: "domain_123")
        }
    }

    /// Test pagination workflow
    @Test("Pagination workflow")
    func testPaginationWorkflow() async throws {
        let mockClient = MockHTTPClient()
        let resend = ResendClient(apiKey: "test_key", httpClient: mockClient)

        // First page
        let page1JSON = """
        {
            "object": "list",
            "data": [
                {"id": "domain_1", "name": "test1.com", "status": "verified", "created_at": "2025-01-01T00:00:00Z", "region": "us-east-1"},
                {"id": "domain_2", "name": "test2.com", "status": "verified", "created_at": "2025-01-01T00:00:00Z", "region": "us-east-1"}
            ]
        }
        """
        mockClient.addResponse(statusCode: 200, body: page1JSON)

        let page1 = try await resend.domains.list(limit: 2, after: nil, before: nil)
        #expect(page1.data.count == 2)
        #expect(page1.hasMore == false)

        // Second page
        let page2JSON = """
        {
            "object": "list",
            "data": [
                {"id": "domain_3", "name": "test3.com", "status": "verified", "created_at": "2025-01-01T00:00:00Z", "region": "us-east-1"}
            ]
        }
        """
        mockClient.addResponse(statusCode: 200, body: page2JSON)

        let page2 = try await resend.domains.list(limit: 2, after: "domain_2", before: nil)
        #expect(page2.data.count == 1)
        #expect(page2.hasMore == false)
    }
}
