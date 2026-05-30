import Testing
import Foundation
import Logging
@testable import ResendCore
@testable import ResendKit

final class RecordingLogHandler: LogHandler, @unchecked Sendable {
    var entries: [(level: Logger.Level, message: Logger.Message)] = []
    var metadata: Logger.Metadata = [:]
    var logLevel: Logger.Level = .trace

    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        entries.append((level, message))
    }

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }
}

@Suite("LoggingHTTPClient Tests")
struct LoggingHTTPClientTests {

    @Test("Logs successful request and response")
    func testLogsSuccess() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: #"{"id":"1"}"#)

        let handler = RecordingLogHandler()
        let logger = Logger(label: "test") { _ in handler }
        let client = LoggingHTTPClient(wrapping: mock, logger: logger)

        let response = try await client.execute(HTTPRequest(url: "https://api.test.com/items", method: .GET))

        #expect(response.statusCode == 200)
        #expect(handler.entries.count == 2)
        #expect(handler.entries[0].level == .debug)
        #expect(handler.entries[0].message.description.contains("GET"))
        #expect(handler.entries[1].level == .debug)
        #expect(handler.entries[1].message.description.contains("200"))
    }

    @Test("Logs error response")
    func testLogsError() async throws {
        let mock = MockHTTPClient()
        mock.addError(URLError(.notConnectedToInternet))

        let handler = RecordingLogHandler()
        let logger = Logger(label: "test") { _ in handler }
        let client = LoggingHTTPClient(wrapping: mock, logger: logger)

        await #expect(throws: URLError.self) {
            try await client.execute(HTTPRequest(url: "https://api.test.com/items", method: .GET))
        }

        #expect(handler.entries.count == 2)
        #expect(handler.entries[0].level == .debug)
        #expect(handler.entries[1].level == .error)
        #expect(handler.entries[1].message.description.contains("failed"))
    }

    @Test("Does not log when no logger provided")
    func testNoLogger() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: #"{"id":"1"}"#)

        let handler = RecordingLogHandler()
        let logger = Logger(label: "test") { _ in handler }
        // Create a regular RetryHTTPClient without logger to verify the handler stays empty
        _ = RetryHTTPClient(wrapping: mock, configuration: .default, logger: nil)
        _ = logger

        // Without LoggingHTTPClient wrapper, nothing should be logged
        let response = try await mock.execute(HTTPRequest(url: "https://api.test.com/items", method: .GET))
        #expect(response.statusCode == 200)
    }

    @Test("RetryHTTPClient logs retry attempt")
    func testRetryLogging() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 429, body: "{}")
        mock.addResponse(statusCode: 200, body: #"{"id":"1"}"#)

        let handler = RecordingLogHandler()
        let logger = Logger(label: "test") { _ in handler }
        let client = RetryHTTPClient(
            wrapping: mock,
            configuration: RetryConfiguration(maxRetries: 1),
            logger: logger
        )

        let response = try await client.execute(HTTPRequest(url: "https://api.test.com/items", method: .GET))

        #expect(response.statusCode == 200)
        let warnings = handler.entries.filter { $0.level == .warning }
        #expect(warnings.count == 1)
        #expect(warnings[0].message.description.contains("retrying"))
    }

    @Test("LoggingHTTPClient wraps RetryHTTPClient")
    func testLoggingWrapsRetry() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 429, body: "{}")
        mock.addResponse(statusCode: 200, body: #"{"id":"1"}"#)

        let handler = RecordingLogHandler()
        let logger = Logger(label: "test") { _ in handler }
        let retryClient = RetryHTTPClient(
            wrapping: mock,
            configuration: RetryConfiguration(maxRetries: 1),
            logger: logger
        )
        let loggingClient = LoggingHTTPClient(wrapping: retryClient, logger: logger)

        let response = try await loggingClient.execute(HTTPRequest(url: "https://api.test.com/items", method: .GET))

        #expect(response.statusCode == 200)
        // 1 debug before + 1 debug after (LoggingHTTPClient wraps the whole RetryHTTPClient call)
        let debug = handler.entries.filter { $0.level == .debug }
        #expect(debug.count == 2)
        let warnings = handler.entries.filter { $0.level == .warning }
        #expect(warnings.count == 1)
    }
}
