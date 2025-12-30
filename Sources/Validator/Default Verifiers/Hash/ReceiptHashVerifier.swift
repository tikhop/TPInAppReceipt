#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Errors that occur during receipt hash verification.
///
/// Represents failures in validating the receipt hash, which is computed from device, app, and receipt data.
public enum HashVerificationError: Hashable, Sendable, Error {
    /// The device identifier is missing and cannot be used for hash computation.
    case missingDeviceIdentifier

    /// The computed hash does not match the hash stored in the receipt.
    ///
    /// This indicates the receipt may have been tampered with or is being validated on a different device.
    case hashMismatch
}

/// A protocol for types that verify receipt hashes.
///
/// Conforming types compute a hash using device-specific information and verify it matches the hash
/// stored in the receipt. This ensures the receipt was issued for the specific device and app that is
/// validating it, preventing misuse of receipts across devices or apps.
///
/// - Note: All types conforming to this protocol must be `Sendable`.
public protocol ReceiptHashVerifier: Sendable {
    /// Verifies the receipt hash.
    ///
    /// Computes a hash using the opaque value, bundle identifier, and the device's unique identifier,
    /// then compares it to the expected hash from the receipt.
    ///
    /// - Parameters:
    ///   - expectedHash: The hash value stored in the receipt to verify against.
    ///   - opaqueValue: The opaque value from the receipt, used in hash computation.
    ///   - bundleIdentifier: The bundle identifier data from the receipt, used in hash computation.
    /// - Returns: A verification result indicating whether the hash matches or the error that occurred.
    func verify(
        expectedHash: Data,
        opaqueValue: Data,
        bundleIdentifier: Data
    ) -> VerificationResult
}
