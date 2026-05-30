//
//  ResendBroadcast.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// A broadcast email campaign sent to an audience.
public struct ResendBroadcast: Codable, Sendable {
    /// The object type, typically "broadcast"
    public var object: String?

    /// Unique identifier for the broadcast
    public var id: String

    /// Optional name for the broadcast campaign
    public var name: String?

    /// ID of the target audience for this broadcast
    public var audienceId: String?

    /// Sender email address
    public var from: String?

    /// Email subject line
    public var subject: String?

    /// Reply-to email addresses
    public var replyTo: [String]?

    /// Preview text shown alongside the subject line
    public var previewText: String?

    /// Current broadcast status (e.g., "draft", "sending", "sent")
    public var status: String?

    /// Timestamp when the broadcast was created
    public var createdAt: String?

    /// Timestamp when the broadcast is scheduled to send
    public var scheduledAt: String?

    /// Timestamp when the broadcast was sent
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

/// Response from sending a broadcast campaign.
public struct ResendBroadcastSendResponse: Codable, Sendable {
    /// Unique identifier for the sent broadcast
    public var id: String

    public init(id: String) {
        self.id = id
    }
}
