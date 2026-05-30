//
//  ResendAPIKey.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// Response from creating a new API key.
///
/// The `token` property contains the full API key value and is only returned
/// once at creation time. Store it securely.
public struct ResendAPIKey: Codable, Sendable {
    /// Unique identifier for the API key
    public var id: String

    /// The API key token value (only returned on creation)
    public var token: String

    public init(id: String, token: String) {
        self.id = id
        self.token = token
    }
}

/// A summary item for an API key in a list response.
public struct ResendAPIKeyListItem: Codable, Sendable {
    /// Unique identifier for the API key
    public var id: String

    /// Display name for the API key
    public var name: String

    /// Timestamp when the API key was created
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
