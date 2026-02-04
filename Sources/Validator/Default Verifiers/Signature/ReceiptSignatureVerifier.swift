#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import X509

/// The digest algorithm used to hash data before cryptographic signature verification.
///
/// This enum specifies which hashing algorithm was used to create the signature over the receipt data.
public enum DigestAlgorithm: Sendable {
    /// SHA-1 digest algorithm.
    ///
    /// A cryptographic hash function that produces a 160-bit hash value. Included for compatibility
    /// with older receipt formats.
    case sha1

    /// SHA-256 digest algorithm.
    ///
    /// A cryptographic hash function that produces a 256-bit hash value. Preferred for modern receipts.
    case sha256
}

/// Errors that occur during receipt signature verification.
///
/// Represents failures in validating the cryptographic signature that authenticates the receipt's integrity.
public enum SignatureVerificationError: Hashable, Sendable, Error {
    /// The public key extracted from the certificate is invalid, missing, or cannot be used for verification.
    case invalidKey

    /// The signature is invalid, malformed, or does not cryptographically verify against the signed data using the provided key.
    case invalidSignature
}

/// A protocol for types that verify receipt signatures.
///
/// Conforming types implement the cryptographic verification of receipt signatures using a public key.
/// They validate that the signature was created by the corresponding private key and that the signed data
/// has not been tampered with.
///
/// - Note: All types conforming to this protocol must be `Sendable`.
public protocol ReceiptSignatureVerifier: Sendable {
    /// Verifies the receipt signature asynchronously.
    ///
    /// Performs cryptographic signature verification using the specified public key and digest algorithm.
    ///
    /// - Parameters:
    ///   - key: The public key extracted from the leaf certificate, used to verify the signature.
    ///   - algorithm: The digest algorithm that was used when creating the signature.
    ///   - signedData: The original data that was signed to create the receipt signature.
    ///   - signature: The signature bytes to verify against the signed data.
    /// - Returns: A verification result indicating whether the signature is valid or the error that occurred.
    func verify(
        key: Certificate.PublicKey,
        algorithm: DigestAlgorithm,
        signedData: Data,
        signature: Data
    ) async -> VerificationResult
}
