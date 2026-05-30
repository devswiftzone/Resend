import Foundation

/// A webhook endpoint that receives event notifications from Resend.
public struct ResendWebhook: Codable, Sendable {
    /// The object type, typically "webhook"
    public var object: String?

    /// Unique identifier for the webhook
    public var id: String

    /// URL that receives webhook event payloads
    public var endpoint: String?

    /// List of event types that trigger this webhook (e.g., "email.sent", "email.bounced")
    public var events: [String]?

    /// The signing secret for verifying webhook signatures (only returned on creation)
    public var signingSecret: String?

    /// Timestamp when the webhook was created
    public var createdAt: String?

    /// Whether the webhook is disabled
    public var disabled: Bool?

    /// Timestamp when the webhook was last updated
    public var updatedAt: String?

    public init(
        object: String? = nil,
        id: String,
        endpoint: String? = nil,
        events: [String]? = nil,
        signingSecret: String? = nil,
        createdAt: String? = nil,
        disabled: Bool? = nil,
        updatedAt: String? = nil
    ) {
        self.object = object
        self.id = id
        self.endpoint = endpoint
        self.events = events
        self.signingSecret = signingSecret
        self.createdAt = createdAt
        self.disabled = disabled
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case object
        case id
        case endpoint
        case events
        case signingSecret = "signing_secret"
        case createdAt = "created_at"
        case disabled
        case updatedAt = "updated_at"
    }
}
