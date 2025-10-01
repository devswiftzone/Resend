//
//  ResendClientProtocol.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// Protocol defining the Resend client interface
public protocol ResendClientProtocol {
    var email: EmailClientProtocol { get }
    var domains: DomainClientProtocol { get }
    var apiKeys: APIKeyClientProtocol { get }
    var audiences: AudienceClientProtocol { get }
    var contacts: ContactClientProtocol { get }
    var broadcasts: BroadcastClientProtocol { get }
}

/// Protocol for email operations
public protocol EmailClientProtocol {
    func send(email: ResendEmail) async throws -> ResendEmailResponse
    func retrieve(id: String) async throws -> ResendEmail
    func update(id: String, scheduledAt: String) async throws -> ResendEmailResponse
    func cancel(id: String) async throws -> ResendEmailResponse
    func sendBatch(emails: [ResendEmail]) async throws -> ResendBatchResponse
}

/// Protocol for domain operations
public protocol DomainClientProtocol {
    func create(name: String, region: String?, customReturnPath: String?) async throws -> ResendDomain
    func get(id: String) async throws -> ResendDomain
    func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendDomain>
    func verify(id: String) async throws -> ResendDomain
    func update(id: String, clickTracking: Bool?, openTracking: Bool?, tls: String?) async throws -> ResendDomain
    func delete(id: String) async throws -> ResendDeleteResponse
}

/// Protocol for API key operations
public protocol APIKeyClientProtocol {
    func create(name: String, permission: String?, domainId: String?) async throws -> ResendAPIKey
    func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendAPIKeyListItem>
    func delete(id: String) async throws
}

/// Protocol for audience operations
public protocol AudienceClientProtocol {
    func create(name: String) async throws -> ResendAudience
    func get(id: String) async throws -> ResendAudience
    func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendAudience>
    func delete(id: String) async throws -> ResendDeleteResponse
}

/// Protocol for contact operations
public protocol ContactClientProtocol {
    func create(audienceId: String, email: String, firstName: String?, lastName: String?, unsubscribed: Bool?) async throws -> ResendContact
    func get(audienceId: String, identifier: String) async throws -> ResendContact
    func list(audienceId: String, limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendContact>
    func update(audienceId: String, identifier: String, firstName: String?, lastName: String?, unsubscribed: Bool?) async throws -> ResendContact
    func delete(audienceId: String, identifier: String) async throws -> ResendDeleteResponse
}

/// Protocol for broadcast operations
public protocol BroadcastClientProtocol {
    func create(audienceId: String, from: String, subject: String, replyTo: [String]?, html: String?, text: String?, name: String?) async throws -> ResendBroadcast
    func get(id: String) async throws -> ResendBroadcast
    func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendBroadcast>
    func update(id: String, audienceId: String?, from: String?, subject: String?, replyTo: [String]?, html: String?, text: String?, name: String?) async throws -> ResendBroadcast
    func send(id: String, scheduledAt: String?) async throws -> ResendBroadcastSendResponse
    func delete(id: String) async throws -> ResendDeleteResponse
}
