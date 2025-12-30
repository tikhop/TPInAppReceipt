#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import X509

// MARK: - ReceiptValidatable

/// A protocol for objects that contain App Store receipt data for validation.
///
/// This protocol defines the interface for accessing and validating receipt properties required by verifiers.
public protocol ReceiptValidatable: Sendable {
    /// The environment where the receipt was generated (sandbox or production).
    var environment: InAppReceiptPayload.Environment { get }

    /// The version identifier of the app that generated the receipt.
    var versionIdentifier: String { get }

    /// The app's bundle identifier as a string.
    var bundleIdentifier: String { get }

    /// The app's bundle identifier encoded as data.
    var bundleIdentifierData: Data { get }

    /// The certificate chain used to sign the receipt, parsed as `Certificate` objects.
    var certificates: [Certificate] { get }

    /// The raw certificate data from the receipt.
    var certificatesRaw: [Data] { get }

    /// The expected hash value computed from the receipt's opaque value, bundle identifier, and device identifier.
    var receiptHash: Data { get }

    /// The opaque value from the receipt used in hash computation.
    var opaqueValue: Data { get }

    /// The data that was signed to create the receipt signature.
    var digestData: Data { get }

    /// The digest algorithm used to hash the signed data.
    var digestAlgorithm: DigestAlgorithm { get }

    /// The signature that verifies the authenticity of the receipt.
    var signature: Data { get }

    /// The date to use for validating certificate expiration and other time-dependent verification checks.
    var validationTime: Date { get }
}

extension ReceiptValidatable {
    var leafCertificate: Certificate? {
        certificates.first
    }

    var intermediateCertificates: [Certificate] {
        guard certificates.count > 1 else {
            return []
        }

        return [certificates[1]]
    }

    var publicKey: Certificate.PublicKey? {
        leafCertificate?.publicKey
    }
}
