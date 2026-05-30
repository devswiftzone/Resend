//
//  EmailClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation
import ResendCore

private struct UpdateEmailRequest: Encodable {
    let scheduledAt: String
}

final class EmailClient: EmailClientProtocol {
    private let apiKey: String
    private let httpClient: HTTPClientProtocol
    private let baseURL: String

    init(apiKey: String, httpClient: HTTPClientProtocol, baseURL: String) {
        self.apiKey = apiKey
        self.httpClient = httpClient
        self.baseURL = baseURL
    }

    public func send(email: ResendEmail) async throws -> ResendEmailResponse {
        let body = try ResendClient.encoder.encode(email)
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "emails",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func retrieve(id: String) async throws -> ResendEmail {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "emails/\(id)"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func update(id: String, scheduledAt: String) async throws -> ResendEmailResponse {
        let body = try ResendClient.encoder.encode(UpdateEmailRequest(scheduledAt: scheduledAt))
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .PATCH,
            path: "emails/\(id)",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func cancel(id: String) async throws -> ResendEmailResponse {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "emails/\(id)/cancel"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func sendBatch(emails: [ResendEmail]) async throws -> ResendBatchResponse {
        let body = try ResendClient.encoder.encode(emails)
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "emails/batch",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendEmail> {
        var query: [URLQueryItem] = []
        if let limit = limit { query.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let after = after { query.append(URLQueryItem(name: "after", value: after)) }
        if let before = before { query.append(URLQueryItem(name: "before", value: before)) }

        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "emails",
            query: query
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func listAll(limit: Int?) -> PaginatedSequence<ResendEmail> {
        PaginatedSequence { cursor in
            let response = try await self.list(limit: limit, after: cursor, before: nil)
            let nextCursor = response.data.last?.id
            return (response.data, response.hasMore, nextCursor)
        }
    }
}
