import Foundation
import SwiftASN1
import Testing

@testable import TPInAppReceipt

@Suite("HashVerifier")
struct HashVerifierTests {
    let knownDeviceUUID = UUID(uuidString: "956328D9-CC6A-47F4-BE40-6953FB0AB6C7")!

    @Test
    func verifyHashWithKnownDeviceReceipt() async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-sandbox-g5")
        let payload = pkcs7.content.encapContentInfo.eContent!

        let verifier = HashVerifier(deviceIdentifier: knownDeviceUUID.data)
        let result = verifier.verify(
            expectedHash: payload.receiptHash,
            opaqueValue: payload.opaqueValue,
            bundleIdentifier: payload.bundleIdentifierData
        )

        #expect(result.isValid)
    }

    @Test
    func verificationFailsWithWrongDeviceIdentifier() async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-sandbox-g5")
        let payload = pkcs7.content.encapContentInfo.eContent!

        let wrongUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let verifier = HashVerifier(deviceIdentifier: wrongUUID.data)
        let result = verifier.verify(
            expectedHash: payload.receiptHash,
            opaqueValue: payload.opaqueValue,
            bundleIdentifier: payload.bundleIdentifierData
        )

        #expect(result.isInvalid)
    }
}
