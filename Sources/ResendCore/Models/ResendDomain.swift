//
//  ResendDomain.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

public struct ResendDomain: Codable, Sendable {
    public var id: String
    public var name: String
    public var status: String?
    public var createdAt: String?
    public var region: String?
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

public struct DNSRecord: Codable, Sendable {
    public var record: String
    public var name: String
    public var type: String
    public var ttl: String?
    public var status: String?
    public var value: String
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
