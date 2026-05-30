//
//  DomainClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation
import ResendCore

final class DomainClient: DomainClientProtocol {
    private let apiKey: String
    private let httpClient: HTTPClientProtocol
    private let baseURL: String

    init(apiKey: String, httpClient: HTTPClientProtocol, baseURL: String) {
        self.apiKey = apiKey
        self.httpClient = httpClient
        self.baseURL = baseURL
    }

    public func create(name: String, region: String?, customReturnPath: String?) async throws -> ResendDomain {
        var payload: [String: Any] = ["name": name]
        if let region = region {
            payload["region"] = region
        }
        if let customReturnPath = customReturnPath {
            payload["custom_return_path"] = customReturnPath
        }

        let body = try JSONSerialization.data(withJSONObject: payload)
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "domains",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func get(id: String) async throws -> ResendDomain {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "domains/\(id)"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendDomain> {
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

        let path = queryItems.isEmpty ? "domains" : "domains?\(queryItems.joined(separator: "&"))"
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: path
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func verify(id: String) async throws -> ResendDomain {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "domains/\(id)/verify"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func update(id: String, clickTracking: Bool?, openTracking: Bool?, tls: String?) async throws -> ResendDomain {
        var payload: [String: Any] = [:]
        if let clickTracking = clickTracking {
            payload["click_tracking"] = clickTracking
        }
        if let openTracking = openTracking {
            payload["open_tracking"] = openTracking
        }
        if let tls = tls {
            payload["tls"] = tls
        }

        let body = try JSONSerialization.data(withJSONObject: payload)
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .PATCH,
            path: "domains/\(id)",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func delete(id: String) async throws -> ResendDeleteResponse {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .DELETE,
            path: "domains/\(id)"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }
}
