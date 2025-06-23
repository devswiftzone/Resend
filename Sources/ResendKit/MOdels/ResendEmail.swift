//
//  ResendEmail.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation


public struct ResendEmail: Codable {
    public var object: String?
    public var id: String?
    public var createdAt: String?
    public var from: String
    public var to: [String]
    public var subject: String
    public var bcc: [String]?  
    public var cc: [String]?
    public var replyTo: [String]?
    public var html: String?
    public var text: String?
    public var headers: [String: String]?
    public var attachments: [EmailAttachment]?
    public var tags: [EmailTag]?
    
    public init(object: String? = nil, id: String? = nil, createdAt: String? = nil, from: String, to: [String], subject: String, bcc: [String]? = nil, cc: [String]? = nil, replyTo: [String]? = nil, html: String? = nil, text: String? = nil, headers: [String : String]? = nil, attachments: [EmailAttachment]? = nil, tags: [EmailTag]? = nil) {
        self.object = object
        self.id = id
        self.createdAt = createdAt
        self.from = from
        self.to = to
        self.subject = subject
        self.bcc = bcc
        self.cc = cc
        self.replyTo = replyTo
        self.html = html
        self.text = text
        self.headers = headers
        self.attachments = attachments
        self.tags = tags
    }
    
    private enum CodingKeys: String, CodingKey {
        case object
        case id
        case from
        case to
        case subject
        case bcc
        case cc
        case createdAt = "created_at"
        case replyTo = "reply_to"
        case html
        case text
        case headers
        case attachments
        case tags
    }
}
