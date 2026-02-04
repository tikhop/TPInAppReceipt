import Foundation
import SwiftASN1
import Testing
import X509

@testable import TPInAppReceipt

// MARK: - Shared Test Cases

enum SignatureVerifierTestCases {
    static func validSignature(
        using verify: (AppReceipt) -> TPInAppReceipt.VerificationResult
    ) throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let result = verify(pkcs7)
        #expect(result.isValid)
    }

    static func corruptedSignatureFails(
        using verify: (_ signedData: Data, _ signature: Data) -> TPInAppReceipt.VerificationResult
    ) throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        var corrupted = pkcs7.signature
        if corrupted.count > 10 {
            corrupted[5] ^= 0xFF
            corrupted[10] ^= 0xFF
        }
        let result = verify(pkcs7.digestData, corrupted)
        #expect(result.isInvalid)
    }

    static func corruptedSignedDataFails(
        using verify: (_ signedData: Data, _ signature: Data) -> TPInAppReceipt.VerificationResult
    ) throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        var corrupted = pkcs7.digestData
        if corrupted.count > 10 {
            corrupted[5] ^= 0xFF
            corrupted[10] ^= 0xFF
        }
        let result = verify(corrupted, pkcs7.signature)
        #expect(result.isInvalid)
    }

    static func emptySignatureFails(
        using verify: (_ signedData: Data, _ signature: Data) -> TPInAppReceipt.VerificationResult
    ) throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let result = verify(pkcs7.digestData, Data())
        #expect(result.isInvalid)
    }

    static func emptySignedDataFails(
        using verify: (_ signedData: Data, _ signature: Data) -> TPInAppReceipt.VerificationResult
    ) throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let result = verify(Data(), pkcs7.signature)
        #expect(result.isInvalid)
    }
}

// MARK: - X509 SignatureVerifier

@Suite("SignatureVerifier")
struct SignatureVerifierTests {
    let verifier = SignatureVerifier()

    @Test
    func validSignature() throws {
        try SignatureVerifierTestCases.validSignature { receipt in
            verifier.verify(receipt)
        }
    }

    @Test
    func corruptedSignatureFails() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        try SignatureVerifierTestCases.corruptedSignatureFails { signedData, signature in
            verifier.verify(
                key: pkcs7.publicKey!,
                algorithm: pkcs7.digestAlgorithm,
                signedData: signedData,
                signature: signature
            )
        }
    }

    @Test
    func corruptedSignedDataFails() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        try SignatureVerifierTestCases.corruptedSignedDataFails { signedData, signature in
            verifier.verify(
                key: pkcs7.publicKey!,
                algorithm: pkcs7.digestAlgorithm,
                signedData: signedData,
                signature: signature
            )
        }
    }

    @Test
    func emptySignatureFails() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        try SignatureVerifierTestCases.emptySignatureFails { signedData, signature in
            verifier.verify(
                key: pkcs7.publicKey!,
                algorithm: pkcs7.digestAlgorithm,
                signedData: signedData,
                signature: signature
            )
        }
    }

    @Test
    func emptySignedDataFails() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        try SignatureVerifierTestCases.emptySignedDataFails { signedData, signature in
            verifier.verify(
                key: pkcs7.publicKey!,
                algorithm: pkcs7.digestAlgorithm,
                signedData: signedData,
                signature: signature
            )
        }
    }
}

// MARK: - Security Framework SignatureVerifier

#if !os(Linux)
@Suite("SecSignatureVerifier")
struct SecSignatureVerifierTests {
    let verifier = SecSignatureVerifier()

    @Test
    func validSignature() throws {
        try SignatureVerifierTestCases.validSignature { receipt in
            verifier.verify(receipt)
        }
    }

    @Test
    func corruptedSignatureFails() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let keyData = try Data(pkcs7.publicKey!.intoBytes())
        try SignatureVerifierTestCases.corruptedSignatureFails { signedData, signature in
            verifier.verify(
                key: keyData,
                algorithm: pkcs7.digestAlgorithm,
                signedData: signedData,
                signature: signature
            )
        }
    }

    @Test
    func corruptedSignedDataFails() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let keyData = try Data(pkcs7.publicKey!.intoBytes())
        try SignatureVerifierTestCases.corruptedSignedDataFails { signedData, signature in
            verifier.verify(
                key: keyData,
                algorithm: pkcs7.digestAlgorithm,
                signedData: signedData,
                signature: signature
            )
        }
    }

    @Test
    func emptySignatureFails() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let keyData = try Data(pkcs7.publicKey!.intoBytes())
        try SignatureVerifierTestCases.emptySignatureFails { signedData, signature in
            verifier.verify(
                key: keyData,
                algorithm: pkcs7.digestAlgorithm,
                signedData: signedData,
                signature: signature
            )
        }
    }

    @Test
    func emptySignedDataFails() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let keyData = try Data(pkcs7.publicKey!.intoBytes())
        try SignatureVerifierTestCases.emptySignedDataFails { signedData, signature in
            verifier.verify(
                key: keyData,
                algorithm: pkcs7.digestAlgorithm,
                signedData: signedData,
                signature: signature
            )
        }
    }
}
#endif
