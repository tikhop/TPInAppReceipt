import Testing
import Foundation
import SwiftASN1
import X509

@_spi(AsyncValidation)
@testable import TPInAppReceipt

// MARK: - X509ChainVerifier Tests

@Suite("X509ChainVerifier Tests")
struct X509ChainVerifierTests {

    // MARK: - Initialization Tests

    @Test("X509ChainVerifier throws with invalid certificate data")
    func chainVerifierThrowsWithInvalidCertificateData() async throws {
        let invalidData = Data([0x00, 0x01, 0x02, 0x03])

        #expect(throws: (any Error).self) {
            _ = try X509ChainVerifier(rootCertificates: [invalidData])
        }
    }

    @Test("X509ChainVerifier initializes with empty root certificates array")
    func chainVerifierInitializesWithEmptyRootCertificates() async throws {
        _ = try X509ChainVerifier(rootCertificates: Array<Data>())
    }

    // MARK: - Chain Verification Tests

    @Test("Valid chain without OCSP using new receipt")
    func testValidChainWithoutOCSP() async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        let certificates = pkcs7.content.certificates

        let verifier = try X509ChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])

        let leafData = certificates[0]
        let intermediateData = certificates[1]
        let validationTime = pkcs7.creationDate

        let result = await verifier.verify(
            leaf: leafData,
            intermediate: [intermediateData],
            policy: [.appleX509Basic, .appStoreReceipt, .validationTime(validationTime)]
        )

        #expect(result.isValid, "Verification should succeed")
    }

    @Test("Valid chain with OCSP using new receipt")
    func testAppleChainIsValidWithOCSP() async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        let verifier = try X509ChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])

        let leafData = certificates[0]
        let intermediateData = certificates[1]
        let validationTime = pkcs7.creationDate

        let result = await verifier.verify(
            leaf: leafData,
            intermediate: [intermediateData],
            policy: [.validationTime(validationTime), .appleX509Basic, .appStoreReceipt, .onlineValidationTime(validationTime)]
        )

        // OCSP might fail due to network issues, which is acceptable in tests
        #expect(result.isValid, "Verification should fail")
    }

    @Test("Chain verification fails with different root certificate")
    func testChainDifferentThanRootCertificate() async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-watch")
        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        // Use a different certificate as root (the intermediate cert)
        let wrongRoot = certificates[1]
        let verifier = X509ChainVerifier(rootCertificates: [wrongRoot])

        let leafData = certificates[0]
        let intermediateData = certificates[1]
        let validationTime = pkcs7.creationDate

        let result = await verifier.verify(
            leaf: leafData,
            intermediate: [intermediateData],
            policy: [.appleX509Basic, .appStoreReceipt, .validationTime(validationTime)]
        )

        #expect(result.isInvalid, "Verification should fail with wrong root certificate")
    }

    @Test("Valid chain with expired certificates fails")
    func testValidChainExpired() async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-legacy")
        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        let verifier = try X509ChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])

        let leafData = certificates[0]
        let intermediateData = certificates[1]

        // Use current date which should be after the certificate expiration
        let result = await verifier.verify(
            leaf: leafData,
            intermediate: [intermediateData],
            policy: [.appleX509Basic, .appStoreReceipt, .validationTime(Date())]
        )

        #expect(result.isInvalid, "Verification should fail with expired certificates")
    }

    @Test("Chain with invalid leaf OID fails without OCSP")
    func testValidChainInvalidLeafOIDWithoutOCSP() async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-watch")
        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        let verifier = try X509ChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])

        // Use intermediate as leaf (wrong OID)
        let leafData = certificates[1]
        let intermediateData = certificates[1]
        let validationTime = pkcs7.creationDate

        let result = await verifier.verify(
            leaf: leafData,
            intermediate: [intermediateData],
            policy: [.appleX509Basic, .appStoreReceipt, .validationTime(validationTime)]
        )

        #expect(result.isInvalid, "Verification should fail with invalid leaf OID")
    }

    @Test("Chain with invalid intermediate OID fails without OCSP")
    func testValidChainInvalidIntermediateOIDWithoutOCSP() async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-watch")
        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        let verifier = try X509ChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])

        // Use leaf as intermediate (wrong OID)
        let leafData = certificates[0]
        let intermediateData = certificates[0]
        let validationTime = pkcs7.creationDate

        let result = await verifier.verify(
            leaf: leafData,
            intermediate: [intermediateData],
            policy: [.appleX509Basic, .appStoreReceipt, .validationTime(validationTime)]
        )

        #expect(result.isInvalid, "Verification should fail with invalid intermediate OID")
    }
}

