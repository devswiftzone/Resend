//
//  EmailAttachment.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// A file attachment for an email message.
///
/// Attachments can be provided as Base64-encoded content or as a URL path
/// for the Resend API to fetch. The maximum total attachment size is 40MB.
///
/// ## Examples
///
/// ```swift
/// // Base64-encoded content
/// let attachment = EmailAttachment(
///     content: "base64EncodedString",
///     filename: "document.pdf"
/// )
///
/// // URL-based attachment
/// let attachment = EmailAttachment(
///     filename: "report.pdf",
///     path: "https://example.com/report.pdf"
/// )
/// ```
public struct EmailAttachment: Codable, Sendable {

    /// The Base64 encoded content of the attachment
    public var content: String?

    /// The filename of the attachment
    public var filename: String?

    /// URL for the Resend API to fetch the attachment from
    public var path: String?

    /// MIME type of the attachment (e.g., "application/pdf")
    public var type: String?

    public init(
        content: String? = nil,
        filename: String? = nil,
        path: String? = nil,
        type: String? = nil
    ) {
        self.content = content
        self.filename = filename
        self.path = path
        self.type = type
    }

}
