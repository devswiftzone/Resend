import Foundation
import Logging
import ResendCore

final class LoggingHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    private let wrapped: HTTPClientProtocol
    private let logger: Logger

    init(wrapping client: HTTPClientProtocol, logger: Logger) {
        self.wrapped = client
        self.logger = logger
    }

    func execute(_ request: HTTPRequest) async throws -> HTTPResponse {
        let start = Date()
        let method = request.method.rawValue
        let url = sanitizeURL(request.url)

        logger.debug("\(method) \(url)")

        do {
            let response = try await wrapped.execute(request)
            let elapsed = elapsedMs(from: start)
            logger.debug("\(response.statusCode) \(method) \(url) (\(elapsed)ms)")
            return response
        } catch {
            let elapsed = elapsedMs(from: start)
            logger.error("\(method) \(url) failed after \(elapsed)ms: \(error.localizedDescription)")
            throw error
        }
    }

    private func sanitizeURL(_ url: String) -> String {
        guard let components = URLComponents(string: url) else { return url }
        return components.host.map { "\(components.scheme.map { "\($0)://" } ?? "")\($0)\(components.path)" } ?? url
    }

    private func elapsedMs(from start: Date) -> Int {
        Int((Date().timeIntervalSince(start)) * 1000)
    }
}
