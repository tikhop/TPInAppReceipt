#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import X509

/// Errors that can occur during receipt validation.
///
/// This error type represents various failures that can occur when validating App Store receipts.
public enum ReceiptValidatorError: Error, Sendable {
    /// The root certificate is invalid or cannot be decoded.
    case rootCertificateInvalid((any Error)?)

    /// The device identifier could not be retrieved.
    case deviceIdentifierIsNotFound

    /// The receipt structure is invalid or missing required fields.
    case invalidReceiptStructure
}

// MARK: - ReceiptValidator

/// Validates App Store receipts using a composition of verifiers.
///
/// `ReceiptValidator` runs multiple verification checks on a receipt in parallel using task groups.
/// It composes multiple `ReceiptVerifier` instances, each responsible for a specific verification aspect.
/// If any verifier fails, validation immediately returns that failure without running remaining verifiers.
///
/// Use the `@VerifierBuilder` result builder to compose verifiers:
///
/// ```swift
/// let validator = ReceiptValidator {
///     X509ChainVerifier(rootCertificates: [rootCert])
///     SignatureVerifier()
///     HashVerifier()
/// }
/// ```
public struct ReceiptValidator: Sendable {
    let verifiers: [any ReceiptVerifier]

    /// Creates a receipt validator with the specified verifiers.
    ///
    /// - Parameter policies: A builder closure that returns an array of verifiers to run.
    ///   Use the `@VerifierBuilder` syntax to compose verifiers.
    public init(@VerifierBuilder policies: () -> [any ReceiptVerifier]) {
        verifiers = policies()
    }

    /// Validates a receipt asynchronously using all configured verifiers.
    ///
    /// The validation runs verifiers in parallel using task groups. If any verifier fails,
    /// remaining verifiers are cancelled and the failure is immediately returned.
    ///
    /// - Parameter receipt: The receipt to validate.
    /// - Returns: A verification result indicating whether all verifications passed or the first failure.
    public func validate(_ receipt: any ReceiptValidatable) async -> VerificationResult {
        await withTaskGroup(of: VerificationResult.self) { group in
            for verifier in verifiers {
                group.addTask {
                    await verifier.verify(receipt)
                }
            }

            for await result in group {
                if case let .invalid(error) = result {
                    group.cancelAll()
                    return .invalid(error)
                }
            }

            return .valid
        }
    }
}

extension ReceiptValidator {
    /// Creates a default validator with all standard verification checks.
    ///
    /// This factory method creates a fully configured receipt validator that performs:
    /// - X.509 certificate chain verification against the provided root certificate
    /// - Cryptographic signature verification
    /// - Receipt hash verification
    /// - Metadata verification (bundle identifier and app version)
    ///
    /// - Parameters:
    ///   - rootCertificate: The Apple root certificate in DER-encoded format.
    ///   - deviceIdentifier: The device identifier data for hash verification.
    /// - Returns: A configured `ReceiptValidator` instance.
    /// - Throws: An error if the root certificate cannot be decoded.
    public static func `default`(
        rootCertificate: Data,
        deviceIdentifier: Data,
        environment: InAppReceiptPayload.Environment,
        needsMetadataVerification: Bool = true
    ) throws -> ReceiptValidator {
        try defaultValidator(
            rootCertificate: rootCertificate,
            deviceIdentifier: deviceIdentifier,
            environment: environment,
            isBlockingApi: false,
            needsMetadataVerification: needsMetadataVerification
        )
    }

    internal static func defaultValidator(
        rootCertificate: Data,
        deviceIdentifier: Data,
        environment: InAppReceiptPayload.Environment,
        isBlockingApi: Bool,
        needsMetadataVerification: Bool
    ) throws -> ReceiptValidator {
        let chainVerifier: ReceiptVerifier =
            (isBlockingApi || environment == .xcode)
            ? try SecChainVerifier(rootCertificates: [rootCertificate])
            : try X509ChainVerifier(rootCertificates: [rootCertificate])

        return ReceiptValidator {
            chainVerifier
            isBlockingApi ? SecSignatureVerifier() : SignatureVerifier()
            #if !targetEnvironment(simulator)
            HashVerifier(deviceIdentifier: deviceIdentifier)
            #endif
            if needsMetadataVerification {
                MetaVerifier(
                    appVersionProvider: nativeAppVersionProvider,
                    bundleIdentifierProvider: nativeBundleIdentifierProvider
                )
            }
        }
    }
}
