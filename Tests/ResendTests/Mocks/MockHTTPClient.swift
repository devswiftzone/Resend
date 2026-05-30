//
//  MockHTTPClient.swift
//  ResendTests
//
//  Created by Test Suite
//

import Foundation
@testable import ResendCore

enum MockResult {
    case response(HTTPResponse)
    case error(Error)
}

final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    var requests: [HTTPRequest] = []
    private var results: [MockResult] = []
    private var currentIndex = 0

    func execute(_ request: HTTPRequest) async throws -> HTTPResponse {
        requests.append(request)

        guard currentIndex < results.count else {
            throw URLError(.unknown)
        }

        let result = results[currentIndex]
        currentIndex += 1

        switch result {
        case .response(let response):
            return response
        case .error(let error):
            throw error
        }
    }

    func reset() {
        requests.removeAll()
        results.removeAll()
        currentIndex = 0
    }

    func addResponse(statusCode: Int, body: String, headers: [String: String]? = nil) {
        var responseHeaders = headers ?? [:]
        if headers == nil { responseHeaders["Content-Type"] = "application/json" }
        let response = HTTPResponse(
            statusCode: statusCode,
            headers: responseHeaders,
            body: body.data(using: .utf8)
        )
        results.append(.response(response))
    }

    func addResponse(statusCode: Int, body: Data?) {
        let response = HTTPResponse(
            statusCode: statusCode,
            headers: ["Content-Type": "application/json"],
            body: body
        )
        results.append(.response(response))
    }

    func addError(_ error: Error) {
        results.append(.error(error))
    }
}
