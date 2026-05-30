//
//  ResendAudience.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// A group of contacts that can receive broadcast campaigns.
public struct ResendAudience: Codable, Sendable {
    /// The object type, typically "audience"
    public var object: String?

    /// Unique identifier for the audience
    public var id: String

    /// Name of the audience
    public var name: String

    /// Timestamp when the audience was created
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
