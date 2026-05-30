//
//  EmailAddressTests.swift
//  ResendTests
//
//  Created by Test Suite
//

import Testing
import Foundation
@testable import ResendCore

@Suite("EmailAddress Tests")
struct EmailAddressTests {

    @Test("Basic initialization")
    func testBasicInitialization() {
        let address = EmailAddress(email: "user@test.com")
        #expect(address.email == "user@test.com")
        #expect(address.name == nil)
    }

    @Test("Initialization with name")
    func testInitializationWithName() {
        let address = EmailAddress(email: "user@test.com", name: "John Doe")
        #expect(address.email == "user@test.com")
        #expect(address.name == "John Doe")
    }

    @Test("String literal initialization")
    func testStringLiteralInitialization() {
        let address: EmailAddress = "user@test.com"
        #expect(address.email == "user@test.com")
        #expect(address.name == nil)
    }

    @Test("Encoding")
    func testEncoding() throws {
        let address = EmailAddress(email: "user@test.com", name: "John Doe")
        let encoder = JSONEncoder()
        let data = try encoder.encode(address)

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["email"] as? String == "user@test.com")
        #expect(json?["name"] as? String == "John Doe")
    }

    @Test("Decoding")
    func testDecoding() throws {
        let json = """
        {
            "email": "user@test.com",
            "name": "John Doe"
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let address = try decoder.decode(EmailAddress.self, from: data)

        #expect(address.email == "user@test.com")
        #expect(address.name == "John Doe")
    }

    @Test("Decoding without name")
    func testDecodingWithoutName() throws {
        let json = """
        {
            "email": "user@test.com"
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let address = try decoder.decode(EmailAddress.self, from: data)

        #expect(address.email == "user@test.com")
        #expect(address.name == nil)
    }
}
