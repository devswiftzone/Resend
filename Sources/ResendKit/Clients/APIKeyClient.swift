//
//  APIKeyClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation
import ResendCore

private struct CreateAPIKeyRequest: Encodable {
    let name: String
    let permission: String?
    let domainId: String?
}

final class APIKeyClient: APIKeyClientProtocol {
    private let apiKey: String
    private let httpClient: HTTPClientProtocol
    private let baseURL: String

    init(apiKey: String, httpClient: HTTPClientProtocol, baseURL: String) {
        self.apiKey = apiKey
        self.httpClient = httpClient
        self.baseURL = baseURL
    }

    public func create(name: String, permission: String?, domainId: String?) async throws -> ResendAPIKey {
        let body = try ResendClient.encoder.encode(
            CreateAPIKeyRequest(name: name, permission: permission, domainId: domainId)
        )
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "api-keys",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func listAll(limit: Int? = nil) -> PaginatedSequence<ResendAPIKeyListItem> {
        PaginatedSequence { cursor in
            let response = try await self.list(limit: limit, after: cursor, before: nil)
            let nextCursor = response.data.last?.id
            return (response.data, response.hasMore, nextCursor)
        }
    }

    public func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendAPIKeyListItem> {
        var query: [URLQueryItem] = []
        if let limit = limit { query.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let after = after { query.append(URLQueryItem(name: "after", value: after)) }
        if let before = before { query.append(URLQueryItem(name: "before", value: before)) }

        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "api-keys",
            query: query
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func delete(id: String) async throws -> ResendDeleteResponse {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .DELETE,
            path: "api-keys/\(id)"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }
}
