//
//  VaporHTTPClient.swift
//  ResendVapor
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation
import Vapor
import ResendCore
import NIOCore
import NIOHTTP1

/// Vapor-based HTTP client implementation using AsyncHTTPClient.
///
/// Used automatically when integrating the Resend SDK with Vapor applications.
/// Wraps Vapor's `Client` to provide HTTP transport for the Resend API.
public final class VaporHTTPClient: HTTPClientProtocol {
    private let client: Client

    /// Create a Vapor-based HTTP client.
    /// - Parameter client: Vapor's `Client` instance, typically from `Request.client` or `Application.client`
    public init(client: Client) {
        self.client = client
    }

    /// Execute an HTTP request using Vapor's async HTTP client.
    public func execute(_ request: HTTPRequest) async throws -> HTTPResponse {
        let uri = URI(string: request.url)

        let method = HTTPMethod(rawValue: request.method.rawValue)
        var headers = HTTPHeaders()

        for (key, value) in request.headers {
            headers.add(name: key, value: value)
        }

        let response: ClientResponse

        if let body = request.body {
            var buffer = ByteBuffer()
            buffer.writeBytes(body)
            response = try await client.send(method, headers: headers, to: uri) { req in
                req.body = .init(buffer: buffer)
            }
        } else {
            response = try await client.send(method, headers: headers, to: uri)
        }

        var responseHeaders: [String: String] = [:]
        for (name, value) in response.headers {
            responseHeaders[name] = value
        }

        let bodyData: Data?
        if let buffer = response.body {
            bodyData = Data(buffer: buffer)
        } else {
            bodyData = nil
        }

        return HTTPResponse(
            statusCode: Int(response.status.code),
            headers: responseHeaders,
            body: bodyData
        )
    }
}
