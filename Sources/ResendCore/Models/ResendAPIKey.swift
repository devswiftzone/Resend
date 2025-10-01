//
//  ResendAPIKey.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

public struct ResendAPIKey: Codable, Sendable {
    public var id: String
    public var token: String

    public init(id: String, token: String) {
        self.id = id
        self.token = token
    }
}

public struct ResendAPIKeyListItem: Codable, Sendable {
    public var id: String
    public var name: String
    public var createdAt: String?

    public init(id: String, name: String, createdAt: String? = nil) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_at"
    }
}
