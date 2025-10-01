//
//  ResendEmailResponse.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

public struct ResendEmailResponse: Codable, Sendable {
    public let id: String

    public init(id: String) {
        self.id = id
    }
}
