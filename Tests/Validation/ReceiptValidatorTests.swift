import Foundation
import Testing
import X509

@testable import TPInAppReceipt

@Suite("ReceiptValidator")
struct ReceiptValidatorTests {
    let knownDeviceUUID = UUID(uuidString: "956328D9-CC6A-47F4-BE40-6953FB0AB6C7")!

    // MARK: - Mock Verifier Tests

    @Test
    func validationSucceedsWhenAllVerifiersPass() async throws {
        let validator = ReceiptValidator {
            MockValidVerifier()
            MockValidVerifier()
            MockValidVerifier()
        }

        let receipt = try TestingUtility.parseReceipt("Assets/receipt-sandbox-g5")
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

        let receipt = try TestingUtility.parseReceipt("Assets/receipt-sandbox-g5")
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
