//
//  ResendDomainTests.swift
//  ResendTests
//
//  Created by Test Suite
//

import Testing
import Foundation
@testable import ResendCore

@Suite("ResendDomain Tests")
struct ResendDomainTests {

    @Test("Domain decoding")
    func testDomainDecoding() throws {
        let json = TestData.domainJSON
        let data = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let domain = try decoder.decode(ResendDomain.self, from: data)

        #expect(domain.id == "domain_123")
        #expect(domain.name == "test.com")
        #expect(domain.status == "verified")
        #expect(domain.region == "us-east-1")
        #expect(domain.records != nil)
        #expect(domain.records?.count == 1)
    }

    @Test("DNS record decoding")
    func testDNSRecordDecoding() throws {
        let json = """
        {
            "record": "SPF",
            "name": "test.com",
            "type": "TXT",
            "ttl": "3600",
            "status": "verified",
            "value": "v=spf1 include:resend.com ~all",
            "priority": 10
        }
        """
        let data = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let record = try decoder.decode(DNSRecord.self, from: data)

        #expect(record.record == "SPF")
        #expect(record.name == "test.com")
        #expect(record.type == "TXT")
        #expect(record.ttl == "3600")
        #expect(record.status == "verified")
        #expect(record.value == "v=spf1 include:resend.com ~all")
        #expect(record.priority == 10)
    }

    @Test("Domain initialization")
    func testDomainInitialization() {
        let record = DNSRecord(
            record: "SPF",
            name: "test.com",
            type: "TXT",
            value: "v=spf1"
        )

        let domain = ResendDomain(
            id: "domain_123",
            name: "test.com",
            status: "verified",
            createdAt: "2025-01-01T00:00:00Z",
            region: "us-east-1",
            records: [record]
        )

        #expect(domain.id == "domain_123")
        #expect(domain.name == "test.com")
        #expect(domain.records?.count == 1)
    }
}
