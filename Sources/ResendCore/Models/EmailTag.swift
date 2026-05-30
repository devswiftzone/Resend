//
//  EmailTag.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// A key-value tag for categorizing and tracking emails.
///
/// Tags are used for analytics and filtering. Common use cases include
/// tracking email types like "welcome", "transactional", or "newsletter".
public struct EmailTag: Codable, Sendable {
    /// The tag name (e.g., "category")
    public var name: String

    /// The tag value (e.g., "welcome-email")
    public var value: String?

    public init(name: String, value: String? = nil) {
        self.name = name
        self.value = value
    }
}
