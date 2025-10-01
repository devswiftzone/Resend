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
