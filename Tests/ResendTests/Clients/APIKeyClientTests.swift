//
//  APIKeyClientTests.swift
//  ResendTests
//
//  Created by Test Suite
//

import Testing
import Foundation
@testable import ResendKit
@testable import ResendCore

@Suite("APIKeyClient Tests")
struct APIKeyClientTests {

    // MARK: - Create API Key Tests

    @Test("Create API key successfully")
    func testCreateAPIKeySuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.apiKeyJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let apiKey = try await resendClient.apiKeys.create(
            name: "Production Key",
            permission: "full_access",
            domainId: nil
        )

        #expect(apiKey.id == "key_123")
        #expect(apiKey.token == "re_test_token_abc123")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .POST)
        #expect(request.url.contains("/api-keys"))
    }

    @Test("Create API key with domain restriction")
    func testCreateAPIKeyWithDomainRestriction() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.apiKeyJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let apiKey = try await resendClient.apiKeys.create(
            name: "Domain Sender",
            permission: "sending_access",
            domainId: "domain_123"
        )

        #expect(apiKey.id == "key_123")
    }

    // MARK: - List API Keys Tests

    @Test("List API keys successfully")
    func testListAPIKeysSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.apiKeyListJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.apiKeys.list(
            limit: 10,
            after: nil,
            before: nil
        )

        #expect(response.data.count == 1)
        #expect(response.data[0].name == "Production Key")
        #expect(response.hasMore == false)

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .GET)
        #expect(request.url.contains("/api-keys"))
    }

    // MARK: - Delete API Key Tests

    @Test("Delete API key successfully")
    func testDeleteAPIKeySuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        let deleteJSON = """
        {"object": "api_key", "id": "key_123", "deleted": true}
        """
        mockHTTPClient.addResponse(statusCode: 200, body: deleteJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.apiKeys.delete(id: "key_123")
        #expect(response.deleted == true)
        #expect(response.id == "key_123")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .DELETE)
        #expect(request.url.contains("/api-keys/key_123"))
    }
}
