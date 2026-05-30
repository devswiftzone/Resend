//
//  ResendCommon.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// Generic list response for paginated endpoints.
///
/// Used by all list endpoints in the Resend API to return paginated results.
/// The `hasMore` flag indicates whether additional pages are available.
public struct ResendListResponse<T: Codable>: Codable, Sendable where T: Sendable {
    /// The object type, typically "list"
    public var object: String

    /// Array of items for the current page
    public var data: [T]

    /// Whether more results are available for pagination
    public var hasMore: Bool

    public init(object: String = "list", data: [T], hasMore: Bool = false) {
        self.object = object
        self.data = data
        self.hasMore = hasMore
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.object = try container.decode(String.self, forKey: .object)
        self.data = try container.decode([T].self, forKey: .data)
        self.hasMore = try container.decodeIfPresent(Bool.self, forKey: .hasMore) ?? false
    }

    private enum CodingKeys: String, CodingKey {
        case object
        case data
        case hasMore = "has_more"
    }
}

/// Generic delete response returned when a resource is deleted.
public struct ResendDeleteResponse: Codable, Sendable {
    /// The object type of the deleted resource
    public var object: String

    /// Unique identifier of the deleted resource
    public var id: String

    /// Whether the resource was successfully deleted
    public var deleted: Bool

    public init(object: String, id: String, deleted: Bool) {
        self.object = object
        self.id = id
        self.deleted = deleted
    }
}

/// Response from sending a batch of emails.
public struct ResendBatchResponse: Codable, Sendable {
    /// Array of individual email responses
    public var data: [ResendEmailResponse]

    /// Errors that occurred during batch sending, if any
    public var errors: [ResendBatchError]?

    public init(data: [ResendEmailResponse], errors: [ResendBatchError]? = nil) {
        self.data = data
        self.errors = errors
    }
}

/// An error that occurred for a specific email in a batch send.
public struct ResendBatchError: Codable, Sendable {
    /// The index of the email in the batch that failed
    public var index: Int

    /// Description of the error
    public var message: String

    public init(index: Int, message: String) {
        self.index = index
        self.message = message
    }
}
