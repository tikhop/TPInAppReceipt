import Foundation
import Testing

@testable import TPInAppReceipt

@Suite("ReceiptValidator")
struct ReceiptValidatorTests {
    @Test
    func validationSucceedsWhenAllVerifiersPass() async throws {
        let validator = ReceiptValidator {
            MockValidVerifier()
            MockValidVerifier()
            MockValidVerifier()
        }

        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let result = await validator.validate(receipt)

        #expect(result.isValid)
    }

    @Test
    func validationFailsWhenAnyVerifierFails() async throws {
        let expectedError = MockVerificationError(message: "Verification failed")

        let validator = ReceiptValidator {
            MockValidVerifier()
            MockInvalidVerifier(error: expectedError)
            MockValidVerifier()
        }

        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let result = await validator.validate(receipt)

        #expect(result.isInvalid)

        if case let .invalid(error) = result {
            #expect(error is MockVerificationError)
            if let mockError = error as? MockVerificationError {
                #expect(mockError == expectedError)
            }
        }
    }
}
