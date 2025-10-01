//
//  ResendClientTests.swift
//  ResendTests
//
//  Created by Test Suite
//

import Testing
import Foundation
@testable import ResendKit
@testable import ResendCore

@Suite("ResendClient Tests")
struct ResendClientTests {

    @Test("Client initialization")
    func testClientInitialization() {
        let client = ResendClient(apiKey: "test_key")

        // Verify all client properties are accessible (compile-time check)
        _ = client.email
        _ = client.domains
        _ = client.apiKeys
        _ = client.audiences
        _ = client.contacts
        _ = client.broadcasts
    }

    @Test("Client initialization with custom HTTP client")
    func testClientInitializationWithCustomHTTPClient() {
        let mockClient = MockHTTPClient()
        let client = ResendClient(
            apiKey: "test_key",
            httpClient: mockClient
        )

        // Verify email client is accessible (compile-time check)
        _ = client.email
    }

    @Test("Client initialization with custom base URL")
    func testClientInitializationWithCustomBaseURL() {
        let client = ResendClient(
            apiKey: "test_key",
            httpClient: nil,
            baseURL: "https://custom.api.com"
        )

        // Verify email client is accessible (compile-time check)
        _ = client.email
    }

    @Test("Request builder creates correct request")
    func testRequestBuilderCreatesCorrectRequest() {
        let request = ResendClient.buildRequest(
            apiKey: "test_key",
            baseURL: "https://api.resend.com",
            method: .POST,
            path: "emails",
            body: nil,
            additionalHeaders: ["X-Custom": "value"]
        )

        #expect(request.url == "https://api.resend.com/emails")
        #expect(request.method == .POST)
        #expect(request.headers["Authorization"] == "Bearer test_key")
        #expect(request.headers["Content-Type"] == "application/json")
        #expect(request.headers["X-Custom"] == "value")
    }

    @Test("Encoder uses snake_case")
    func testEncoderUsesSnakeCase() throws {
        struct TestModel: Codable {
            let firstName: String
            let lastName: String
        }

        let model = TestModel(firstName: "John", lastName: "Doe")
        let data = try ResendClient.encoder.encode(model)
        let jsonString = String(data: data, encoding: .utf8)!

        #expect(jsonString.contains("first_name"))
        #expect(jsonString.contains("last_name"))
    }

    @Test("Decoder uses snake_case")
    func testDecoderUsesSnakeCase() throws {
        let json = """
        {
            "first_name": "John",
            "last_name": "Doe"
        }
        """

        struct TestModel: Codable {
            let firstName: String
            let lastName: String
        }

        let data = json.data(using: .utf8)!
        let model = try ResendClient.decoder.decode(TestModel.self, from: data)

        #expect(model.firstName == "John")
        #expect(model.lastName == "Doe")
    }
}
