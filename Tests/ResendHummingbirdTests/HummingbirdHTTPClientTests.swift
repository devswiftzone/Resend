import Testing
import AsyncHTTPClient
import NIOCore
import Hummingbird
@testable import ResendHummingbird
@testable import ResendCore

@Suite("HummingbirdHTTPClient Tests")
struct HummingbirdHTTPClientTests {

    @Test("Initializes with default shared client")
    func testDefaultInitialization() {
        let client = HummingbirdHTTPClient()
        #expect(client is HummingbirdHTTPClient)
    }

    @Test("Initializes with custom HTTPClient")
    func testCustomHTTPClient() {
        let httpClient = HTTPClient.shared
        let client = HummingbirdHTTPClient(client: httpClient)
        #expect(client is HummingbirdHTTPClient)
    }

    @Test("Conforms to HTTPClientProtocol")
    func testConformance() {
        let client = HummingbirdHTTPClient()
        let proto: any HTTPClientProtocol = client
        #expect(proto is HummingbirdHTTPClient)
    }

    @Test("HummingbirdHTTPClient is Sendable")
    func testSendable() {
        let client = HummingbirdHTTPClient()
        let sendable: any Sendable = client
        #expect(sendable is HummingbirdHTTPClient)
    }
}

@Suite("Application+Resend Extension Tests")
struct ApplicationResendExtensionTests {

    @Test("Initialize with API key stores client")
    func testInitializeWithApiKey() {
        var router = Router()
        var app = Application(router: router)
        app.resend.initialize(apiKey: "test_key")
        _ = app.resend.client
    }

    @Test("Client is accessible after initialization")
    func testClientAfterInitialization() {
        var router = Router()
        var app = Application(router: router)
        app.resend.initialize(apiKey: "test_key")
        _ = app.resend.client.email
        _ = app.resend.client.domains
        _ = app.resend.client.apiKeys
        _ = app.resend.client.audiences
        _ = app.resend.client.contacts
        _ = app.resend.client.broadcasts
        _ = app.resend.client.webhooks
    }

    @Test("Initialize with custom http client")
    func testInitializeWithCustomClient() {
        var router = Router()
        var app = Application(router: router)
        let customClient = HummingbirdHTTPClient()
        app.resend.initialize(apiKey: "test_key", httpClient: customClient)
        _ = app.resend.client
    }
}
