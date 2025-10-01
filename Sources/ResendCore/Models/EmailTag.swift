//
//  EmailTag.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

public struct EmailTag: Codable, Sendable {
    public var name: String
    public var value: String?
    
    public init(name: String, value: String? = nil) {
        self.name = name
        self.value = value
    }
}
