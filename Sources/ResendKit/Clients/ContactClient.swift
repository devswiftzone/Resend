//
//  ContactClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation
import ResendCore

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
        var payload: [String: Any] = ["email": email]
        if let firstName = firstName {
            payload["first_name"] = firstName
        }
        if let lastName = lastName {
            payload["last_name"] = lastName
        }
        if let unsubscribed = unsubscribed {
            payload["unsubscribed"] = unsubscribed
        }

        let body = try JSONSerialization.data(withJSONObject: payload)
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "audiences/\(audienceId)/contacts",
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

        return try ResendClient.decoder.decode(ResendContact.self, from: body)
    }

    public func get(audienceId: String, identifier: String) async throws -> ResendContact {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "audiences/\(audienceId)/contacts/\(identifier)"
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

        return try ResendClient.decoder.decode(ResendContact.self, from: body)
    }

    public func list(audienceId: String, limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendContact> {
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

        let basePath = "audiences/\(audienceId)/contacts"
        let path = queryItems.isEmpty ? basePath : "\(basePath)?\(queryItems.joined(separator: "&"))"
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

        return try ResendClient.decoder.decode(ResendListResponse<ResendContact>.self, from: body)
    }

    public func update(audienceId: String, identifier: String, firstName: String?, lastName: String?, unsubscribed: Bool?) async throws -> ResendContact {
        var payload: [String: Any] = [:]
        if let firstName = firstName {
            payload["first_name"] = firstName
        }
        if let lastName = lastName {
            payload["last_name"] = lastName
        }
        if let unsubscribed = unsubscribed {
            payload["unsubscribed"] = unsubscribed
        }

        let body = try JSONSerialization.data(withJSONObject: payload)
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .PATCH,
            path: "audiences/\(audienceId)/contacts/\(identifier)",
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

        return try ResendClient.decoder.decode(ResendContact.self, from: body)
    }

    public func delete(audienceId: String, identifier: String) async throws -> ResendDeleteResponse {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .DELETE,
            path: "audiences/\(audienceId)/contacts/\(identifier)"
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
