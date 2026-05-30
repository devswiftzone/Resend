import Testing
import Foundation
@testable import ResendCore
@testable import ResendKit

@Suite("WebhookClient Tests")
struct WebhookClientTests {

    @Test("Create webhook successfully")
    func testCreateWebhook() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: """
        {"object": "webhook", "id": "wh_123", "signing_secret": "whsec_test"}
        """)

        let client = ResendClient(apiKey: "test_key", httpClient: mock)
        let webhook = try await client.webhooks.create(
            endpoint: "https://example.com/handler",
            events: ["email.sent"]
        )

        #expect(webhook.id == "wh_123")
        #expect(webhook.signingSecret == "whsec_test")
        #expect(mock.requests.count == 1)
    }

    @Test("Get webhook successfully")
    func testGetWebhook() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: """
        {"object": "webhook", "id": "wh_123", "endpoint": "https://example.com/handler", "events": ["email.sent"], "disabled": false}
        """)

        let client = ResendClient(apiKey: "test_key", httpClient: mock)
        let webhook = try await client.webhooks.get(id: "wh_123")

        #expect(webhook.id == "wh_123")
        #expect(webhook.endpoint == "https://example.com/handler")
        #expect(webhook.events == ["email.sent"])
        #expect(webhook.disabled == false)
    }

    @Test("List webhooks successfully")
    func testListWebhooks() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: """
        {"object": "list", "data": [{"id": "wh_1", "endpoint": "https://a.com/handler", "events": ["email.sent"]}], "has_more": false}
        """)

        let client = ResendClient(apiKey: "test_key", httpClient: mock)
        let list = try await client.webhooks.list(limit: nil, after: nil, before: nil)

        #expect(list.data.count == 1)
        #expect(list.data[0].id == "wh_1")
    }

    @Test("Update webhook successfully")
    func testUpdateWebhook() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: """
        {"object": "webhook", "id": "wh_123", "endpoint": "https://updated.com/handler", "disabled": true}
        """)

        let client = ResendClient(apiKey: "test_key", httpClient: mock)
        let webhook = try await client.webhooks.update(
            id: "wh_123",
            endpoint: "https://updated.com/handler",
            events: nil,
            disabled: true
        )

        #expect(webhook.id == "wh_123")
        #expect(webhook.endpoint == "https://updated.com/handler")
        #expect(webhook.disabled == true)
    }

    @Test("Delete webhook successfully")
    func testDeleteWebhook() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: """
        {"object": "webhook", "id": "wh_123", "deleted": true}
        """)

        let client = ResendClient(apiKey: "test_key", httpClient: mock)
        let response = try await client.webhooks.delete(id: "wh_123")

        #expect(response.deleted == true)
        #expect(response.id == "wh_123")
    }

    @Test("List webhooks with pagination")
    func testListWebhooksWithPagination() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: """
        {"object": "list", "data": [{"id": "wh_1", "endpoint": "https://a.com/handler", "events": ["email.sent"]}], "has_more": true}
        """)
        mock.addResponse(statusCode: 200, body: """
        {"object": "list", "data": [{"id": "wh_2", "endpoint": "https://b.com/handler", "events": ["email.delivered"]}], "has_more": false}
        """)

        let client = ResendClient(apiKey: "test_key", httpClient: mock)
        let seq = client.webhooks.listAll(limit: nil)

        var items: [ResendWebhook] = []
        for try await item in seq {
            items.append(item)
        }

        #expect(items.count == 2)
        #expect(items[0].id == "wh_1")
        #expect(items[1].id == "wh_2")
        #expect(mock.requests.count == 2)
    }
}
