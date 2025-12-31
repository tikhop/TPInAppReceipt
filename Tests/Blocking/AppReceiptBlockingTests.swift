import Foundation
import Testing

@_spi(Blocking)
@testable import TPInAppReceipt

@Suite("AppReceipt Blocking Mode Tests")
struct AppReceiptBlockingTests {

    // MARK: - Test Data

    /// The known device UUID used to create `receipt-from-known-device`
    let knownDeviceUUID = UUID(uuidString: "956328D9-CC6A-47F4-BE40-6953FB0AB6C7")!

    // MARK: - Full Validation Tests (Chain + Signature + Hash, without Meta)

    @Test("Valid receipt passes chain, signature, and hash verification")
    func validReceiptPassesFullVerification() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let rootCertificate = TestingUtility.loadRootCertificate()

        let validator = ReceiptValidator {
            SecChainVerifier(rootCertificates: [rootCertificate])
            SecSignatureVerifier()
            HashVerifier(deviceIdentifier: knownDeviceUUID.data)
        }

        let result = validator.validate_blocking(receipt)

        #expect(result.isValid, "Receipt should pass all verifications with correct certificate and device ID")
    }

    // MARK: - Validator Creation Tests

    @Test("Default blocking validator has verifiers configured")
    func defaultBlockingValidatorHasVerifiers() {
        let rootCertificate = TestingUtility.loadRootCertificate()
        let deviceIdentifier = Data(repeating: 0, count: 16)

        let validator = ReceiptValidator.default_blocking(
            rootCertificate: rootCertificate,
            deviceIdentifier: deviceIdentifier
        )

        #expect(validator.verifiers.count == 4, "Default validator should have 4 verifiers (chain, signature, hash, meta)")
    }
}
