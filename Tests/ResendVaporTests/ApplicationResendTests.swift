import Testing
import Vapor
@testable import ResendVapor
@testable import ResendCore
@testable import ResendKit

@Suite("Application+Resend Tests")
struct ApplicationResendTests {

    @Test("Initialize with API key stores client")
    func testInitializeWithApiKey() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        app.resend.initialize(apiKey: "test_key")

        #expect(app.resend.client is ResendClient)
    }

    @Test("Client is accessible after initialization")
    func testClientAfterInitialization() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        app.resend.initialize(apiKey: "test_key")

        _ = app.resend.client.email
        _ = app.resend.client.domains
        _ = app.resend.client.apiKeys
        _ = app.resend.client.audiences
        _ = app.resend.client.contacts
        _ = app.resend.client.broadcasts
        _ = app.resend.client.webhooks
    }

    @Test("Client is accessible via Request")
    func testRequestAccess() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        app.resend.initialize(apiKey: "test_key")

        let request = Request(
            application: app,
            method: .GET,
            url: URI(path: "/test"),
            on: app.eventLoopGroup.next()
        )

        _ = request.resend
    }

    @Test("VaporHTTPClient wraps Vapor Client")
    func testVaporHTTPClientInitialization() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        let vaporClient = VaporHTTPClient(client: app.client)
        _ = vaporClient
    }

    @Test("VaporHTTPClient conforms to HTTPClientProtocol")
    func testVaporHTTPClientConformance() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        let vaporClient: HTTPClientProtocol = VaporHTTPClient(client: app.client)
        _ = vaporClient
    }
}
