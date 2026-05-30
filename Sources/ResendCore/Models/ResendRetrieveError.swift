//
//  ResendRetrieveError.swift
//  
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation


public struct ResendRetrieveError: Codable, Sendable, Error {
    public let statusCode: Int
    public let message: String
    public let name: String

    public init(statusCode: Int, message: String, name: String) {
        self.statusCode = statusCode
        self.message = message
        self.name = name
    }
}
