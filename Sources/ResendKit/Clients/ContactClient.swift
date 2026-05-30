//
//  ContactClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation
import ResendCore

private struct CreateContactRequest: Encodable {
    let email: String
    let firstName: String?
    let lastName: String?
    let unsubscribed: Bool?
}

private struct UpdateContactRequest: Encodable {
    let firstName: String?
    let lastName: String?
    let unsubscribed: Bool?
}

final class ContactClient: ContactClientProtocol {
    private let apiKey: String
    private let httpClient: HTTPClientProtocol
    private let baseURL: String

    init(apiKey: String, httpClient: HTTPClientProtocol, baseURL: String) {
        self.apiKey = apiKey
        self.httpClient = httpClient
        self.baseURL = baseURL
    }

    public func create(audienceId: String, email: String, firstName: String?, lastName: String?, unsubscribed: Bool?) async throws -> ResendContact {
        let body = try ResendClient.encoder.encode(
            CreateContactRequest(email: email, firstName: firstName, lastName: lastName, unsubscribed: unsubscribed)
        )
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "audiences/\(audienceId)/contacts",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func get(audienceId: String, identifier: String) async throws -> ResendContact {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "audiences/\(audienceId)/contacts/\(identifier)"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func listAll(audienceId: String, limit: Int? = nil) -> PaginatedSequence<ResendContact> {
        PaginatedSequence { cursor in
            let response = try await self.list(audienceId: audienceId, limit: limit, after: cursor, before: nil)
            let nextCursor = response.data.last?.id
            return (response.data, response.hasMore, nextCursor)
        }
    }

    public func list(audienceId: String, limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendContact> {
        var query: [URLQueryItem] = []
        if let limit = limit { query.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let after = after { query.append(URLQueryItem(name: "after", value: after)) }
        if let before = before { query.append(URLQueryItem(name: "before", value: before)) }

        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "audiences/\(audienceId)/contacts",
            query: query
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func update(audienceId: String, identifier: String, firstName: String?, lastName: String?, unsubscribed: Bool?) async throws -> ResendContact {
        let body = try ResendClient.encoder.encode(
            UpdateContactRequest(firstName: firstName, lastName: lastName, unsubscribed: unsubscribed)
        )
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .PATCH,
            path: "audiences/\(audienceId)/contacts/\(identifier)",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func delete(audienceId: String, identifier: String) async throws -> ResendDeleteResponse {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .DELETE,
            path: "audiences/\(audienceId)/contacts/\(identifier)"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }
}
