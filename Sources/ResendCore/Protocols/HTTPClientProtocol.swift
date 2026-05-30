//
//  HTTPClientProtocol.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// Protocol defining HTTP client capabilities for making API requests
public protocol HTTPClientProtocol {
    /// Execute an HTTP request
    /// - Parameter request: The HTTP request to execute
    /// - Returns: The HTTP response
    func execute(_ request: HTTPRequest) async throws -> HTTPResponse
}

/// Represents an HTTP request
public struct HTTPRequest {
    public let url: String
    public let method: HTTPMethod
    public let headers: [String: String]
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

/// Represents an HTTP response
public struct HTTPResponse {
    public let statusCode: Int
    public let headers: [String: String]
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

/// HTTP methods
public enum HTTPMethod: String {
    case GET
    case POST
    case PATCH
    case DELETE
    case PUT
}

extension HTTPClientProtocol {
    /// Execute a request and decode the response, handling API errors
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
