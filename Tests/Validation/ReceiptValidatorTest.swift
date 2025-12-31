import Testing
import Foundation
import X509

@testable import TPInAppReceipt

// MARK: - Mock Verifiers

/// A mock verifier that always returns valid
struct MockValidVerifier: ReceiptVerifier {
    func verify(_ receipt: ReceiptValidatable) async -> TPInAppReceipt.VerificationResult {
        return .valid
    }}

/// A mock verifier that always returns invalid with a specific error
struct MockInvalidVerifier: ReceiptVerifier {
    let error: Error

    init(error: Error) {
        self.error = error
    }

    func verify(_ receipt: ReceiptValidatable) async -> TPInAppReceipt.VerificationResult {
        return .invalid(error)
    }
}

/// A mock error type for testing
struct MockVerificationError: Error, Equatable {
    let message: String
}

// MARK: - ReceiptValidator Tests

@Suite("ReceiptValidator Tests")
struct ReceiptValidatorTests {

    // MARK: - Valid Verification Tests

    @Test("Validation succeeds when all verifiers return valid")
    func testValidationSucceedsWithAllValidVerifiers() async throws {
        let validator = ReceiptValidator {
            MockValidVerifier()
            MockValidVerifier()
            MockValidVerifier()
        }

        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let result = await validator.validate(receipt)

        #expect(result.isValid)
    }

    @Test("Validation succeeds with empty verifiers list")
    func testValidationSucceedsWithEmptyVerifiers() async throws {
        let validator = ReceiptValidator {
        }

        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let result = await validator.validate(receipt)

        #expect(result.isValid)
    }

    // MARK: - Invalid Verification Tests

    @Test("Validation fails when one verifier returns invalid")
    func testValidationFailsWithOneInvalidVerifier() async throws {
        let expectedError = MockVerificationError(message: "Verification failed")

        let validator = ReceiptValidator {
            MockValidVerifier()
            MockInvalidVerifier(error: expectedError)
            MockValidVerifier()
        }

        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let result = await validator.validate(receipt)

        #expect(result.isInvalid)

        if case .invalid(let error) = result {
            #expect(error is MockVerificationError)
            if let mockError = error as? MockVerificationError {
                #expect(mockError == expectedError)
            }
        }
    }

    // MARK: - Default Validator Tests

    @Test("Default validator initializes successfully")
    func testDefaultValidatorInitialization() throws {
        let rootCertificate = TestingUtility.loadRootCertificate()
        let deviceIdentifier = Data(repeating: 0, count: 16)

        let validator = ReceiptValidator.default(
            rootCertificate: try! Certificate(derEncoded: rootCertificate.bytes),
            deviceIdentifier: deviceIdentifier
        )

        #expect(validator.verifiers.count > 0)
    }

    // MARK: - VerificationResult Tests

    @Test("VerificationResult.isValid returns true for valid result")
    func testVerificationResultIsValidTrue() {
        let result = VerificationResult.valid

        #expect(result.isValid == true)
        #expect(result.isInvalid == false)
    }

    @Test("VerificationResult.isValid returns false for invalid result")
    func testVerificationResultIsValidFalse() {
        let result = VerificationResult.invalid(MockVerificationError(message: "Error"))

        #expect(result.isValid == false)
        #expect(result.isInvalid == true)
    }
}

