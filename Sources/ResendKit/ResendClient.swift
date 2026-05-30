//
//  ResendClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation
import Logging
import ResendCore

/// Main Resend API client for sending emails and managing resources.
///
/// `ResendClient` is the primary interface for interacting with the Resend API.
/// It provides access to all API endpoints through specialized client properties.
///
/// ## Topics
///
/// ### Creating a Client
///
/// ```swift
/// let resend = ResendClient(apiKey: "re_your_api_key")
/// ```
///
/// ### Sending an Email
///
/// ```swift
/// let email = ResendEmail(
///     from: "onboarding@resend.dev",
///     to: ["user@example.com"],
///     subject: "Hello",
///     html: "<p>Welcome!</p>"
/// )
/// let response = try await resend.email.send(email: email)
/// ```
///
/// ### Managing Domains
///
/// ```swift
/// let domain = try await resend.domains.create(name: "example.com", region: nil, customReturnPath: nil)
/// let domains = try await resend.domains.list(limit: 10, after: nil, before: nil)
/// ```
public final class ResendClient: ResendClientProtocol {

    private let apiKey: String
    private let httpClient: HTTPClientProtocol
    private let baseURL: String

    /// Access email-related operations
    public let email: EmailClientProtocol
    /// Access domain-related operations
    public let domains: DomainClientProtocol
    /// Access API key management
    public let apiKeys: APIKeyClientProtocol
    /// Access audience management
    public let audiences: AudienceClientProtocol
    /// Access contact management
    public let contacts: ContactClientProtocol
    /// Access broadcast campaign operations
    public let broadcasts: BroadcastClientProtocol
    /// Access webhook management
    public let webhooks: WebhookClientProtocol

    /// Initialize a new Resend client.
    /// - Parameters:
    ///   - apiKey: Your Resend API key from the Resend dashboard
    ///   - httpClient: Custom HTTP client implementation (defaults to `URLSessionHTTPClient`)
    ///   - retry: Optional retry configuration for automatic retries on transient failures and rate limits
    ///   - logger: Optional swift-log `Logger` for HTTP request/response logging
    ///   - baseURL: Base API URL (defaults to `https://api.resend.com`)
    public init(
        apiKey: String,
        httpClient: HTTPClientProtocol? = nil,
        retry: RetryConfiguration? = nil,
        logger: Logger? = nil,
        baseURL: String = "https://api.resend.com"
    ) {
        self.apiKey = apiKey
        var client = httpClient ?? URLSessionHTTPClient()
        if let retry = retry {
            client = RetryHTTPClient(wrapping: client, configuration: retry, logger: logger)
        }
        if let logger = logger {
            client = LoggingHTTPClient(wrapping: client, logger: logger)
        }
        self.httpClient = client
        self.baseURL = baseURL

        self.email = EmailClient(apiKey: apiKey, httpClient: self.httpClient, baseURL: baseURL)
        self.domains = DomainClient(apiKey: apiKey, httpClient: self.httpClient, baseURL: baseURL)
        self.apiKeys = APIKeyClient(apiKey: apiKey, httpClient: self.httpClient, baseURL: baseURL)
        self.audiences = AudienceClient(
            apiKey: apiKey, httpClient: self.httpClient, baseURL: baseURL)
        self.contacts = ContactClient(apiKey: apiKey, httpClient: self.httpClient, baseURL: baseURL)
        self.broadcasts = BroadcastClient(
            apiKey: apiKey, httpClient: self.httpClient, baseURL: baseURL)
        self.webhooks = WebhookClient(
            apiKey: apiKey, httpClient: self.httpClient, baseURL: baseURL)
    }
}

// MARK: - Request Builder
extension ResendClient {
    /// Build an authenticated HTTP request to the Resend API.
    static func buildRequest(
        apiKey: String,
        baseURL: String,
        method: HTTPMethod,
        path: String,
        query: [URLQueryItem]? = nil,
        body: Data? = nil,
        additionalHeaders: [String: String] = [:]
    ) -> HTTPRequest {
        var urlString = "\(baseURL)/\(path)"
        if let query = query, !query.isEmpty {
            var components = URLComponents(string: urlString)
            components?.queryItems = query
            urlString = components?.url?.absoluteString ?? urlString
        }

        var headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]

        for (key, value) in additionalHeaders {
            headers[key] = value
        }

        return HTTPRequest(
            url: urlString,
            method: method,
            headers: headers,
            body: body
        )
    }

    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
}
