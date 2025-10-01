//
//  EmailAttachment.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

public struct EmailAttachment: Codable, Sendable {
    
    /// The Base64 encoded content of the attachment.
    public var content: String
    
    /// The filename of the attachment.
    public var filename: String
    
    /// The content-disposition of the attachment specifying how you would like the attachment to be displayed.
    public var path: String
   
    public init(
        content: String,
        filename: String,
        path: String
       
    ) {
        self.content = content
        self.filename = filename
        self.path = path
    }
    
    private enum CodingKeys: String, CodingKey {
        case content
        case filename
        case path
    }
    
}
