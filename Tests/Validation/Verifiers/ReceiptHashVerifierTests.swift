import Testing
import Foundation
import SwiftASN1

@testable import TPInAppReceipt

@Suite("Receipt Hash Verifier Tests")
struct ReceiptHashVerifierTests {

    let knownDeviceUUID = UUID(uuidString: "956328D9-CC6A-47F4-BE40-6953FB0AB6C7")!

    @Test("Verify hash with known device receipt")
    func verifyHashWithKnownDeviceReceipt() async throws {
        let receiptData = TestingUtility.readReceipt("Assets/receipt-from-known-device")

        let result = try BER.parse(receiptData.bytes)
        let pkcs7 = try AppReceipt(berEncoded: result)
        let payload = pkcs7.content.encapContentInfo.eContent!

        let verifier = HashVerifier(deviceIdentifier: knownDeviceUUID.data)

        let isValid = verifier.verify(
            expectedHash: payload.receiptHash,
            opaqueValue: payload.opaqueValue,
            bundleIdentifier: payload.bundleIdentifierData
        ).isValid

        #expect(isValid, "Hash verification should pass for known device receipt")
    }

    @Test("Compute hash produces correct result")
    func computeHashProducesCorrectResult() async throws {
        let receiptData = TestingUtility.readReceipt("Assets/receipt-from-known-device")

        let result = try BER.parse(Array(receiptData))
        let pkcs7 = try AppReceipt(berEncoded: result)
        let payload = pkcs7.content.encapContentInfo.eContent!

        let verifier = HashVerifier(deviceIdentifier: knownDeviceUUID.data)

        let computedHash = verifier.computeHash(
            deviceIdentifier: knownDeviceUUID.data,
            opaqueValue: payload.opaqueValue,
            bundleIdentifierData: payload.bundleIdentifierData
        )

        #expect(computedHash == payload.receiptHash, "Computed hash should match receipt hash")
    }

    @Test("Verification fails with wrong device identifier")
    func verificationFailsWithWrongDeviceIdentifier() async throws {
        let receiptData = TestingUtility.readReceipt("Assets/receipt-from-known-device")

        let result = try BER.parse(Array(receiptData))
        let pkcs7 = try AppReceipt(berEncoded: result)
        let payload = pkcs7.content.encapContentInfo.eContent!

        let wrongUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let wrongDeviceData = wrongUUID.data

        let verifier = HashVerifier(deviceIdentifier: wrongDeviceData)

        let isValid = verifier.verify(
            expectedHash: payload.receiptHash,
            opaqueValue: payload.opaqueValue,
            bundleIdentifier: payload.bundleIdentifierData
        ).isValid

        #expect(!isValid, "Hash verification should fail with wrong device identifier")
    }
}
