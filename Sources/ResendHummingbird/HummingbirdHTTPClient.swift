import Foundation
import NIOCore
import AsyncHTTPClient
import ResendCore

/// AsyncHTTPClient-based HTTP transport for the Resend SDK.
///
/// Wraps `AsyncHTTPClient.HTTPClient` to conform to `HTTPClientProtocol`,
/// enabling use with `ResendClient` in Hummingbird-based applications.
///
/// ## Usage
///
/// ```swift
/// let httpClient = HummingbirdHTTPClient()
/// let resend = ResendClient(apiKey: "re_...", httpClient: httpClient)
/// ```
public struct HummingbirdHTTPClient: HTTPClientProtocol {
    private let client: HTTPClient

    /// Create a Hummingbird-compatible HTTP client.
    /// - Parameter client: An `AsyncHTTPClient.HTTPClient` instance. Defaults to `.shared`.
    public init(client: HTTPClient = .shared) {
        self.client = client
    }

    /// Execute an HTTP request via AsyncHTTPClient.
    public func execute(_ request: HTTPRequest) async throws -> HTTPResponse {
        var hbRequest = HTTPClientRequest(url: request.url)
        hbRequest.method = .init(rawValue: request.method.rawValue)
        for (key, value) in request.headers {
            hbRequest.headers.add(name: key, value: value)
        }
        if let body = request.body {
            var buffer = ByteBufferAllocator().buffer(capacity: body.count)
            buffer.writeBytes(body)
            hbRequest.body = .bytes(buffer)
        }

        let response = try await client.execute(hbRequest, timeout: .seconds(30))

        var headers: [String: String] = [:]
        for (name, value) in response.headers {
            headers[name] = value
        }

        let bodyData: Data?
        let collected = try await response.body.collect(upTo: 10 * 1024 * 1024)
        if collected.readableBytes > 0 {
            bodyData = collected.withUnsafeReadableBytes { Data($0) }
        } else {
            bodyData = nil
        }

        return HTTPResponse(
            statusCode: Int(response.status.code),
            headers: headers,
            body: bodyData
        )
    }
}
