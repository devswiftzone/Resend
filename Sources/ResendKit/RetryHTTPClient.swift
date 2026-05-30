//
//  RetryHTTPClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez
//

import Foundation
import ResendCore

/// Configuration for retry behavior
public struct RetryConfiguration: Sendable {
    /// Maximum number of retry attempts
    public let maxRetries: Int
    /// Base delay in seconds for exponential backoff
    public let baseDelay: TimeInterval
    /// Maximum delay in seconds between retries
    public let maxDelay: TimeInterval
    /// Whether to add random jitter to delays
    public let enableJitter: Bool
    /// HTTP status codes that trigger a retry
    public let retryableStatusCodes: Set<Int>

    public static let `default` = RetryConfiguration(
        maxRetries: 3,
        baseDelay: 1.0,
        maxDelay: 30.0,
        enableJitter: true,
        retryableStatusCodes: [429, 502, 503, 504]
    )

    public init(
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0,
        enableJitter: Bool = true,
        retryableStatusCodes: Set<Int> = [429, 502, 503, 504]
    ) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.enableJitter = enableJitter
        self.retryableStatusCodes = retryableStatusCodes
    }
}

/// HTTP client decorator that adds retry logic with exponential backoff
public final class RetryHTTPClient: HTTPClientProtocol {
    private let wrapped: HTTPClientProtocol
    private let configuration: RetryConfiguration

    public init(wrapping client: HTTPClientProtocol, configuration: RetryConfiguration = .default) {
        self.wrapped = client
        self.configuration = configuration
    }

    public func execute(_ request: HTTPRequest) async throws -> HTTPResponse {
        var lastError: Error?

        for attempt in 0...configuration.maxRetries {
            do {
                let response = try await wrapped.execute(request)

                guard configuration.retryableStatusCodes.contains(response.statusCode) else {
                    return response
                }

                if attempt == configuration.maxRetries {
                    return response
                }

                let delay = calculateDelay(for: attempt, response: response)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                lastError = nil
            } catch {
                guard attempt < configuration.maxRetries else {
                    throw error
                }
                guard isRetryableError(error) else {
                    throw error
                }

                let delay = calculateDelay(for: attempt, response: nil)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                lastError = error
            }
        }

        throw lastError ?? URLError(.unknown)
    }

    private func calculateDelay(for attempt: Int, response: HTTPResponse?) -> TimeInterval {
        if let retryAfter = parseRetryAfter(response), attempt == 0 {
            return min(retryAfter, configuration.maxDelay)
        }
        let exponential = configuration.baseDelay * exponentialBackoff(attempt)
        let clamped = min(exponential, configuration.maxDelay)
        guard configuration.enableJitter else { return clamped }
        let jitter = Double.random(in: 0...clamped * 0.1)
        return clamped + jitter
    }

    private func exponentialBackoff(_ attempt: Int) -> Double {
        (0..<attempt).reduce(1.0) { result, _ in result * 2.0 }
    }

    private func parseRetryAfter(_ response: HTTPResponse?) -> TimeInterval? {
        guard let value = response?.headers["Retry-After"] else { return nil }
        if let seconds = TimeInterval(value) { return seconds }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        if let date = formatter.date(from: value) {
            return date.timeIntervalSinceNow
        }
        return nil
    }

    private func isRetryableError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .networkConnectionLost, .notConnectedToInternet,
                 .cannotConnectToHost, .dnsLookupFailed:
                return true
            default:
                return false
            }
        }
        return false
    }
}
