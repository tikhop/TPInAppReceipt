import Foundation
import Testing

@testable import TPInAppReceipt

// MARK: - Mock Verifiers

struct MockValidVerifier: ReceiptVerifier {
    func verify(_: ReceiptValidatable) async -> VerificationResult {
        .valid
    }
}

struct MockInvalidVerifier: ReceiptVerifier {
    let error: Error

    func verify(_: ReceiptValidatable) async -> VerificationResult {
        .invalid(error)
    }
}

struct MockVerificationError: Error, Equatable {
    let message: String
}
