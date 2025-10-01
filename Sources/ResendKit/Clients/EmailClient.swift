//
//  EmailClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation
import ResendCore

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

        return try ResendClient.decoder.decode(ResendEmailResponse.self, from: body)
    }

    public func retrieve(id: String) async throws -> ResendEmail {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .GET,
            path: "emails/\(id)"
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

        return try ResendClient.decoder.decode(ResendEmail.self, from: body)
    }

    public func update(id: String, scheduledAt: String) async throws -> ResendEmailResponse {
        let payload = ["scheduled_at": scheduledAt]
        let body = try JSONSerialization.data(withJSONObject: payload)

        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .PATCH,
            path: "emails/\(id)",
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

        return try ResendClient.decoder.decode(ResendEmailResponse.self, from: body)
    }

    public func cancel(id: String) async throws -> ResendEmailResponse {
        let request = ResendClient.buildRequest(
            apiKey: apiKey,
            baseURL: baseURL,
            method: .POST,
            path: "emails/\(id)/cancel"
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

        return try ResendClient.decoder.decode(ResendEmailResponse.self, from: body)
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

        return try ResendClient.decoder.decode(ResendBatchResponse.self, from: body)
    }
}
