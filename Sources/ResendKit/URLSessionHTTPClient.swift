//
//  URLSessionHTTPClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation
import ResendCore
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// URLSession-based HTTP client implementation for the Resend API.
///
/// This is the default HTTP client used by `ResendClient` when no custom client is provided.
/// It uses `URLSession` for HTTP transport with async/await.
///
/// ## Example
///
/// ```swift
/// let client = URLSessionHTTPClient()
/// let request = HTTPRequest(url: "https://api.resend.com/emails", method: .POST, headers: [...], body: ...)
/// let response = try await client.execute(request)
/// ```
public final class URLSessionHTTPClient: HTTPClientProtocol {
    private let session: URLSession

    /// Create a URLSession-based HTTP client.
    /// - Parameter session: The URLSession to use (defaults to `.shared`)
    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Execute an HTTP request using URLSession.
    public func execute(_ request: HTTPRequest) async throws -> HTTPResponse {
        guard let url = URL(string: request.url) else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        urlRequest.httpBody = request.body

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        var headers: [String: String] = [:]
        for (key, value) in httpResponse.allHeaderFields {
            if let key = key as? String, let value = value as? String {
                headers[key] = value
            }
        }

        return HTTPResponse(
            statusCode: httpResponse.statusCode,
            headers: headers,
            body: data
        )
    }
}
