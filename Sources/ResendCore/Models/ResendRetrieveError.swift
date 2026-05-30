//
//  ResendRetrieveError.swift
//  
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation

/// An error returned by the Resend API.
///
/// This struct is decoded from error responses and provides the HTTP status code,
/// a human-readable message, and an error name identifier.
public struct ResendRetrieveError: Codable, Sendable, Error {
    /// The HTTP status code of the error response
    public let statusCode: Int

    /// A human-readable description of the error
    public let message: String

    /// The error type identifier (e.g., "not_found", "validation_error")
    public let name: String

    public init(statusCode: Int, message: String, name: String) {
        self.statusCode = statusCode
        self.message = message
        self.name = name
    }

    private enum CodingKeys: String, CodingKey {
        case statusCode
        case message
        case name
    }
}
