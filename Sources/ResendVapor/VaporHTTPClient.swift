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

/// Vapor-based HTTP client implementation using AsyncHTTPClient
public final class VaporHTTPClient: HTTPClientProtocol {
    private let client: Client

    public init(client: Client) {
        self.client = client
    }

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
