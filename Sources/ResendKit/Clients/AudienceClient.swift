//
//  AudienceClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation
import ResendCore

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
        let payload = ["name": name]
        let body = try JSONSerialization.data(withJSONObject: payload)

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

    public func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendAudience> {
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

        let path = queryItems.isEmpty ? "audiences" : "audiences?\(queryItems.joined(separator: "&"))"
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: path
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
