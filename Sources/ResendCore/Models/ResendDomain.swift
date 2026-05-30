//
//  ResendDomain.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// A domain that has been configured for sending emails through Resend.
///
/// Domains must be verified before they can be used as sender addresses.
/// Contains DNS records that need to be added to the domain's DNS configuration.
public struct ResendDomain: Codable, Sendable {
    /// Unique identifier for the domain
    public var id: String

    /// The domain name (e.g., "example.com")
    public var name: String

    /// Current verification status (e.g., "pending", "verified", "failed")
    public var status: String?

    /// Timestamp when the domain was created
    public var createdAt: String?

    /// AWS region where the domain is configured
    public var region: String?

    /// DNS records that need to be configured for verification
    public var records: [DNSRecord]?

    public init(
        id: String,
        name: String,
        status: String? = nil,
        createdAt: String? = nil,
        region: String? = nil,
        records: [DNSRecord]? = nil
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.createdAt = createdAt
        self.region = region
        self.records = records
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case createdAt = "created_at"
        case region
        case records
    }
}

/// A DNS record required for domain verification.
///
/// Each DNS record must be added to the domain's DNS provider configuration
/// before Resend can verify ownership and enable sending.
public struct DNSRecord: Codable, Sendable {
    /// The type of DNS record (e.g., "MX", "TXT", "CNAME")
    public var record: String

    /// The hostname or subdomain for this record
    public var name: String

    /// The DNS record type
    public var type: String

    /// Time to live in seconds
    public var ttl: String?

    /// Current verification status of this record
    public var status: String?

    /// The value that the DNS record should point to
    public var value: String

    /// Priority for MX records
    public var priority: Int?

    public init(
        record: String,
        name: String,
        type: String,
        ttl: String? = nil,
        status: String? = nil,
        value: String,
        priority: Int? = nil
    ) {
        self.record = record
        self.name = name
        self.type = type
        self.ttl = ttl
        self.status = status
        self.value = value
        self.priority = priority
    }
}
