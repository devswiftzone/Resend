//
//  EmailAttachment.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// A file attachment for an email message.
///
/// Attachments are included as Base64-encoded content in the email payload.
/// The maximum total attachment size is 40MB.
///
/// ## Example
///
/// ```swift
/// let attachment = EmailAttachment(
///     content: "base64EncodedString",
///     filename: "document.pdf",
///     disposition: "attachment"
/// )
/// ```
public struct EmailAttachment: Codable, Sendable {

    /// The Base64 encoded content of the attachment
    public var content: String

    /// The filename of the attachment
    public var filename: String

    /// Content-disposition: "attachment" (download) or "inline" (display in email body)
    public var disposition: String

    public init(
        content: String,
        filename: String,
        disposition: String = "attachment"
    ) {
        self.content = content
        self.filename = filename
        self.disposition = disposition
    }

    private enum CodingKeys: String, CodingKey {
        case content
        case filename
        case disposition = "path"
    }

}
