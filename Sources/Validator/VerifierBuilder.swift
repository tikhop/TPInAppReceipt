
// MARK: - VerifierBuilder

/// A result builder for composing receipt verifiers.
///
/// `VerifierBuilder` is a DSL (Domain Specific Language) that enables composition
/// of `ReceiptVerifier` instances.
///
/// Use `@VerifierBuilder` syntax when initializing a `ReceiptValidator`:
///
/// ```swift
/// let validator = ReceiptValidator {
///     X509ChainVerifier(rootCertificates: [rootCert])
///     SignatureVerifier()
///     if shouldVerifyHash {
///         HashVerifier()
///     }
/// }
/// ```
@resultBuilder
public struct VerifierBuilder: Sendable { }

public extension VerifierBuilder {
    static func buildExpression(_ expression: any ReceiptVerifier) -> [any ReceiptVerifier] {
        [expression]
    }

    static func buildExpression(_ expression: [any ReceiptVerifier]) -> [any ReceiptVerifier] {
        expression
    }

    static func buildBlock() -> [any ReceiptVerifier] {
        []
    }

    static func buildPartialBlock(first policy: any ReceiptVerifier) -> [any ReceiptVerifier] {
        [policy]
    }

    static func buildPartialBlock(first policy: [any ReceiptVerifier]) -> [any ReceiptVerifier] {
        policy
    }

    static func buildPartialBlock(accumulated policies: [any ReceiptVerifier], next policy: any ReceiptVerifier) -> [any ReceiptVerifier] {
        policies + [policy]
    }

    static func buildPartialBlock(accumulated policies: [any ReceiptVerifier], next policy: [any ReceiptVerifier]) -> [any ReceiptVerifier] {
        policies + policy
    }

    static func buildOptional(_ policy: [any ReceiptVerifier]?) -> [any ReceiptVerifier] {
        policy ?? []
    }

    static func buildEither(first policy: [any ReceiptVerifier]) -> [any ReceiptVerifier] {
        policy
    }

    static func buildEither(second policy: [any ReceiptVerifier]) -> [any ReceiptVerifier] {
        policy
    }

    static func buildArray(_ policies: [[any ReceiptVerifier]]) -> [any ReceiptVerifier] {
        policies.flatMap { $0 }
    }
}
