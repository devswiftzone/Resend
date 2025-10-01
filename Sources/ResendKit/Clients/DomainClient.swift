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

        return try ResendClient.decoder.decode(ResendDomain.self, from: body)
    }

    public func get(id: String) async throws -> ResendDomain {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "domains/\(id)"
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

        return try ResendClient.decoder.decode(ResendDomain.self, from: body)
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

        return try ResendClient.decoder.decode(ResendListResponse<ResendDomain>.self, from: body)
    }

    public func verify(id: String) async throws -> ResendDomain {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "domains/\(id)/verify"
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

        return try ResendClient.decoder.decode(ResendDomain.self, from: body)
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

        return try ResendClient.decoder.decode(ResendDomain.self, from: body)
    }

    public func delete(id: String) async throws -> ResendDeleteResponse {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .DELETE,
            path: "domains/\(id)"
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

        return try ResendClient.decoder.decode(ResendDeleteResponse.self, from: body)
    }
}
