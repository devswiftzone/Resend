//
//  ResendContact.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

public struct ResendContact: Codable, Sendable {
    public var object: String?
    public var id: String
    public var email: String
    public var firstName: String?
    public var lastName: String?
    public var createdAt: String?
    public var unsubscribed: Bool?

    public init(
        object: String? = nil,
        id: String,
        email: String,
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
}
