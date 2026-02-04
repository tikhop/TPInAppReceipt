import Foundation
import Testing

@testable import TPInAppReceipt

@Suite("VerifierBuilder")
struct VerifierBuilderTests {
    @Test
    func emptyBuilderProducesNoVerifiers() {
        let validator = ReceiptValidator {}

        #expect(validator.verifiers.count == 0)
    }

    @Test
    func builderPreservesOrder() {
        let error1 = MockVerificationError(message: "First")
        let error2 = MockVerificationError(message: "Second")
        let error3 = MockVerificationError(message: "Third")

        let validator = ReceiptValidator {
            MockInvalidVerifier(error: error1)
            MockInvalidVerifier(error: error2)
            MockInvalidVerifier(error: error3)
        }

        #expect(validator.verifiers.count == 3)
        let verifier1 = validator.verifiers[0] as! MockInvalidVerifier
        let verifier2 = validator.verifiers[1] as! MockInvalidVerifier
        let verifier3 = validator.verifiers[2] as! MockInvalidVerifier

        #expect(verifier1.error as? MockVerificationError == error1)
        #expect(verifier2.error as? MockVerificationError == error2)
        #expect(verifier3.error as? MockVerificationError == error3)
    }

    @Test
    func builderComposesConditionalAndLoopVerifiers() {
        let includeOptional = true
        let extras = [MockValidVerifier(), MockValidVerifier()]

        let validator = ReceiptValidator {
            MockValidVerifier()
            if includeOptional {
                MockValidVerifier()
            }
            for verifier in extras {
                verifier
            }
        }

        #expect(validator.verifiers.count == 4)
    }
}
