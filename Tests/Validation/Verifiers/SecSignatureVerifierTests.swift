import Foundation
import Testing
import SwiftASN1
import X509

@testable import TPInAppReceipt

// MARK: - SecSignatureVerifier Tests

#if !os(Linux)
@Suite("SecSignatureVerifier Tests")
struct SecSignatureVerifierTests {

    // MARK: - Valid Signature Tests

    @Test("Valid signature verification")
    func testValidSignature() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        let verifier = SecSignatureVerifier()
        let result = verifier.verify(pkcs7)

        #expect(result.isValid, "Signature verification should succeed")
    }

    // MARK: - Invalid Signature Tests

    @Test("Invalid signature with corrupted signature data")
    func testInvalidSignatureWithCorruptedData() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        let verifier = SecSignatureVerifier()

        // Create corrupted signature by flipping some bytes
        var corruptedSignature = pkcs7.signature
        if corruptedSignature.count > 10 {
            corruptedSignature[5] ^= 0xFF
            corruptedSignature[10] ^= 0xFF
        }

        // Convert public key to Data for Sec verification
        guard let keyData = try? Data(pkcs7.publicKey.intoBytes()) else {
            Issue.record("Failed to convert public key to Data")
            return
        }

        let result = verifier.verify(
            key: keyData,
            algorithm: pkcs7.digestAlgorithm,
            signedData: pkcs7.digestData,
            signature: corruptedSignature
        )

        #expect(result.isInvalid, "Verification should fail with corrupted signature")
    }

    @Test("Invalid signature with corrupted signed data")
    func testInvalidSignatureWithCorruptedSignedData() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        let verifier = SecSignatureVerifier()

        // Create corrupted signed data
        var corruptedData = pkcs7.digestData
        if corruptedData.count > 10 {
            corruptedData[5] ^= 0xFF
            corruptedData[10] ^= 0xFF
        }

        // Convert public key to Data for Sec verification
        guard let keyData = try? Data(pkcs7.publicKey.intoBytes()) else {
            Issue.record("Failed to convert public key to Data")
            return
        }

        let result = verifier.verify(
            key: keyData,
            algorithm: pkcs7.digestAlgorithm,
            signedData: corruptedData,
            signature: pkcs7.signature
        )

        #expect(result.isInvalid, "Verification should fail with corrupted signed data")
    }

    @Test("Invalid signature with wrong public key")
    func testInvalidSignatureWithWrongKey() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let otherReceipt = try TestingUtility.parseReceipt("Assets/receipt-watch")

        let verifier = SecSignatureVerifier()

        // Convert wrong public key to Data for Sec verification
        guard let wrongKeyData = try? Data(otherReceipt.publicKey.intoBytes()) else {
            Issue.record("Failed to convert public key to Data")
            return
        }

        let result = verifier.verify(
            key: wrongKeyData,
            algorithm: pkcs7.digestAlgorithm,
            signedData: pkcs7.digestData,
            signature: pkcs7.signature
        )

        #expect(result.isInvalid, "Verification should fail with wrong public key")
    }

    // MARK: - Algorithm Tests

    @Test("SHA-1 algorithm verification")
    func testSHA1AlgorithmVerification() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-legacy")

        // Legacy receipts typically use SHA-1
        if pkcs7.digestAlgorithm == .sha1 {
            let verifier = SecSignatureVerifier()
            let result = verifier.verify(pkcs7)

            #expect(result.isValid, "SHA-1 signature verification should succeed")
        }
    }

    @Test("SHA-256 algorithm verification")
    func testSHA256AlgorithmVerification() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        // Modern receipts typically use SHA-256
        if pkcs7.digestAlgorithm == .sha256 {
            let verifier = SecSignatureVerifier()
            let result = verifier.verify(pkcs7)

            #expect(result.isValid, "SHA-256 signature verification should succeed")
        }
    }

    // MARK: - Edge Cases

    @Test("Empty signature data fails verification")
    func testEmptySignatureFails() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        let verifier = SecSignatureVerifier()

        // Convert public key to Data for Sec verification
        guard let keyData = try? Data(pkcs7.publicKey.intoBytes()) else {
            Issue.record("Failed to convert public key to Data")
            return
        }

        let result = verifier.verify(
            key: keyData,
            algorithm: pkcs7.digestAlgorithm,
            signedData: pkcs7.digestData,
            signature: Data()
        )

        #expect(result.isInvalid, "Verification should fail with empty signature")
    }

    @Test("Empty signed data fails verification")
    func testEmptySignedDataFails() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        let verifier = SecSignatureVerifier()

        // Convert public key to Data for Sec verification
        guard let keyData = try? Data(pkcs7.publicKey.intoBytes()) else {
            Issue.record("Failed to convert public key to Data")
            return
        }

        let result = verifier.verify(
            key: keyData,
            algorithm: pkcs7.digestAlgorithm,
            signedData: Data(),
            signature: pkcs7.signature
        )

        #expect(result.isInvalid, "Verification should fail with empty signed data")
    }

    @Test("Invalid public key data fails verification")
    func testInvalidPublicKeyDataFails() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        let verifier = SecSignatureVerifier()

        // Use invalid key data
        let invalidKeyData = Data([0x00, 0x01, 0x02, 0x03])

        let result = verifier.verify(
            key: invalidKeyData,
            algorithm: pkcs7.digestAlgorithm,
            signedData: pkcs7.digestData,
            signature: pkcs7.signature
        )

        #expect(result.isInvalid, "Verification should fail with invalid public key data")
    }
}

// MARK: - Helper Extension

fileprivate extension DERSerializable {
    func intoBytes() throws -> Data {
        var serializer = DER.Serializer()
        try serializer.serialize(self)
        return Data(serializer.serializedBytes)
    }
}
#endif
