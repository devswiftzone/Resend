//
//  HTTPClientProtocol.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// Protocol defining HTTP client capabilities for making API requests.
///
/// Implement this protocol to provide custom HTTP transport for the Resend SDK.
/// The SDK includes built-in implementations using URLSession and Vapor's client.
public protocol HTTPClientProtocol: Sendable {
    /// Execute an HTTP request and return the response.
    /// - Parameter request: The HTTP request to execute
    /// - Returns: The HTTP response
    func execute(_ request: HTTPRequest) async throws -> HTTPResponse
}

/// Represents an HTTP request to be sent to the Resend API.
public struct HTTPRequest {
    /// The full URL for the request
    public let url: String

    /// The HTTP method (GET, POST, PATCH, DELETE, PUT)
    public let method: HTTPMethod

    /// HTTP request headers
    public let headers: [String: String]

    /// The request body data
    public let body: Data?

    public init(
        url: String,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
}

/// Represents an HTTP response from the Resend API.
public struct HTTPResponse {
    /// The HTTP status code
    public let statusCode: Int

    /// Response headers
    public let headers: [String: String]

    /// The response body data
    public let body: Data?

    public init(
        statusCode: Int,
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }
}

/// HTTP methods used by the Resend API.
public enum HTTPMethod: String {
    case GET
    case POST
    case PATCH
    case DELETE
    case PUT
}

extension HTTPClientProtocol {
    /// Execute a request and decode the response, handling API errors.
    ///
    /// This helper method:
    /// - Executes the HTTP request
    /// - Validates the status code (200-299)
    /// - Decodes the response body into the specified type
    /// - Throws `ResendRetrieveError` for non-success status codes
    ///
    /// - Parameters:
    ///   - request: The HTTP request to execute
    ///   - decoder: JSON decoder for response parsing
    /// - Returns: Decoded response of the specified type
    public func executeAndDecode<T: Decodable>(
        _ request: HTTPRequest,
        decoder: JSONDecoder
    ) async throws -> T {
        let response = try await execute(request)
        guard (200...299).contains(response.statusCode) else {
            if let body = response.body {
                throw try decoder.decode(ResendRetrieveError.self, from: body)
            }
            throw URLError(.badServerResponse)
        }
        guard let body = response.body else {
            throw URLError(.cannotParseResponse)
        }
        return try decoder.decode(T.self, from: body)
    }
}
