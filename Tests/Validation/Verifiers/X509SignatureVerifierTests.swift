import Testing
import Foundation
import SwiftASN1
import X509

@testable import TPInAppReceipt

// MARK: - X509 SignatureVerifier Tests

@Suite("X509 SignatureVerifier Tests")
struct X509SignatureVerifierTests {

    // MARK: - Valid Signature Tests

    @Test("Valid signature verification")
    func testValidSignature() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        let verifier = SignatureVerifier()
        let result = verifier.verify(pkcs7)

        #expect(result.isValid, "Signature verification should succeed")
    }

    // MARK: - Invalid Signature Tests

    @Test("Invalid signature with corrupted signature data")
    func testInvalidSignatureWithCorruptedData() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        let verifier = SignatureVerifier()

        // Create corrupted signature by flipping some bytes
        var corruptedSignature = pkcs7.signature
        if corruptedSignature.count > 10 {
            corruptedSignature[5] ^= 0xFF
            corruptedSignature[10] ^= 0xFF
        }

        let result = verifier.verify(
            key: pkcs7.publicKey,
            algorithm: pkcs7.digestAlgorithm,
            signedData: pkcs7.digestData,
            signature: corruptedSignature
        )

        #expect(result.isInvalid, "Verification should fail with corrupted signature")
    }

    @Test("Invalid signature with corrupted signed data")
    func testInvalidSignatureWithCorruptedSignedData() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        let verifier = SignatureVerifier()

        // Create corrupted signed data
        var corruptedData = pkcs7.digestData
        if corruptedData.count > 10 {
            corruptedData[5] ^= 0xFF
            corruptedData[10] ^= 0xFF
        }

        let result = verifier.verify(
            key: pkcs7.publicKey,
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

        let verifier = SignatureVerifier()

        // Use public key from a different receipt
        let result = verifier.verify(
            key: otherReceipt.publicKey,
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

        if pkcs7.digestAlgorithm == .sha1 {
            let verifier = SignatureVerifier()
            let result = verifier.verify(pkcs7)

            #expect(result.isValid, "SHA-1 signature verification should succeed")
        }
    }

    @Test("SHA-256 algorithm verification")
    func testSHA256AlgorithmVerification() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        if pkcs7.digestAlgorithm == .sha256 {
            let verifier = SignatureVerifier()
            let result = verifier.verify(pkcs7)

            #expect(result.isValid, "SHA-256 signature verification should succeed")
        }
    }

    // MARK: - Edge Cases

    @Test("Empty signature data fails verification")
    func testEmptySignatureFails() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        let verifier = SignatureVerifier()
        let result = verifier.verify(
            key: pkcs7.publicKey,
            algorithm: pkcs7.digestAlgorithm,
            signedData: pkcs7.digestData,
            signature: Data()
        )

        #expect(result.isInvalid, "Verification should fail with empty signature")
    }

    @Test("Empty signed data fails verification")
    func testEmptySignedDataFails() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        let verifier = SignatureVerifier()
        let result = verifier.verify(
            key: pkcs7.publicKey,
            algorithm: pkcs7.digestAlgorithm,
            signedData: Data(),
            signature: pkcs7.signature
        )

        #expect(result.isInvalid, "Verification should fail with empty signed data")
    }
}
