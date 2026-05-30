//
//  Application+Resend.swift
//  ResendVapor
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Vapor
import ResendCore
import ResendKit

extension Application {
    /// Resend integration for Vapor applications.
    ///
    /// Provides access to the Resend client through `app.resend`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// try app.resend.initialize(apiKey: "re_...")
    /// let response = try await app.resend.client.email.send(email: ...)
    /// ```
    public struct Resend {
        private final class Storage: @unchecked Sendable {
            var client: ResendClient?

            init() {}
        }

        private struct Key: StorageKey {
            typealias Value = Storage
        }

        private var storage: Storage {
            if self.application.storage[Key.self] == nil {
                self.application.storage[Key.self] = .init()
            }
            return self.application.storage[Key.self]!
        }

        /// Initialize Resend with an API key.
        /// - Parameter apiKey: Your Resend API key
        public func initialize(apiKey: String) {
            let httpClient = VaporHTTPClient(client: self.application.client)
            self.storage.client = ResendClient(apiKey: apiKey, httpClient: httpClient)
        }

        /// Initialize Resend using the `RESEND_API_KEY` environment variable.
        /// - Warning: Fatal error if the environment variable is not set.
        public func initialize() {
            guard let apiKey = Environment.get("RESEND_API_KEY") else {
                fatalError("No RESEND_API_KEY environment variable found")
            }
            initialize(apiKey: apiKey)
        }

        fileprivate let application: Application

        /// The configured Resend client.
        /// - Warning: Fatal error if `initialize()` has not been called.
        public var client: ResendClient {
            guard let client = storage.client else {
                fatalError("Resend not initialized. Call app.resend.initialize() first.")
            }
            return client
        }
    }

    /// Access the Resend integration.
    public var resend: Resend {
        .init(application: self)
    }
}

// MARK: - Request Extension
extension Request {
    /// Access the Resend client from a `Request`.
    ///
    /// Requires that `app.resend.initialize()` has been called during configuration.
    public var resend: ResendClient {
        return self.application.resend.client
    }
}
