//
//  ResendCommonTests.swift
//  ResendTests
//
//  Created by Test Suite
//

import Testing
import Foundation
@testable import ResendCore

@Suite("ResendCommon Tests")
struct ResendCommonTests {

    // MARK: - ResendListResponse Tests

    @Test("List response decoding")
    func testListResponseDecoding() throws {
        let json = """
        {
            "object": "list",
            "data": [
                {"id": "item_1", "name": "Item 1"},
                {"id": "item_2", "name": "Item 2"}
            ]
        }
        """

        struct TestItem: Codable, Sendable {
            let id: String
            let name: String
        }

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let response = try decoder.decode(ResendListResponse<TestItem>.self, from: data)

        #expect(response.object == "list")
        #expect(response.data.count == 2)
        #expect(response.hasMore == false)
        #expect(response.data[0].id == "item_1")
    }

    @Test("List response without has_more")
    func testListResponseWithoutHasMore() throws {
        let json = """
        {
            "object": "list",
            "data": [],
            "has_more": false
        }
        """

        struct TestItem: Codable {
            let id: String
        }

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let response = try decoder.decode(ResendListResponse<TestItem>.self, from: data)

        #expect(response.data.count == 0)
        #expect(response.hasMore == false)
    }

    // MARK: - ResendDeleteResponse Tests

    @Test("Delete response decoding")
    func testDeleteResponseDecoding() throws {
        let json = TestData.deleteResponseJSON
        let data = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let response = try decoder.decode(ResendDeleteResponse.self, from: data)

        #expect(response.object == "domain")
        #expect(response.id == "domain_123")
        #expect(response.deleted == true)
    }

    // MARK: - ResendBatchResponse Tests

    @Test("Batch response decoding")
    func testBatchResponseDecoding() throws {
        let json = TestData.batchResponseJSON
        let data = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let response = try decoder.decode(ResendBatchResponse.self, from: data)

        #expect(response.data.count == 2)
        #expect(response.data[0].id == "email_1")
        #expect(response.errors?.count == 1)
        #expect(response.errors?[0].index == 2)
        #expect(response.errors?[0].message == "Invalid email")
    }

    // MARK: - ResendRetrieveError Tests

    @Test("Error decoding")
    func testErrorDecoding() throws {
        let json = TestData.errorJSON
        let data = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let error = try decoder.decode(ResendRetrieveError.self, from: data)

        #expect(error.statusCode == 400)
        #expect(error.message == "Invalid email address")
        #expect(error.name == "validation_error")
    }

    @Test("Error conforms to Error protocol")
    func testErrorConformsToErrorProtocol() {
        // Compile-time conformance check: this will fail to compile if ResendRetrieveError doesn't conform to Error
        func requiresError<T: Error>(_: T) {}
        let error = ResendRetrieveError(
            statusCode: 404,
            message: "Not found",
            name: "not_found"
        )
        requiresError(error)
    }
}

