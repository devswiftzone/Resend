//
//  RetryHTTPClient.swift
//  ResendKit
//
//  Created by Asiel Cabrera Gonzalez
//

import Foundation
import Logging
import ResendCore

/// Configuration for retry behavior when API requests fail.
///
/// Use with `ResendClient.init(retry:)` to enable automatic retries with
/// exponential backoff and optional jitter for transient failures.
///
/// ```swift
/// let config = RetryConfiguration(
///     maxRetries: 3,
///     baseDelay: 1.0,
///     maxDelay: 30.0,
///     enableJitter: true
/// )
/// ```
public struct RetryConfiguration: Sendable {
    /// Maximum number of retry attempts before giving up
    public let maxRetries: Int

    /// Base delay in seconds for exponential backoff (doubles with each retry)
    public let baseDelay: TimeInterval

    /// Maximum delay in seconds between retries (caps exponential growth)
    public let maxDelay: TimeInterval

    /// Whether to add random jitter (up to 10% of delay) to prevent thundering herd
    public let enableJitter: Bool

    /// HTTP status codes that trigger a retry (default: 429, 502, 503, 504)
    public let retryableStatusCodes: Set<Int>

    /// Default retry configuration: 3 retries, 1s base delay, 30s max, jitter enabled
    public static let `default` = RetryConfiguration(
        maxRetries: 3,
        baseDelay: 1.0,
        maxDelay: 30.0,
        enableJitter: true,
        retryableStatusCodes: [429, 502, 503, 504]
    )

    /// Create a custom retry configuration.
    /// - Parameters:
    ///   - maxRetries: Maximum number of retry attempts (default: 3)
    ///   - baseDelay: Base delay in seconds (default: 1.0)
    ///   - maxDelay: Maximum delay in seconds (default: 30.0)
    ///   - enableJitter: Whether to add random jitter (default: true)
    ///   - retryableStatusCodes: Status codes that trigger retry (default: 429, 502, 503, 504)
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

/// HTTP client decorator that adds retry logic with exponential backoff.
///
/// Wraps any `HTTPClientProtocol` and automatically retries failed requests
/// based on the provided `RetryConfiguration`. Supports retry on both
/// HTTP status codes (429, 5xx) and network errors (timeouts, connection loss).
public final class RetryHTTPClient: HTTPClientProtocol {
    private let wrapped: HTTPClientProtocol
    private let configuration: RetryConfiguration
    private let logger: Logger?

    /// Create a retry-decorated HTTP client.
    /// - Parameters:
    ///   - client: The underlying HTTP client to wrap
    ///   - configuration: Retry configuration (defaults to `RetryConfiguration.default`)
    ///   - logger: Optional logger for retry event logging
    public init(
        wrapping client: HTTPClientProtocol,
        configuration: RetryConfiguration = .default,
        logger: Logger? = nil
    ) {
        self.wrapped = client
        self.configuration = configuration
        self.logger = logger
    }

    /// Execute a request with automatic retry on failure.
    /// Retries on configured status codes and transient network errors.
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
                logger?.warning(
                    "\(request.method.rawValue) \(request.url) returned \(response.statusCode), retrying in \(String(format: "%.1f", delay))s (attempt \(attempt + 1)/\(configuration.maxRetries))"
                )
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
                logger?.warning(
                    "\(request.method.rawValue) \(request.url) failed: \(error.localizedDescription), retrying in \(String(format: "%.1f", delay))s (attempt \(attempt + 1)/\(configuration.maxRetries))"
                )
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                lastError = error
            }
        }

        throw lastError ?? URLError(.unknown)
    }

    /// Calculate delay with exponential backoff, optional jitter, and Retry-After support.
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

    /// Parse the Retry-After header if present.
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

    /// Determine whether an error is transient and should be retried.
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
