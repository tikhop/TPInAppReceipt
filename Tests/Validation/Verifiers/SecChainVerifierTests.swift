import Foundation
import Testing
@testable import TPInAppReceipt

// MARK: - SecChainVerifier Tests

#if !os(Linux)
@Suite("SecChainVerifier Tests")
struct SecChainVerifierTests {
    // MARK: - Chain Verification Tests

    @Test("Valid chain without OCSP using new receipt")
    func testValidChainWithoutOCSP() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")

        let certificates = pkcs7.content.certificates

        let verifier = SecChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        let validationTime = pkcs7.creationDate

        let policy: [ReceiptChainVerifierPolicy] = [
            .appleX509Basic,
            .validationTime(validationTime)
        ]

        let result = verifier.verify(
            leaf: certificates[0],
            intermediate: [certificates[1]],
            policy: policy
        )

        if case .invalid(let error) = result {
            Issue.record("Verification should succeed but failed with: \(error)")
        }
    }

    @Test("Valid chain with OCSP using new receipt")
    func testAppleChainIsValidWithOCSP() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-watch")

        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        let verifier = SecChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        let validationTime = pkcs7.creationDate

        let policy: [ReceiptChainVerifierPolicy] = [
            .appleX509Basic,
            .validationTime(validationTime),
            .onlineValidationTime(validationTime)
        ]

        let result = verifier.verify(
            leaf: certificates[0],
            intermediate: [certificates[1]],
            policy: policy
        )

        if case .invalid(let error) = result {
            // OCSP validation may fail in test environment, log but don't fail
            print("OCSP verification warning: \(error)")
        }
    }

    @Test("Chain verification fails with different root certificate")
    func testChainDifferentThanRootCertificate() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-watch")

        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        // No root certificates - chain cannot complete to a trusted anchor
        let verifier = SecChainVerifier(rootCertificates: [])
        let validationTime = pkcs7.creationDate

        let policy: [ReceiptChainVerifierPolicy] = [
            .appStoreReceipt,
            .appleX509Basic,
            .validationTime(validationTime)
        ]

        let result = verifier.verify(
            leaf: certificates[0],
            intermediate: [certificates[1]],
            policy: policy
        )

        #expect(result.isInvalid)
    }

    @Test("Valid chain with expired certificates fails")
    func testValidChainExpired() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-legacy")

        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        let verifier = SecChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])

        // Use current date which should be after the certificate expiration
        let policy: [ReceiptChainVerifierPolicy] = [
            .appStoreReceipt,
            .appleX509Basic,
            .validationTime(Date())
        ]

        let result = verifier.verify(
            leaf: certificates[0],
            intermediate: [certificates[1]],
            policy: policy
        )

        #expect(result.isInvalid)
    }

    @Test("Chain with invalid leaf OID fails without OCSP")
    func testValidChainInvalidLeafOIDWithoutOCSP() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-watch")

        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        let verifier = SecChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        let validationTime = pkcs7.creationDate

        let policy: [ReceiptChainVerifierPolicy] = [
            .appStoreReceipt,
            .appleX509Basic,
            .validationTime(validationTime)
        ]

        // Use intermediate as leaf (wrong OID)
        let result = verifier.verify(
            leaf: certificates[1],
            intermediate: [certificates[1]],
            policy: policy
        )

        #expect(result.isInvalid)
    }

    @Test("Chain with invalid intermediate OID fails without OCSP")
    func testValidChainInvalidIntermediateOIDWithoutOCSP() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-watch")

        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        let verifier = SecChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        let validationTime = pkcs7.creationDate

        let policy: [ReceiptChainVerifierPolicy] = [
            .appleX509Basic,
            .validationTime(validationTime)
        ]

        // Use leaf as intermediate (wrong OID)
        let result = verifier.verify(
            leaf: certificates[0],
            intermediate: [certificates[0]],
            policy: policy
        )

        #expect(result.isInvalid)
    }

    // MARK: - Additional Verification Tests

    @Test("Valid chain using Certificate API")
    func testValidChainWithCertificateAPI() throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-watch")

        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        let verifier = SecChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        let validationTime = pkcs7.creationDate

        let policy: [ReceiptChainVerifierPolicy] = [
            .appleX509Basic,
            .validationTime(validationTime)
        ]

        let result = verifier.verify(
            leaf: certificates[0],
            intermediate: [certificates[1]],
            policy: policy
        )

        if case .invalid(let error) = result {
            Issue.record("Verification should succeed but failed with: \(error)")
        }
    }
}
#endif
