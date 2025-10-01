//
//  BroadcastClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation
import ResendCore

final class BroadcastClient: BroadcastClientProtocol {
    private let apiKey: String
    private let httpClient: HTTPClientProtocol
    private let baseURL: String

    init(apiKey: String, httpClient: HTTPClientProtocol, baseURL: String) {
        self.apiKey = apiKey
        self.httpClient = httpClient
        self.baseURL = baseURL
    }

    public func create(audienceId: String, from: String, subject: String, replyTo: [String]?, html: String?, text: String?, name: String?) async throws -> ResendBroadcast {
        var payload: [String: Any] = [
            "audience_id": audienceId,
            "from": from,
            "subject": subject
        ]

        if let replyTo = replyTo {
            payload["reply_to"] = replyTo
        }
        if let html = html {
            payload["html"] = html
        }
        if let text = text {
            payload["text"] = text
        }
        if let name = name {
            payload["name"] = name
        }

        let body = try JSONSerialization.data(withJSONObject: payload)
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "broadcasts",
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

        return try ResendClient.decoder.decode(ResendBroadcast.self, from: body)
    }

    public func get(id: String) async throws -> ResendBroadcast {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "broadcasts/\(id)"
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

        return try ResendClient.decoder.decode(ResendBroadcast.self, from: body)
    }

    public func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendBroadcast> {
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

        let path = queryItems.isEmpty ? "broadcasts" : "broadcasts?\(queryItems.joined(separator: "&"))"
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

        return try ResendClient.decoder.decode(ResendListResponse<ResendBroadcast>.self, from: body)
    }

    public func update(id: String, audienceId: String?, from: String?, subject: String?, replyTo: [String]?, html: String?, text: String?, name: String?) async throws -> ResendBroadcast {
        var payload: [String: Any] = [:]

        if let audienceId = audienceId {
            payload["audience_id"] = audienceId
        }
        if let from = from {
            payload["from"] = from
        }
        if let subject = subject {
            payload["subject"] = subject
        }
        if let replyTo = replyTo {
            payload["reply_to"] = replyTo
        }
        if let html = html {
            payload["html"] = html
        }
        if let text = text {
            payload["text"] = text
        }
        if let name = name {
            payload["name"] = name
        }

        let body = try JSONSerialization.data(withJSONObject: payload)
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .PATCH,
            path: "broadcasts/\(id)",
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

        return try ResendClient.decoder.decode(ResendBroadcast.self, from: body)
    }

    public func send(id: String, scheduledAt: String?) async throws -> ResendBroadcastSendResponse {
        var payload: [String: Any] = [:]
        if let scheduledAt = scheduledAt {
            payload["scheduled_at"] = scheduledAt
        }

        let body = payload.isEmpty ? nil : try JSONSerialization.data(withJSONObject: payload)
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "broadcasts/\(id)/send",
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

        return try ResendClient.decoder.decode(ResendBroadcastSendResponse.self, from: body)
    }

    public func delete(id: String) async throws -> ResendDeleteResponse {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .DELETE,
            path: "broadcasts/\(id)"
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
