//
//  ResendCommon.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// Generic list response for paginated endpoints
public struct ResendListResponse<T: Codable>: Codable, Sendable where T: Sendable {
    public var object: String
    public var data: [T]
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

/// Generic delete response
public struct ResendDeleteResponse: Codable, Sendable {
    public var object: String
    public var id: String
    public var deleted: Bool

    public init(object: String, id: String, deleted: Bool) {
        self.object = object
        self.id = id
        self.deleted = deleted
    }
}

/// Batch email response
public struct ResendBatchResponse: Codable, Sendable {
    public var data: [ResendEmailResponse]
    public var errors: [ResendBatchError]?

    public init(data: [ResendEmailResponse], errors: [ResendBatchError]? = nil) {
        self.data = data
        self.errors = errors
    }
}

public struct ResendBatchError: Codable, Sendable {
    public var index: Int
    public var message: String

    public init(index: Int, message: String) {
        self.index = index
        self.message = message
    }
}
