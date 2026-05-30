import Foundation
import CryptoKit

/// Errors that can occur during webhook signature verification.
public enum WebhookVerificationError: Error, Sendable {
    /// The signature in the header does not match the computed signature
    case invalidSignature
    /// The signing secret could not be decoded
    case invalidSecret
    /// No signature header was provided
    case missingSignature
    /// The timestamp is too old (exceeds tolerance window), possible replay attack
    case timestampTooOld
}

/// Verifies webhook signatures using the Svix/Resend signing scheme.
///
/// Resend uses Svix to sign webhook payloads. Each request includes three headers:
/// - `svix-id`: Unique message identifier
/// - `svix-timestamp`: Unix timestamp of when the message was sent
/// - `svix-signature`: HMAC-SHA256 signature (format: `v1,base64_signature`)
///
/// ## Usage
///
/// ```swift
/// let valid = WebhookSignature.verify(
///     payload: rawBody,
///     id: req.headers["svix-id"] ?? "",
///     timestamp: req.headers["svix-timestamp"] ?? "",
///     signature: req.headers["svix-signature"] ?? "",
///     secret: "whsec_..."
/// )
///
/// if valid {
///     // Process webhook
/// } else {
///     // Reject
/// }
/// ```
public enum WebhookSignature {

    /// Maximum allowable age of a webhook timestamp in seconds (5 minutes).
    /// Used to prevent replay attacks.
    public static let maxTimestampAge: TimeInterval = 300

    /// Verifies a webhook signature.
    ///
    /// Computes the expected HMAC-SHA256 signature from the payload, ID, and timestamp,
    /// then compares it against the signatures in the `svix-signature` header using
    /// constant-time comparison to prevent timing attacks.
    ///
    /// - Parameters:
    ///   - payload: The raw request body as a string
    ///   - id: The `svix-id` header value
    ///   - timestamp: The `svix-timestamp` header value (Unix timestamp as string)
    ///   - signatureHeader: The `svix-signature` header value
    ///   - secret: The webhook signing secret (with or without `whsec_` prefix)
    ///   - tolerance: Maximum age in seconds for the timestamp (default 5 min). Pass `nil` to skip timestamp check.
    /// - Returns: `true` if the signature is valid
    /// - Throws: `WebhookVerificationError` if verification fails
    @discardableResult
    public static func verify(
        payload: String,
        id: String,
        timestamp: String,
        signatureHeader: String,
        secret: String,
        tolerance: TimeInterval? = maxTimestampAge
    ) throws -> Bool {
        guard !signatureHeader.isEmpty else {
            throw WebhookVerificationError.missingSignature
        }

        guard let secretData = decodeSecret(secret) else {
            throw WebhookVerificationError.invalidSecret
        }

        if let tolerance = tolerance {
            try verifyTimestamp(timestamp, tolerance: tolerance)
        }

        let signedContent = "\(id).\(timestamp).\(payload)"
        let key = SymmetricKey(data: secretData)
        let computed = Data(HMAC<SHA256>.authenticationCode(for: Data(signedContent.utf8), using: key))
        let computedBase64 = computed.base64EncodedString()

        let expectedSignatures = signatureHeader
            .split(separator: " ")
            .compactMap { piece -> String? in
                let parts = piece.split(separator: ",", maxSplits: 1)
                guard parts.count == 2, parts[0] == "v1" else { return nil }
                return String(parts[1])
            }

        guard !expectedSignatures.isEmpty else {
            throw WebhookVerificationError.invalidSignature
        }

        for expected in expectedSignatures {
            if constantTimeCompare(computedBase64, expected) {
                return true
            }
        }

        throw WebhookVerificationError.invalidSignature
    }

    /// Decode the signing secret, stripping the `whsec_` prefix if present.
    private static func decodeSecret(_ secret: String) -> Data? {
        var key = secret
        if key.hasPrefix("whsec_") {
            key = String(key.dropFirst(6))
        }
        return Data(base64Encoded: key)
    }

    /// Verify that the timestamp is within the allowed tolerance window.
    private static func verifyTimestamp(_ timestamp: String, tolerance: TimeInterval) throws {
        guard let timestampValue = TimeInterval(timestamp) else {
            throw WebhookVerificationError.timestampTooOld
        }
        let now = Date().timeIntervalSince1970
        if abs(now - timestampValue) > tolerance {
            throw WebhookVerificationError.timestampTooOld
        }
    }

    /// Constant-time string comparison to prevent timing side-channel attacks.
    private static func constantTimeCompare(_ lhs: String, _ rhs: String) -> Bool {
        let lhsBytes = Array(lhs.utf8)
        let rhsBytes = Array(rhs.utf8)
        guard lhsBytes.count == rhsBytes.count else { return false }
        var result: UInt8 = 0
        for index in 0..<lhsBytes.count {
            result |= lhsBytes[index] ^ rhsBytes[index]
        }
        return result == 0
    }
}
