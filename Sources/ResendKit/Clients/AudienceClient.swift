//
//  AudienceClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation
import ResendCore

private struct CreateAudienceRequest: Encodable {
    let name: String
}

final class AudienceClient: AudienceClientProtocol {
    private let apiKey: String
    private let httpClient: HTTPClientProtocol
    private let baseURL: String

    init(apiKey: String, httpClient: HTTPClientProtocol, baseURL: String) {
        self.apiKey = apiKey
        self.httpClient = httpClient
        self.baseURL = baseURL
    }

    public func create(name: String) async throws -> ResendAudience {
        let body = try ResendClient.encoder.encode(CreateAudienceRequest(name: name))
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "audiences",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func get(id: String) async throws -> ResendAudience {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "audiences/\(id)"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func listAll(limit: Int? = nil) -> PaginatedSequence<ResendAudience> {
        PaginatedSequence { cursor in
            let response = try await self.list(limit: limit, after: cursor, before: nil)
            let nextCursor = response.data.last?.id
            return (response.data, response.hasMore, nextCursor)
        }
    }

    public func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendAudience> {
        var query: [URLQueryItem] = []
        if let limit = limit { query.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let after = after { query.append(URLQueryItem(name: "after", value: after)) }
        if let before = before { query.append(URLQueryItem(name: "before", value: before)) }

        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "audiences",
            query: query
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func delete(id: String) async throws -> ResendDeleteResponse {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .DELETE,
            path: "audiences/\(id)"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }
}
