//
//  ResendRetrieveError.swift
//  
//
//  Created by Asiel Cabrera Gonzalez on 12/3/23.
//

import Foundation


public struct ResendRetrieveError: Codable, Error {
    public let statusCode:  Int
    public let message: String
    public let name: String
}
