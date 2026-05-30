//
//  RetryHTTPClientTests.swift
//  ResendTests
//

import Testing
import Foundation
@testable import ResendKit
@testable import ResendCore

@Suite("RetryHTTPClient Tests")
struct RetryHTTPClientTests {

    @Test("Does not retry successful responses")
    func testNoRetryOnSuccess() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: "{\"id\": \"test\"}")

        let retry = RetryHTTPClient(wrapping: mock)
        let request = HTTPRequest(url: "https://api.test.com/test", method: .GET)
        let response = try await retry.execute(request)

        #expect(response.statusCode == 200)
        #expect(mock.requests.count == 1)
    }

    @Test("Retries on 429 status code")
    func testRetryOnRateLimit() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 429, body: "{}")
        mock.addResponse(statusCode: 200, body: "{\"id\": \"test\"}")

        let config = RetryConfiguration(maxRetries: 1, baseDelay: 0.01, maxDelay: 0.1, enableJitter: false)
        let retry = RetryHTTPClient(wrapping: mock, configuration: config)
        let request = HTTPRequest(url: "https://api.test.com/test", method: .GET)
        let response = try await retry.execute(request)

        #expect(response.statusCode == 200)
        #expect(mock.requests.count == 2)
    }

    @Test("Does not retry on 400 status code")
    func testNoRetryOnClientError() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 400, body: "{}")

        let config = RetryConfiguration(maxRetries: 3, baseDelay: 0.01, maxDelay: 0.1, enableJitter: false)
        let retry = RetryHTTPClient(wrapping: mock, configuration: config)
        let request = HTTPRequest(url: "https://api.test.com/test", method: .GET)
        let response = try await retry.execute(request)

        #expect(response.statusCode == 400)
        #expect(mock.requests.count == 1)
    }

    @Test("Throws after exhausting retries")
    func testThrowsAfterMaxRetries() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 429, body: "{}")
        mock.addResponse(statusCode: 429, body: "{}")
        mock.addResponse(statusCode: 429, body: "{}")

        let config = RetryConfiguration(maxRetries: 2, baseDelay: 0.01, maxDelay: 0.1, enableJitter: false)
        let retry = RetryHTTPClient(wrapping: mock, configuration: config)
        let request = HTTPRequest(url: "https://api.test.com/test", method: .GET)
        let response = try await retry.execute(request)

        #expect(response.statusCode == 429)
        #expect(mock.requests.count == 3)
    }

    @Test("Respects Retry-After header")
    func testRespectsRetryAfter() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 429, body: "{}", headers: ["Retry-After": "0"])
        mock.addResponse(statusCode: 200, body: "{\"id\": \"test\"}")

        let config = RetryConfiguration(maxRetries: 1, baseDelay: 10, maxDelay: 60, enableJitter: false)
        let retry = RetryHTTPClient(wrapping: mock, configuration: config)
        let request = HTTPRequest(url: "https://api.test.com/test", method: .GET)
        let response = try await retry.execute(request)

        #expect(response.statusCode == 200)
    }

    @Test("Retries on network timeout")
    func testRetryOnTimeout() async throws {
        let mock = MockHTTPClient()
        mock.addError(URLError(.timedOut))
        mock.addResponse(statusCode: 200, body: "{\"id\": \"test\"}")

        let config = RetryConfiguration(maxRetries: 1, baseDelay: 0.01, maxDelay: 0.1, enableJitter: false)
        let retry = RetryHTTPClient(wrapping: mock, configuration: config)
        let request = HTTPRequest(url: "https://api.test.com/test", method: .GET)
        let response = try await retry.execute(request)

        #expect(response.statusCode == 200)
        #expect(mock.requests.count == 2)
    }

    @Test("Retry configuration default values")
    func testDefaultConfiguration() {
        let config = RetryConfiguration.default
        #expect(config.maxRetries == 3)
        #expect(config.baseDelay == 1.0)
        #expect(config.maxDelay == 30.0)
        #expect(config.enableJitter == true)
        #expect(config.retryableStatusCodes == [429, 502, 503, 504])
    }

    @Test("ResendClient with retry configuration")
    func testClientWithRetry() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: TestData.domainJSON)

        let config = RetryConfiguration(maxRetries: 1, baseDelay: 0.01, maxDelay: 0.1, enableJitter: false)
        let client = ResendClient(apiKey: "test", httpClient: mock, retry: config)

        let domain = try await client.domains.get(id: "domain_123")
        #expect(domain.id == "domain_123")
    }
}
