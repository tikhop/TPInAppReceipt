/// A protocol for types that verify aspects of an App Store receipt.
///
/// Conforming types perform specific validation checks on receipts, such as certificate chain validation,
/// signature verification, hash verification, or metadata validation. Multiple verifiers can be composed
/// together to perform comprehensive receipt validation.
public protocol ReceiptVerifier: Sendable {
    /// Verifies the receipt asynchronously.
    ///
    /// - Parameter receipt: The receipt data to verify.
    /// - Returns: A verification result indicating success or failure with an associated error.
    func verify(_ receipt: any ReceiptValidatable) async -> VerificationResult

    /// Verifies the receipt synchronously.
    ///
    /// This is a blocking variant of the async `verify(_:)` method for use in synchronous contexts.
    ///
    /// - Parameter receipt: The receipt data to verify.
    /// - Returns: A verification result indicating success or failure with an associated error.
    @_spi(Blocking)
    func verify(_ receipt: any ReceiptValidatable) -> VerificationResult
}

/// The result of a verification operation.
///
/// Represents the outcome of a receipt verification check. Use the `isValid` or `isInvalid` properties
/// to determine the verification status.
public enum VerificationResult: Sendable {
    /// The verification succeeded.
    case valid

    /// The verification failed with an error.
    ///
    /// - Parameter error: The error that caused the verification to fail.
    case invalid(any Error)

    /// A Boolean value indicating whether the verification succeeded.
    ///
    /// - Returns: `true` if verification succeeded, `false` otherwise.
    @inlinable
    public var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .invalid:
            return false
        }
    }

    /// A Boolean value indicating whether the verification failed.
    ///
    /// - Returns: `true` if verification failed, `false` otherwise.
    @inlinable
    public var isInvalid: Bool {
        switch self {
        case .valid:
            return false
        case .invalid:
            return true
        }
    }
}
