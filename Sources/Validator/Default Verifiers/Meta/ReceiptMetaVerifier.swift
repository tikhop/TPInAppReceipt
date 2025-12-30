/// Errors that occur during receipt metadata verification.
///
/// Represents failures in validating that the receipt belongs to the correct app and version.
public enum MetaVerificationError: Hashable, Sendable, Error {
    /// The bundle identifier in the receipt does not match the expected app's bundle identifier.
    ///
    /// This can indicate the receipt is being used for a different app than it was issued for.
    case bundleIdentifierMismatch

    /// The version identifier in the receipt does not match the expected app version.
    case versionIdentifierMismatch

    /// The app's bundle information could not be retrieved from the main bundle.
    case bundleInfoUnavailable
}

/// A protocol for types that verify receipt metadata.
///
/// Conforming types validate that the receipt's metadata (bundle identifier and version identifier)
/// matches the expected values for the app, ensuring the receipt was issued for the correct app
/// and version.
///
/// - Note: All types conforming to this protocol must be `Sendable`.
public protocol ReceiptMetaVerifier: Sendable {
    /// Verifies the receipt metadata.
    ///
    /// Validates that the receipt's bundle identifier and version identifier match the expected values.
    ///
    /// - Parameters:
    ///   - bundleIdentifier: The expected bundle identifier that should be in the receipt.
    ///   - versionIdentifier: The expected version identifier that should be in the receipt.
    /// - Returns: A verification result indicating whether the metadata is correct or the error that occurred.
    func verify(
        bundleIdentifier: String,
        versionIdentifier: String
    ) -> VerificationResult
}
