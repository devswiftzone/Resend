//
//  DomainClientTests.swift
//  ResendTests
//
//  Created by Test Suite
//

import Testing
import Foundation
@testable import ResendKit
@testable import ResendCore

@Suite("DomainClient Tests")
struct DomainClientTests {

    // MARK: - Create Domain Tests

    @Test("Create domain successfully")
    func testCreateDomainSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.domainJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let domain = try await resendClient.domains.create(
            name: "test.com",
            region: "us-east-1",
            customReturnPath: "bounce"
        )

        #expect(domain.id == "domain_123")
        #expect(domain.name == "test.com")
        #expect(domain.status == "verified")
        #expect(domain.region == "us-east-1")
        #expect(domain.records != nil)

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .POST)
        #expect(request.url.contains("/domains"))
    }

    @Test("Create domain with minimal params")
    func testCreateDomainWithMinimalParams() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.domainJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let domain = try await resendClient.domains.create(
            name: "test.com",
            region: nil,
            customReturnPath: nil
        )

        #expect(domain.name == "test.com")
    }

    // MARK: - Get Domain Tests

    @Test("Get domain successfully")
    func testGetDomainSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.domainJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let domain = try await resendClient.domains.get(id: "domain_123")

        #expect(domain.id == "domain_123")
        #expect(domain.name == "test.com")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .GET)
        #expect(request.url.contains("/domains/domain_123"))
    }

    // MARK: - List Domains Tests

    @Test("List domains successfully")
    func testListDomainsSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.domainListJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.domains.list(
            limit: 10,
            after: nil,
            before: nil
        )

        #expect(response.data.count == 2)
        #expect(response.data[0].name == "test1.com")
        #expect(response.data[1].name == "test2.com")
        #expect(response.hasMore == false)

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .GET)
        #expect(request.url.contains("/domains"))
        #expect(request.url.contains("limit=10"))
    }

    @Test("List domains with pagination")
    func testListDomainsWithPagination() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.domainListJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.domains.list(
            limit: 5,
            after: "domain_5",
            before: nil
        )

        #expect(response.data.count == 2)

        let request = mockHTTPClient.requests[0]
        #expect(request.url.contains("limit=5"))
        #expect(request.url.contains("after=domain_5"))
    }

    // MARK: - Verify Domain Tests

    @Test("Verify domain successfully")
    func testVerifyDomainSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.domainJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let domain = try await resendClient.domains.verify(id: "domain_123")

        #expect(domain.id == "domain_123")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .POST)
        #expect(request.url.contains("/domains/domain_123/verify"))
    }

    // MARK: - Update Domain Tests

    @Test("Update domain successfully")
    func testUpdateDomainSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.domainJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let domain = try await resendClient.domains.update(
            id: "domain_123",
            clickTracking: true,
            openTracking: true,
            tls: "enforced"
        )

        #expect(domain.id == "domain_123")

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .PATCH)
        #expect(request.url.contains("/domains/domain_123"))
    }

    @Test("Update domain partial")
    func testUpdateDomainPartial() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.domainJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let domain = try await resendClient.domains.update(
            id: "domain_123",
            clickTracking: true,
            openTracking: nil,
            tls: nil
        )

        #expect(domain.id == "domain_123")
    }

    // MARK: - Delete Domain Tests

    @Test("Delete domain successfully")
    func testDeleteDomainSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        mockHTTPClient.addResponse(statusCode: 200, body: TestData.deleteResponseJSON)

        let resendClient = ResendClient(
            apiKey: "test_api_key",
            httpClient: mockHTTPClient
        )

        let response = try await resendClient.domains.delete(id: "domain_123")

        #expect(response.id == "domain_123")
        #expect(response.deleted == true)

        let request = mockHTTPClient.requests[0]
        #expect(request.method == .DELETE)
        #expect(request.url.contains("/domains/domain_123"))
    }
}
