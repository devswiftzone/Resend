//
//  ResendEmailResponse.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// Response from sending an email, containing the assigned email ID.
public struct ResendEmailResponse: Codable, Sendable {
    /// Unique identifier for the sent email
    public let id: String

    public init(id: String) {
        self.id = id
    }
}
