//
//  APIKeyClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation
import ResendCore

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
        var payload: [String: Any] = ["name": name]
        if let permission = permission {
            payload["permission"] = permission
        }
        if let domainId = domainId {
            payload["domain_id"] = domainId
        }

        let body = try JSONSerialization.data(withJSONObject: payload)
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "api-keys",
            body: body
        )

        let response = try await httpClient.execute(request)

        guard (200...299).contains(response.statusCode) else {
            if let body = response.body {
                throw try ResendClient.decoder.decode(ResendRetrieveError.self, from: body)
            }
            throw URLError(.badServerResponse)
        }

        guard let body = response.body else {
            throw URLError(.cannotParseResponse)
        }

        return try ResendClient.decoder.decode(ResendAPIKey.self, from: body)
    }

    public func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendAPIKeyListItem> {
        var queryItems: [String] = []
        if let limit = limit {
            queryItems.append("limit=\(limit)")
        }
        if let after = after {
            queryItems.append("after=\(after)")
        }
        if let before = before {
            queryItems.append("before=\(before)")
        }

        let path = queryItems.isEmpty ? "api-keys" : "api-keys?\(queryItems.joined(separator: "&"))"
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: path
        )

        let response = try await httpClient.execute(request)

        guard (200...299).contains(response.statusCode) else {
            if let body = response.body {
                throw try ResendClient.decoder.decode(ResendRetrieveError.self, from: body)
            }
            throw URLError(.badServerResponse)
        }

        guard let body = response.body else {
            throw URLError(.cannotParseResponse)
        }

        return try ResendClient.decoder.decode(ResendListResponse<ResendAPIKeyListItem>.self, from: body)
    }

    public func delete(id: String) async throws {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .DELETE,
            path: "api-keys/\(id)"
        )

        let response = try await httpClient.execute(request)

        guard (200...299).contains(response.statusCode) else {
            if let body = response.body {
                throw try ResendClient.decoder.decode(ResendRetrieveError.self, from: body)
            }
            throw URLError(.badServerResponse)
        }
    }
}
