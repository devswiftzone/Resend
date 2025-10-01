//
//  ContactClientTests.swift
//  ResendTests
//
//  Created by Test Suite
//

import Testing
import Foundation
@testable import ResendKit
@testable import ResendCore

@Suite("ContactClient Tests")
struct ContactClientTests {

    @Test("Create contact successfully")
    func testCreateContactSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.contactJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let contact = try await resendClient.contacts.create(
            audienceId: "audience_123",
            email: "user@test.com",
            firstName: "John",
            lastName: "Doe",
            unsubscribed: false
        )

        #expect(contact.id == "contact_123")
        #expect(contact.email == "user@test.com")
        #expect(contact.firstName == "John")
        #expect(contact.lastName == "Doe")
        #expect(contact.unsubscribed == false)

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .POST)
        #expect(request.url.contains("/audiences/audience_123/contacts"))
    }

    @Test("Get contact successfully")
    func testGetContactSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.contactJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let contact = try await resendClient.contacts.get(
            audienceId: "audience_123",
            identifier: "contact_123"
        )

        #expect(contact.id == "contact_123")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .GET)
        #expect(request.url.contains("/audiences/audience_123/contacts/contact_123"))
    }

    @Test("List contacts successfully")
    func testListContactsSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.contactListJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.contacts.list(
            audienceId: "audience_123",
            limit: 50,
            after: nil,
            before: nil
        )

        #expect(response.data.count == 1)
        #expect(response.data[0].email == "user1@test.com")

        let request = mockHTTPClient.requests[0]
        #expect(request.url.contains("/audiences/audience_123/contacts"))
    }

    @Test("Update contact successfully")
    func testUpdateContactSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.contactJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let contact = try await resendClient.contacts.update(
            audienceId: "audience_123",
            identifier: "contact_123",
            firstName: "Jane",
            lastName: nil,
            unsubscribed: nil
        )

        #expect(contact.id == "contact_123")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .PATCH)
    }

    @Test("Delete contact successfully")
    func testDeleteContactSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        let deleteJSON = """
        {
            "object": "contact",
            "id": "contact_123",
            "deleted": true
        }
        """
        mockHTTPClient.addResponse(statusCode: 200, body: deleteJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.contacts.delete(
            audienceId: "audience_123",
            identifier: "contact_123"
        )

        #expect(response.deleted == true)

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .DELETE)
    }
}
