//
//  ResendContact.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// A contact within an audience for broadcast campaigns.
public struct ResendContact: Codable, Sendable {
    /// The object type, typically "contact"
    public var object: String?

    /// Unique identifier for the contact
    public var id: String

    /// Email address of the contact
    public var email: String?

    /// First name of the contact
    public var firstName: String?

    /// Last name of the contact
    public var lastName: String?

    /// Timestamp when the contact was created
    public var createdAt: String?

    /// Whether the contact has unsubscribed from broadcasts
    public var unsubscribed: Bool?

    public init(
        object: String? = nil,
        id: String,
        email: String?,
        firstName: String? = nil,
        lastName: String? = nil,
        createdAt: String? = nil,
        unsubscribed: Bool? = nil
    ) {
        self.object = object
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.createdAt = createdAt
        self.unsubscribed = unsubscribed
    }

    private enum CodingKeys: String, CodingKey {
        case object
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case createdAt = "created_at"
        case unsubscribed
    }
}
