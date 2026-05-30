import Foundation
import ResendCore

private struct CreateWebhookRequest: Encodable {
    let endpoint: String
    let events: [String]
}

private struct UpdateWebhookRequest: Encodable {
    let endpoint: String?
    let events: [String]?
    let disabled: Bool?
}

final class WebhookClient: WebhookClientProtocol {
    private let apiKey: String
    private let httpClient: HTTPClientProtocol
    private let baseURL: String

    init(apiKey: String, httpClient: HTTPClientProtocol, baseURL: String) {
        self.apiKey = apiKey
        self.httpClient = httpClient
        self.baseURL = baseURL
    }

    public func create(endpoint: String, events: [String]) async throws -> ResendWebhook {
        let body = try ResendClient.encoder.encode(CreateWebhookRequest(endpoint: endpoint, events: events))
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "webhooks",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func get(id: String) async throws -> ResendWebhook {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "webhooks/\(id)"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func listAll(limit: Int? = nil) -> PaginatedSequence<ResendWebhook> {
        PaginatedSequence { cursor in
            let response = try await self.list(limit: limit, after: cursor, before: nil)
            let nextCursor = response.data.last?.id
            return (response.data, response.hasMore, nextCursor)
        }
    }

    public func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendWebhook> {
        var query: [URLQueryItem] = []
        if let limit = limit { query.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let after = after { query.append(URLQueryItem(name: "after", value: after)) }
        if let before = before { query.append(URLQueryItem(name: "before", value: before)) }

        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "webhooks",
            query: query
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func update(id: String, endpoint: String?, events: [String]?, disabled: Bool?) async throws -> ResendWebhook {
        let body = try ResendClient.encoder.encode(UpdateWebhookRequest(endpoint: endpoint, events: events, disabled: disabled))
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .PATCH,
            path: "webhooks/\(id)",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func delete(id: String) async throws -> ResendDeleteResponse {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .DELETE,
            path: "webhooks/\(id)"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }
}
