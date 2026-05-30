//
//  BroadcastClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation
import ResendCore

private struct CreateBroadcastRequest: Encodable {
    let audienceId: String
    let from: String
    let subject: String
    let replyTo: [String]?
    let html: String?
    let text: String?
    let name: String?
}

private struct UpdateBroadcastRequest: Encodable {
    let audienceId: String?
    let from: String?
    let subject: String?
    let replyTo: [String]?
    let html: String?
    let text: String?
    let name: String?
}

private struct SendBroadcastRequest: Encodable {
    let scheduledAt: String?
}

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
        let body = try ResendClient.encoder.encode(
            CreateBroadcastRequest(
                audienceId: audienceId, from: from, subject: subject,
                replyTo: replyTo, html: html, text: text, name: name
            )
        )
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "broadcasts",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func get(id: String) async throws -> ResendBroadcast {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "broadcasts/\(id)"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendBroadcast> {
        var query: [URLQueryItem] = []
        if let limit = limit { query.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let after = after { query.append(URLQueryItem(name: "after", value: after)) }
        if let before = before { query.append(URLQueryItem(name: "before", value: before)) }

        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "broadcasts",
            query: query
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func update(id: String, audienceId: String?, from: String?, subject: String?, replyTo: [String]?, html: String?, text: String?, name: String?) async throws -> ResendBroadcast {
        let body = try ResendClient.encoder.encode(
            UpdateBroadcastRequest(
                audienceId: audienceId, from: from, subject: subject,
                replyTo: replyTo, html: html, text: text, name: name
            )
        )
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .PATCH,
            path: "broadcasts/\(id)",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func send(id: String, scheduledAt: String?) async throws -> ResendBroadcastSendResponse {
        let body = try ResendClient.encoder.encode(SendBroadcastRequest(scheduledAt: scheduledAt))
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "broadcasts/\(id)/send",
            body: body
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }

    public func delete(id: String) async throws -> ResendDeleteResponse {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .DELETE,
            path: "broadcasts/\(id)"
        )
        return try await httpClient.executeAndDecode(request, decoder: ResendClient.decoder)
    }
}
