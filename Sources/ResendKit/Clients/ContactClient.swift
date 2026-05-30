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
