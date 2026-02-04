import Foundation
import Testing

@_spi(Blocking) @testable import TPInAppReceipt

@Suite("AppReceipt Blocking Mode")
struct AppReceiptBlockingTests {
    let knownDeviceUUID = UUID(uuidString: "956328D9-CC6A-47F4-BE40-6953FB0AB6C7")!

    @Test
    func validReceiptPassesChainSignatureAndHashVerification() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let rootCertificate = TestingUtility.loadRootCertificate()

        let validator = ReceiptValidator {
            SecChainVerifier(rootCertificates: [rootCertificate])
            SecSignatureVerifier()
            HashVerifier(deviceIdentifier: knownDeviceUUID.data)
        }

        let result = validator.validate_blocking(receipt)

        #expect(result.isValid)
    }
}
