//
//  MockHTTPClient.swift
//  ResendTests
//
//  Created by Test Suite
//

import Foundation
@testable import ResendCore

final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    var requests: [HTTPRequest] = []
    var responses: [HTTPResponse] = []
    var currentResponseIndex = 0
    var shouldThrowError = false
    var errorToThrow: Error = URLError(.badServerResponse)

    func execute(_ request: HTTPRequest) async throws -> HTTPResponse {
        requests.append(request)

        if shouldThrowError {
            throw errorToThrow
        }

        guard currentResponseIndex < responses.count else {
            throw URLError(.unknown)
        }

        let response = responses[currentResponseIndex]
        currentResponseIndex += 1
        return response
    }

    func reset() {
        requests.removeAll()
        responses.removeAll()
        currentResponseIndex = 0
        shouldThrowError = false
    }

    func addResponse(statusCode: Int, body: String) {
        let response = HTTPResponse(
            statusCode: statusCode,
            headers: ["Content-Type": "application/json"],
            body: body.data(using: .utf8)
        )
        responses.append(response)
    }

    func addResponse(statusCode: Int, body: Data?) {
        let response = HTTPResponse(
            statusCode: statusCode,
            headers: ["Content-Type": "application/json"],
            body: body
        )
        responses.append(response)
    }
}
