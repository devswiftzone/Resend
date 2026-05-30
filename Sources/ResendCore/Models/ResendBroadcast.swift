//
//  ResendBroadcast.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

public struct ResendBroadcast: Codable, Sendable {
    public var object: String?
    public var id: String
    public var name: String?
    public var audienceId: String?
    public var from: String?
    public var subject: String?
    public var replyTo: [String]?
    public var previewText: String?
    public var status: String?
    public var createdAt: String?
    public var scheduledAt: String?
    public var sentAt: String?

    public init(
        object: String? = nil,
        id: String,
        name: String? = nil,
        audienceId: String? = nil,
        from: String? = nil,
        subject: String? = nil,
        replyTo: [String]? = nil,
        previewText: String? = nil,
        status: String? = nil,
        createdAt: String? = nil,
        scheduledAt: String? = nil,
        sentAt: String? = nil
    ) {
        self.object = object
        self.id = id
        self.name = name
        self.audienceId = audienceId
        self.from = from
        self.subject = subject
        self.replyTo = replyTo
        self.previewText = previewText
        self.status = status
        self.createdAt = createdAt
        self.scheduledAt = scheduledAt
        self.sentAt = sentAt
    }

    private enum CodingKeys: String, CodingKey {
        case object
        case id
        case name
        case audienceId = "audience_id"
        case from
        case subject
        case replyTo = "reply_to"
        case previewText = "preview_text"
        case status
        case createdAt = "created_at"
        case scheduledAt = "scheduled_at"
        case sentAt = "sent_at"
    }
}

public struct ResendBroadcastSendResponse: Codable, Sendable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}
