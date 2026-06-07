import Testing
import Foundation
#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif
@testable import ResendKit

@Suite("WebhookSignature Tests")
struct WebhookSignatureTests {

    // Test vectors generated using known inputs and Svix algorithm
    private let testSecret = "whsec_MfUWQVGajs3kLzqLJArNZ/AKLqOQJbK1GGRKJdZ6l6E="
    private let testPayload = #"{"test": 2432232314}"#
    private let testId = "msg_p5jXN8AQM9LWM0D4loKWxJek"
    private let testTimestamp = "1614265330"

    private func makeSignature(secret: String, id: String, timestamp: String, payload: String) -> String {
        var key = secret
        if key.hasPrefix("whsec_") { key = String(key.dropFirst(6)) }
        guard let keyData = Data(base64Encoded: key) else { return "" }
        let cryptoKey = SymmetricKey(data: keyData)
        let signed = "\(id).\(timestamp).\(payload)"
        let code = HMAC<SHA256>.authenticationCode(for: Data(signed.utf8), using: cryptoKey)
        return "v1,\(Data(code).base64EncodedString())"
    }

    @Test("Verifies valid signature")
    func testValidSignature() throws {
        let signature = makeSignature(secret: testSecret, id: testId, timestamp: testTimestamp, payload: testPayload)

        let result = try WebhookSignature.verify(
            payload: testPayload,
            id: testId,
            timestamp: testTimestamp,
            signatureHeader: signature,
            secret: testSecret,
            tolerance: nil  // Skip timestamp check
        )

        #expect(result == true)
    }

    @Test("Rejects invalid signature")
    func testInvalidSignature() throws {
        let signature = "v1,invalidsignaturebase64="

        #expect(throws: WebhookVerificationError.invalidSignature) {
            try WebhookSignature.verify(
                payload: testPayload,
                id: testId,
                timestamp: testTimestamp,
                signatureHeader: signature,
                secret: testSecret,
                tolerance: nil
            )
        }
    }

    @Test("Throws on missing signature header")
    func testMissingSignature() {
        #expect(throws: WebhookVerificationError.missingSignature) {
            try WebhookSignature.verify(
                payload: testPayload,
                id: testId,
                timestamp: testTimestamp,
                signatureHeader: "",
                secret: testSecret,
                tolerance: nil
            )
        }
    }

    @Test("Rejects signature without v1 prefix")
    func testWrongVersion() throws {
        let sig = makeSignature(secret: testSecret, id: testId, timestamp: testTimestamp, payload: testPayload)
        let wrongVersion = sig.replacingOccurrences(of: "v1", with: "v2")

        #expect(throws: WebhookVerificationError.invalidSignature) {
            try WebhookSignature.verify(
                payload: testPayload,
                id: testId,
                timestamp: testTimestamp,
                signatureHeader: wrongVersion,
                secret: testSecret,
                tolerance: nil
            )
        }
    }

    @Test("Rejects tampered payload")
    func testTamperedPayload() throws {
        let signature = makeSignature(secret: testSecret, id: testId, timestamp: testTimestamp, payload: testPayload)

        #expect(throws: WebhookVerificationError.invalidSignature) {
            try WebhookSignature.verify(
                payload: #"{"test": 123}"#,  // Different payload
                id: testId,
                timestamp: testTimestamp,
                signatureHeader: signature,
                secret: testSecret,
                tolerance: nil
            )
        }
    }

    @Test("Accepts secret without whsec_ prefix")
    func testSecretWithoutPrefix() throws {
        let secretNoPrefix = String(testSecret.dropFirst(6))
        let signature = makeSignature(secret: testSecret, id: testId, timestamp: testTimestamp, payload: testPayload)

        let result = try WebhookSignature.verify(
            payload: testPayload,
            id: testId,
            timestamp: testTimestamp,
            signatureHeader: signature,
            secret: secretNoPrefix,
            tolerance: nil
        )

        #expect(result == true)
    }

    @Test("Rejects expired timestamp")
    func testExpiredTimestamp() {
        let oldTimestamp = "1000000000"  // Year 2001

        #expect(throws: WebhookVerificationError.timestampTooOld) {
            try WebhookSignature.verify(
                payload: testPayload,
                id: testId,
                timestamp: oldTimestamp,
                signatureHeader: "v1,test",
                secret: testSecret,
                tolerance: 300
            )
        }
    }

    @Test("Multiple signatures with one valid")
    func testMultipleSignatures() throws {
        let validSig = makeSignature(secret: testSecret, id: testId, timestamp: testTimestamp, payload: testPayload)
        let multipleHeaders = "v1,fakesignature= \(validSig)"

        let result = try WebhookSignature.verify(
            payload: testPayload,
            id: testId,
            timestamp: testTimestamp,
            signatureHeader: multipleHeaders,
            secret: testSecret,
            tolerance: nil
        )

        #expect(result == true)
    }

    @Test("Multiple signatures all invalid")
    func testAllInvalidSignatures() {
        let multipleHeaders = "v1,fakesig1= v1,fakesig2="

        #expect(throws: WebhookVerificationError.invalidSignature) {
            try WebhookSignature.verify(
                payload: testPayload,
                id: testId,
                timestamp: testTimestamp,
                signatureHeader: multipleHeaders,
                secret: testSecret,
                tolerance: nil
            )
        }
    }

    @Test("Rejects future timestamp")
    func testFutureTimestamp() {
        let futureTimestamp = "1999999999"  // Year 2033

        #expect(throws: WebhookVerificationError.timestampTooOld) {
            try WebhookSignature.verify(
                payload: testPayload,
                id: testId,
                timestamp: futureTimestamp,
                signatureHeader: "v1,test",
                secret: testSecret,
                tolerance: 300
            )
        }
    }

    @Test("Accepts empty payload")
    func testEmptyPayload() throws {
        let signature = makeSignature(secret: testSecret, id: testId, timestamp: testTimestamp, payload: "")

        let result = try WebhookSignature.verify(
            payload: "",
            id: testId,
            timestamp: testTimestamp,
            signatureHeader: signature,
            secret: testSecret,
            tolerance: nil
        )

        #expect(result == true)
    }

    @Test("Skips timestamp check when tolerance is nil")
    func testSkipTimestampCheck() throws {
        let oldTimestamp = "1000000000"  // Year 2001
        let signature = makeSignature(secret: testSecret, id: testId, timestamp: oldTimestamp, payload: testPayload)

        let result = try WebhookSignature.verify(
            payload: testPayload,
            id: testId,
            timestamp: oldTimestamp,
            signatureHeader: signature,
            secret: testSecret,
            tolerance: nil
        )

        #expect(result == true)
    }

    @Test("Throws on invalid base64 secret")
    func testInvalidSecret() {
        let invalidSecret = "not-valid-base64!!!"
        let signature = "v1,test"

        #expect(throws: WebhookVerificationError.invalidSecret) {
            try WebhookSignature.verify(
                payload: testPayload,
                id: testId,
                timestamp: testTimestamp,
                signatureHeader: signature,
                secret: invalidSecret,
                tolerance: nil
            )
        }
    }

    @Test("Signature header with trailing spaces")
    func testSignatureTrailingSpaces() throws {
        let validSig = makeSignature(secret: testSecret, id: testId, timestamp: testTimestamp, payload: testPayload)
        let signatureWithSpaces = "  \(validSig)  "

        let result = try WebhookSignature.verify(
            payload: testPayload,
            id: testId,
            timestamp: testTimestamp,
            signatureHeader: signatureWithSpaces,
            secret: testSecret,
            tolerance: nil
        )

        #expect(result == true)
    }
}
