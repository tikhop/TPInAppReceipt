#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import X509

/// Errors that occur during certificate chain verification.
///
/// Represents failures in validating the X.509 certificate chain from the leaf certificate to the root.
public enum ChainVerificationError: Hashable, Sendable, Error {
    /// The certificate data is invalid, malformed, or cannot be decoded.
    case invalidCertificateData

    /// The certificate chain validation failed.
    ///
    /// This can occur when certificates are expired, self-signed, untrusted, or the chain is incomplete.
    case chainValidationFailed

    /// The certificate revocation check failed or the certificate has been revoked.
    case revocationCheckFailed
}

/// Policies that control how certificate chain verification is performed.
///
/// These policies specify validation rules and constraints applied during certificate chain verification.
public enum ReceiptChainVerifierPolicy: Sendable {
    /// Use Apple's basic X.509 validation policies for certificate verification.
    case appleX509Basic

    /// Use App Store specific validation policies.
    ///
    /// - Note: This policy doesn't work in Xcode development environments.
    case appStoreReceipt

    /// Validate the certificate chain as if it was on the specified date.
    ///
    /// Ensures certificates were valid on the given date, useful for historical receipt validation.
    case validationTime(Date)

    /// Use the specified date for online revocation checks, if any.
    case onlineValidationTime(Date)
}

/// A protocol for types that verify certificate chains in receipts.
///
/// Conforming types validate the X.509 certificate chain used to sign a receipt, ensuring that
/// the leaf certificate chains up to the Apple root certificate and that all certificates in the
/// chain are valid, properly chained, and not revoked.
///
/// - Note: All types conforming to this protocol must be `Sendable`.
public protocol ReceiptChainVerifier: Sendable {
    /// Verifies the certificate chain asynchronously.
    ///
    /// Validates that the leaf certificate is properly chained to the intermediate certificate(s),
    /// and that the chain is valid according to the specified policies.
    ///
    /// - Parameters:
    ///   - leaf: The leaf certificate from the receipt to verify.
    ///   - intermediate: Array of intermediate certificates in the chain. Should include all
    ///     certificates between the leaf and the root (typically one intermediate for App Store receipts).
    ///   - policy: Array of verification policies to apply. Controls how validation is performed
    ///     (e.g., which X.509 policies to use, what date to validate against).
    /// - Returns: A verification result indicating whether the chain is valid or the error that occurred.
    func verify(
        leaf: Certificate,
        intermediate: [Certificate],
        policy: [ReceiptChainVerifierPolicy]
    ) async -> VerificationResult
}
