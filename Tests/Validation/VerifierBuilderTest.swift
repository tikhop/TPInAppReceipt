import Testing
import Foundation

@testable import TPInAppReceipt

// MARK: - VerifierBuilder Tests

@Suite("VerifierBuilder Tests")
struct VerifierBuilderTests {

    // MARK: - Basic Building Tests

    @Test("VerifierBuilder builds empty array")
    func testBuildEmptyArray() {
        let validator = ReceiptValidator {
        }

        #expect(validator.verifiers.count == 0)
    }

    @Test("VerifierBuilder builds single verifier")
    func testBuildSingleVerifier() {
        let validator = ReceiptValidator {
            MockValidVerifier()
        }

        #expect(validator.verifiers.count == 1)
    }

    @Test("VerifierBuilder builds multiple verifiers")
    func testBuildMultipleVerifiers() {
        let validator = ReceiptValidator {
            MockValidVerifier()
            MockValidVerifier()
            MockValidVerifier()
        }

        #expect(validator.verifiers.count == 3)
    }

    @Test("VerifierBuilder preserves order of verifiers")
    func testBuildPreservesOrder() {
        let error1 = MockVerificationError(message: "First")
        let error2 = MockVerificationError(message: "Second")
        let error3 = MockVerificationError(message: "Third")

        let validator = ReceiptValidator {
            MockInvalidVerifier(error: error1)
            MockInvalidVerifier(error: error2)
            MockInvalidVerifier(error: error3)
        }

        #expect(validator.verifiers.count == 3)
        // Verify order is preserved by checking the errors
        let verifier1 = validator.verifiers[0] as! MockInvalidVerifier
        let verifier2 = validator.verifiers[1] as! MockInvalidVerifier
        let verifier3 = validator.verifiers[2] as! MockInvalidVerifier

        #expect(verifier1.error as? MockVerificationError == error1)
        #expect(verifier2.error as? MockVerificationError == error2)
        #expect(verifier3.error as? MockVerificationError == error3)
    }

    // MARK: - Conditional Building Tests

    @Test("VerifierBuilder supports if statement with true condition")
    func testBuildWithIfTrue() {
        let includeVerifier = true

        let validator = ReceiptValidator {
            MockValidVerifier()
            if includeVerifier {
                MockValidVerifier()
            }
            MockValidVerifier()
        }

        #expect(validator.verifiers.count == 3)
    }

    @Test("VerifierBuilder supports if statement with false condition")
    func testBuildWithIfFalse() {
        let includeVerifier = false

        let validator = ReceiptValidator {
            MockValidVerifier()
            if includeVerifier {
                MockValidVerifier()
            }
            MockValidVerifier()
        }

        #expect(validator.verifiers.count == 2)
    }

    @Test("VerifierBuilder supports if-else with true condition")
    func testBuildWithIfElseTrue() {
        let useFirstBranch = true

        let validator = ReceiptValidator {
            if useFirstBranch {
                MockValidVerifier()
            } else {
                MockInvalidVerifier(error: MockVerificationError(message: "Should not run"))
            }
        }

        #expect(validator.verifiers.count == 1)
        #expect(validator.verifiers[0] is MockValidVerifier)
    }

    @Test("VerifierBuilder supports if-else with false condition")
    func testBuildWithIfElseFalse() {
        let useFirstBranch = false

        let validator = ReceiptValidator {
            if useFirstBranch {
                MockValidVerifier()
            } else {
                MockInvalidVerifier(error: MockVerificationError(message: "Should run"))
            }
        }

        #expect(validator.verifiers.count == 1)
        #expect(validator.verifiers[0] is MockInvalidVerifier)
    }

    @Test("VerifierBuilder supports nested if statements")
    func testBuildWithNestedIf() {
        let outerCondition = true
        let innerCondition = true

        let validator = ReceiptValidator {
            MockValidVerifier()
            if outerCondition {
                MockValidVerifier()
                if innerCondition {
                    MockValidVerifier()
                }
            }
            MockValidVerifier()
        }

        #expect(validator.verifiers.count == 4)
    }

    @Test("VerifierBuilder supports multiple if statements")
    func testBuildWithMultipleIf() {
        let condition1 = true
        let condition2 = false
        let condition3 = true

        let validator = ReceiptValidator {
            if condition1 {
                MockValidVerifier()
            }
            if condition2 {
                MockValidVerifier()
            }
            if condition3 {
                MockValidVerifier()
            }
        }

        #expect(validator.verifiers.count == 2)
    }

    // MARK: - Loop Building Tests

    @Test("VerifierBuilder supports for-in loops")
    func testBuildWithForLoop() {
        let additionalVerifiers = [
            MockValidVerifier(),
            MockValidVerifier(),
            MockValidVerifier()
        ]

        let validator = ReceiptValidator {
            MockValidVerifier()
            for verifier in additionalVerifiers {
                verifier
            }
        }

        #expect(validator.verifiers.count == 4)
    }

    @Test("VerifierBuilder supports empty for-in loops")
    func testBuildWithEmptyForLoop() {
        let additionalVerifiers: [MockValidVerifier] = []

        let validator = ReceiptValidator {
            MockValidVerifier()
            for verifier in additionalVerifiers {
                verifier
            }
            MockValidVerifier()
        }

        #expect(validator.verifiers.count == 2)
    }

    @Test("VerifierBuilder supports for-in with range")
    func testBuildWithRangeLoop() {
        let validator = ReceiptValidator {
            for _ in 0..<3 {
                MockValidVerifier()
            }
        }

        #expect(validator.verifiers.count == 3)
    }

    // MARK: - Mixed Control Flow Tests

    @Test("VerifierBuilder supports mixed if and for statements")
    func testBuildWithMixedControlFlow() {
        let includeLoop = true
        let additionalVerifiers = [MockValidVerifier(), MockValidVerifier()]

        let validator = ReceiptValidator {
            MockValidVerifier()
            if includeLoop {
                for verifier in additionalVerifiers {
                    verifier
                }
            }
            MockValidVerifier()
        }

        #expect(validator.verifiers.count == 4)
    }

    @Test("VerifierBuilder supports complex control flow")
    func testBuildWithComplexControlFlow() {
        let useFirstBranch = true
        let includeExtra = true

        let validator = ReceiptValidator {
            if useFirstBranch {
                MockValidVerifier()
            } else {
                MockInvalidVerifier(error: MockVerificationError(message: "Error"))
            }

            for _ in 0..<2 {
                MockValidVerifier()
            }

            if includeExtra {
                MockValidVerifier()
            }
        }

        #expect(validator.verifiers.count == 4)
    }

    // MARK: - Multiple Verifiers in Branches Tests

    @Test("VerifierBuilder supports multiple verifiers in if block")
    func testBuildWithMultipleVerifiersInIf() {
        let includeVerifiers = true

        let validator = ReceiptValidator {
            if includeVerifiers {
                MockValidVerifier()
                MockValidVerifier()
                MockValidVerifier()
            }
        }

        #expect(validator.verifiers.count == 3)
    }

    @Test("VerifierBuilder supports multiple verifiers in if-else branches")
    func testBuildWithMultipleVerifiersInIfElse() {
        let useFirstBranch = true

        let validator = ReceiptValidator {
            if useFirstBranch {
                MockValidVerifier()
                MockValidVerifier()
            } else {
                MockInvalidVerifier(error: MockVerificationError(message: "Error 1"))
                MockInvalidVerifier(error: MockVerificationError(message: "Error 2"))
                MockInvalidVerifier(error: MockVerificationError(message: "Error 3"))
            }
        }

        #expect(validator.verifiers.count == 2)
    }
}
