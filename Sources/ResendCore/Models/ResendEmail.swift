//
//  ResendEmail.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// Represents an email to be sent or retrieved via the Resend API.
///
/// Use this structure to compose emails with various options including HTML content,
/// attachments, custom headers, and more.
///
/// ## Example
///
/// ```swift
/// let email = ResendEmail(
///     from: "onboarding@resend.dev",
///     to: ["user@example.com"],
///     subject: "Welcome!",
///     html: "<p>Thanks for signing up!</p>"
/// )
/// ```
public struct ResendEmail: Codable, Sendable {
    /// The object type, typically "email"
    public var object: String?

    /// Unique identifier for the email (set by API)
    public var id: String?

    /// Timestamp when the email was created
    public var createdAt: String?

    /// Sender email address. Must be a verified domain.
    public var from: String

    /// Recipient email addresses (max 50)
    public var to: [String]

    /// Email subject line
    public var subject: String

    /// Blind carbon copy recipients
    public var bcc: [String]?

    /// Carbon copy recipients
    public var cc: [String]?

    /// Reply-to email addresses
    public var replyTo: [String]?

    /// HTML version of the email body
    public var html: String?

    /// Plain text version of the email body
    public var text: String?

    /// Custom email headers
    public var headers: [String: String]?

    /// File attachments (max 40MB total)
    public var attachments: [EmailAttachment]?

    /// Custom metadata tags for tracking
    public var tags: [EmailTag]?
    
    public init(object: String? = nil, id: String? = nil, createAt: String? = nil, from: String, to: [String], subject: String, bcc: [String]? = nil, cc: [String]? = nil, replyTo: [String]? = nil, html: String? = nil, text: String? = nil, headers: [String : String]? = nil, attachments: [EmailAttachment]? = nil, tags: [EmailTag]? = nil) {
        self.object = object
        self.id = id
        self.createdAt = createAt
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
