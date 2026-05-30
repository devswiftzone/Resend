//
//  AudienceClientTests.swift
//  ResendTests
//
//  Created by Test Suite
//

import Testing
import Foundation
@testable import ResendKit
@testable import ResendCore

@Suite("AudienceClient Tests")
struct AudienceClientTests {

    @Test("Create audience successfully")
    func testCreateAudienceSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.audienceJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let audience = try await resendClient.audiences.create(name: "Newsletter")

        #expect(audience.id == "audience_123")
        #expect(audience.name == "Newsletter")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .POST)
        #expect(request.url.contains("/audiences"))
    }

    @Test("Get audience successfully")
    func testGetAudienceSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.audienceJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let audience = try await resendClient.audiences.get(id: "audience_123")

        #expect(audience.id == "audience_123")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .GET)
        #expect(request.url.contains("/audiences/audience_123"))
    }

    @Test("List audiences successfully")
    func testListAudiencesSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.audienceListJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.audiences.list(
            limit: 10,
            after: nil,
            before: nil
        )

        #expect(response.data.count == 1)
        #expect(response.data[0].name == "Newsletter")

        let request = mockHTTPClient.requests[0]
        #expect(request.url.contains("/audiences"))
    }

    @Test("Delete audience successfully")
    func testDeleteAudienceSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        let deleteJSON = """
        {
            "object": "audience",
            "id": "audience_123",
            "deleted": true
        }
        """
        mockHTTPClient.addResponse(statusCode: 200, body: deleteJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.audiences.delete(id: "audience_123")

        #expect(response.id == "audience_123")
        #expect(response.deleted == true)

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .DELETE)
    }
}
