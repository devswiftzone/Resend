//
//  EmailAddress.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// A structured email address with an optional display name.
///
/// `EmailAddress` also conforms to `ExpressibleByStringLiteral`, allowing
/// you to use a plain string where an email address is expected:
///
/// ```swift
/// let address: EmailAddress = "user@example.com"
/// ```
public struct EmailAddress: Codable, Sendable {
    /// The email address (e.g., "user@example.com")
    public var email: String

    /// Optional display name for the recipient
    public var name: String?

    public init(
        email: String,
        name: String? = nil
    ) {
        self.email = email
        self.name = name
    }
}

extension EmailAddress: ExpressibleByStringLiteral {
    public init(stringLiteral email: StringLiteralType) {
        self.init(email: email)
    }
}
