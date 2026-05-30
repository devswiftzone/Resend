//
//  ResendClientProtocol.swift
//  ResendCore
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

import Foundation

/// Protocol defining the Resend client interface.
///
/// Conforming types provide access to all Resend API operations through
/// specialized sub-clients for each resource type.
public protocol ResendClientProtocol: Sendable {
    /// Email operations (send, retrieve, schedule, cancel)
    var email: EmailClientProtocol { get }

    /// Domain management operations
    var domains: DomainClientProtocol { get }

    /// API key management operations
    var apiKeys: APIKeyClientProtocol { get }

    /// Audience management operations
    var audiences: AudienceClientProtocol { get }

    /// Contact management operations
    var contacts: ContactClientProtocol { get }

    /// Broadcast campaign operations
    var broadcasts: BroadcastClientProtocol { get }

    /// Webhook management operations
    var webhooks: WebhookClientProtocol { get }
}

/// Protocol for email operations.
///
/// Provides methods for sending, retrieving, listing, scheduling, and canceling emails.
public protocol EmailClientProtocol: Sendable {
    /// Send an email
    func send(email: ResendEmail) async throws -> ResendEmailResponse
    /// Retrieve a sent email by ID
    func retrieve(id: String) async throws -> ResendEmail
    /// Update the scheduled time for an email
    func update(id: String, scheduledAt: String) async throws -> ResendEmailResponse
    /// Cancel a scheduled email
    func cancel(id: String) async throws -> ResendEmailResponse
    /// Send a batch of emails in a single API call
    func sendBatch(emails: [ResendEmail]) async throws -> ResendBatchResponse
    /// List sent emails with cursor-based pagination
    func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendEmail>
    /// List all sent emails using automatic cursor pagination
    func listAll(limit: Int?) -> PaginatedSequence<ResendEmail>
}

/// Protocol for domain operations.
///
/// Provides methods for creating, verifying, and managing sending domains.
public protocol DomainClientProtocol: Sendable {
    /// Create a new domain for sending emails
    func create(name: String, region: String?, customReturnPath: String?) async throws -> ResendDomain
    /// Retrieve a domain by ID
    func get(id: String) async throws -> ResendDomain
    /// List domains with cursor-based pagination
    func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendDomain>
    /// List all domains using automatic cursor pagination
    func listAll(limit: Int?) -> PaginatedSequence<ResendDomain>
    /// Verify domain ownership via DNS records
    func verify(id: String) async throws -> ResendDomain
    /// Update domain settings
    func update(id: String, clickTracking: Bool?, openTracking: Bool?, tls: String?) async throws -> ResendDomain
    /// Delete a domain
    func delete(id: String) async throws -> ResendDeleteResponse
}

/// Protocol for API key operations.
///
/// Provides methods for creating, retrieving, listing, and deleting API keys.
public protocol APIKeyClientProtocol: Sendable {
    /// Create a new API key
    func create(name: String, permission: String?, domainId: String?) async throws -> ResendAPIKey
    /// List API keys with cursor-based pagination
    func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendAPIKeyListItem>
    /// List all API keys using automatic cursor pagination
    func listAll(limit: Int?) -> PaginatedSequence<ResendAPIKeyListItem>
    /// Delete an API key
    func delete(id: String) async throws -> ResendDeleteResponse
}

/// Protocol for audience operations.
///
/// Provides methods for creating, updating, and managing audience groups for broadcast campaigns.
public protocol AudienceClientProtocol: Sendable {
    /// Create a new audience
    func create(name: String) async throws -> ResendAudience
    /// Retrieve an audience by ID
    func get(id: String) async throws -> ResendAudience
    /// List audiences with cursor-based pagination
    func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendAudience>
    /// List all audiences using automatic cursor pagination
    func listAll(limit: Int?) -> PaginatedSequence<ResendAudience>
    /// Update an audience's name
    func update(id: String, name: String) async throws -> ResendAudience
    /// Delete an audience
    func delete(id: String) async throws -> ResendDeleteResponse
}

/// Protocol for contact operations.
///
/// Provides methods for managing contacts within an audience.
public protocol ContactClientProtocol: Sendable {
    /// Create a new contact in an audience
    func create(audienceId: String, email: String, firstName: String?, lastName: String?, unsubscribed: Bool?) async throws -> ResendContact
    /// Retrieve a contact by audience ID and contact identifier
    func get(audienceId: String, identifier: String) async throws -> ResendContact
    /// List contacts in an audience with cursor-based pagination
    func list(audienceId: String, limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendContact>
    /// List all contacts in an audience using automatic cursor pagination
    func listAll(audienceId: String, limit: Int?) -> PaginatedSequence<ResendContact>
    /// Update a contact's information
    func update(audienceId: String, identifier: String, firstName: String?, lastName: String?, unsubscribed: Bool?) async throws -> ResendContact
    /// Delete a contact from an audience
    func delete(audienceId: String, identifier: String) async throws -> ResendDeleteResponse
}

/// Protocol for webhook operations.
///
/// Provides methods for creating and managing webhook endpoints
/// that receive event notifications from Resend.
public protocol WebhookClientProtocol: Sendable {
    /// Create a new webhook endpoint
    func create(endpoint: String, events: [String]) async throws -> ResendWebhook
    /// Retrieve a webhook by ID
    func get(id: String) async throws -> ResendWebhook
    /// List webhooks with cursor-based pagination
    func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendWebhook>
    /// List all webhooks using automatic cursor pagination
    func listAll(limit: Int?) -> PaginatedSequence<ResendWebhook>
    /// Update a webhook's configuration
    func update(id: String, endpoint: String?, events: [String]?, disabled: Bool?) async throws -> ResendWebhook
    /// Delete a webhook
    func delete(id: String) async throws -> ResendDeleteResponse
}

/// Protocol for broadcast operations.
///
/// Provides methods for creating and sending broadcast email campaigns to audiences.
public protocol BroadcastClientProtocol: Sendable {
    /// Create a new broadcast campaign
    func create(audienceId: String, from: String, subject: String, replyTo: [String]?, html: String?, text: String?, name: String?) async throws -> ResendBroadcast
    /// Retrieve a broadcast by ID
    func get(id: String) async throws -> ResendBroadcast
    /// List broadcasts with cursor-based pagination
    func list(limit: Int?, after: String?, before: String?) async throws -> ResendListResponse<ResendBroadcast>
    /// List all broadcasts using automatic cursor pagination
    func listAll(limit: Int?) -> PaginatedSequence<ResendBroadcast>
    /// Update a broadcast campaign
    func update(id: String, audienceId: String?, from: String?, subject: String?, replyTo: [String]?, html: String?, text: String?, name: String?) async throws -> ResendBroadcast
    /// Send a broadcast campaign
    func send(id: String, scheduledAt: String?) async throws -> ResendBroadcastSendResponse
    /// Delete a broadcast
    func delete(id: String) async throws -> ResendDeleteResponse
}
