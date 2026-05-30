import Foundation
import Hummingbird
import ResendCore
import ResendKit

private final class ResendStorage: @unchecked Sendable {
    private let lock = NSLock()
    private var client: ResendClient?

    func set(_ client: ResendClient) {
        lock.withLock { self.client = client }
    }

    func get() -> ResendClient {
        lock.withLock {
            guard let client = client else {
                fatalError("Resend not configured. Call app.resend.initialize(apiKey:) first.")
            }
            return client
        }
    }
}

private let _storage = ResendStorage()

extension Application {
    /// Resend integration for Hummingbird applications.
    ///
    /// Provides access to the Resend client through `app.resend`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var app = Application(router: router)
    /// app.resend.initialize(apiKey: "re_...")
    /// let response = try await app.resend.client.email.send(email: ...)
    /// ```
    public var resend: Resend {
        .init()
    }

    public struct Resend {
        fileprivate init() {}

        /// Initialize Resend with an API key using default AsyncHTTPClient.
        /// - Parameter apiKey: Your Resend API key
        public func initialize(apiKey: String) {
            let httpClient = HummingbirdHTTPClient()
            _storage.set(ResendClient(apiKey: apiKey, httpClient: httpClient))
        }

        /// Initialize Resend with an API key and custom HTTP client.
        /// - Parameters:
        ///   - apiKey: Your Resend API key
        ///   - httpClient: A custom `HTTPClientProtocol` implementation
        public func initialize(apiKey: String, httpClient: HTTPClientProtocol) {
            _storage.set(ResendClient(apiKey: apiKey, httpClient: httpClient))
        }

        /// Initialize Resend using the `RESEND_API_KEY` environment variable.
        /// - Warning: Fatal error if the environment variable is not set.
        public func initialize() {
            guard let apiKey = ProcessInfo.processInfo.environment["RESEND_API_KEY"], !apiKey.isEmpty else {
                fatalError("No RESEND_API_KEY environment variable found")
            }
            initialize(apiKey: apiKey)
        }

        /// The configured Resend client.
        /// - Warning: Fatal error if `initialize()` has not been called.
        public var client: ResendClient {
            _storage.get()
        }
    }
}
