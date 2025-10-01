//
//  ResendAudience.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

public struct ResendAudience: Codable, Sendable {
    public var object: String?
    public var id: String
    public var name: String
    public var createdAt: String?

    public init(
        object: String? = nil,
        id: String,
        name: String,
        createdAt: String? = nil
    ) {
        self.object = object
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }

    private enum CodingKeys: String, CodingKey {
        case object
        case id
        case name
        case createdAt = "created_at"
    }
}
