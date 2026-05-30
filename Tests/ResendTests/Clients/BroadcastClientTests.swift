//
//  BroadcastClientTests.swift
//  ResendTests
//
//  Created by Test Suite
//

import Testing
import Foundation
@testable import ResendKit
@testable import ResendCore

@Suite("BroadcastClient Tests")
struct BroadcastClientTests {

    @Test("Create broadcast successfully")
    func testCreateBroadcastSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.broadcastJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let broadcast = try await resendClient.broadcasts.create(
            audienceId: "audience_123",
            from: "newsletter@test.com",
            subject: "Test Newsletter",
            replyTo: ["support@test.com"],
            html: "<p>Newsletter content</p>",
            text: "Newsletter content",
            name: "Test Campaign"
        )

        #expect(broadcast.id == "broadcast_123")
        #expect(broadcast.name == "Newsletter")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .POST)
        #expect(request.url.contains("/broadcasts"))
    }

    @Test("Get broadcast successfully")
    func testGetBroadcastSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.broadcastJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let broadcast = try await resendClient.broadcasts.get(id: "broadcast_123")

        #expect(broadcast.id == "broadcast_123")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .GET)
        #expect(request.url.contains("/broadcasts/broadcast_123"))
    }

    @Test("List broadcasts successfully")
    func testListBroadcastsSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        let listJSON = """
        {
            "object": "list",
            "data": [
                {
                    "id": "broadcast_1",
                    "name": "Newsletter",
                    "status": "draft"
                }
            ],
            "has_more": false
        }
        """
        mockHTTPClient.addResponse(statusCode: 200, body: listJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.broadcasts.list(
            limit: 10,
            after: nil,
            before: nil
        )

        #expect(response.data.count == 1)

        let request = mockHTTPClient.requests[0]
        #expect(request.url.contains("/broadcasts"))
    }

    @Test("Update broadcast successfully")
    func testUpdateBroadcastSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.broadcastJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let broadcast = try await resendClient.broadcasts.update(
            id: "broadcast_123",
            audienceId: nil,
            from: nil,
            subject: "Updated Subject",
            replyTo: nil,
            html: "<p>Updated content</p>",
            text: nil,
            name: "Updated Name"
        )

        #expect(broadcast.id == "broadcast_123")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .PATCH)
    }

    @Test("Send broadcast successfully")
    func testSendBroadcastSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.broadcastSendResponseJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.broadcasts.send(
            id: "broadcast_123",
            scheduledAt: nil
        )

        #expect(response.id == "send_123")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .POST)
        #expect(request.url.contains("/broadcasts/broadcast_123/send"))
    }

    @Test("Send broadcast scheduled")
    func testSendBroadcastScheduled() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.broadcastSendResponseJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.broadcasts.send(
            id: "broadcast_123",
            scheduledAt: "tomorrow at 9am"
        )

        #expect(response.id == "send_123")
    }

    @Test("Delete broadcast successfully")
    func testDeleteBroadcastSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        let deleteJSON = """
        {
            "object": "broadcast",
            "id": "broadcast_123",
            "deleted": true
        }
        """
        mockHTTPClient.addResponse(statusCode: 200, body: deleteJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.broadcasts.delete(id: "broadcast_123")

        #expect(response.deleted == true)

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .DELETE)
    }
}
