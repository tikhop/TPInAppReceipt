import Foundation
import SwiftASN1
import Testing
import X509

@_spi(AsyncValidation) @testable import TPInAppReceipt

// MARK: - Shared Test Cases

typealias ChainVerifyFn = (
    _ leaf: Certificate,
    _ intermediate: [Certificate],
    _ policy: [ReceiptChainVerifierPolicy]
) async -> TPInAppReceipt.VerificationResult

enum ChainVerifierTestCases {
    static func validChain(using verify: ChainVerifyFn) async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let certificates = pkcs7.content.certificates

        let result = await verify(
            certificates[0],
            [certificates[1]],
            [.appleX509Basic, .appStoreReceipt, .validationTime(pkcs7.creationDate)]
        )

        #expect(result.isValid)
    }

    static func wrongRootCertificateFails(using verify: ChainVerifyFn) async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-watch")
        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        let result = await verify(
            certificates[0],
            [certificates[1]],
            [.appleX509Basic, .appStoreReceipt, .validationTime(pkcs7.creationDate)]
        )

        #expect(result.isInvalid)
    }

    static func expiredCertificatesFails(using verify: ChainVerifyFn) async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-legacy")
        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        let result = await verify(
            certificates[0],
            [certificates[1]],
            [.appleX509Basic, .appStoreReceipt, .validationTime(Date())]
        )

        #expect(result.isInvalid)
    }

    static func invalidLeafOIDFails(using verify: ChainVerifyFn) async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-watch")
        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        // Use intermediate as leaf (wrong OID)
        let result = await verify(
            certificates[1],
            [certificates[1]],
            [.appleX509Basic, .appStoreReceipt, .validationTime(pkcs7.creationDate)]
        )

        #expect(result.isInvalid)
    }

    static func invalidIntermediateOIDFails(using verify: ChainVerifyFn) async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-watch")
        let certificates = pkcs7.content.certificates

        guard certificates.count >= 2 else {
            Issue.record("Receipt should contain at least 2 certificates")
            return
        }

        // Use leaf as intermediate — leaf cert lacks CA basic constraints
        let result = await verify(
            certificates[0],
            [certificates[0]],
            [.appleX509Basic, .validationTime(pkcs7.creationDate)]
        )

        #expect(result.isInvalid)
    }
}

// MARK: - X509ChainVerifier

@Suite("X509ChainVerifier")
struct X509ChainVerifierTests {
    @Test
    func validChain() async throws {
        let verifier = try X509ChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        try await ChainVerifierTestCases.validChain { leaf, intermediate, policy in
            await verifier.verify(leaf: leaf, intermediate: intermediate, policy: policy)
        }
    }

    @Test
    func wrongRootCertificateFails() async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-watch")
        let wrongRoot = pkcs7.content.certificates[1]
        let verifier = X509ChainVerifier(rootCertificates: [wrongRoot])
        try await ChainVerifierTestCases.wrongRootCertificateFails { leaf, intermediate, policy in
            await verifier.verify(leaf: leaf, intermediate: intermediate, policy: policy)
        }
    }

    @Test
    func expiredCertificatesFails() async throws {
        let verifier = try X509ChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        try await ChainVerifierTestCases.expiredCertificatesFails { leaf, intermediate, policy in
            await verifier.verify(leaf: leaf, intermediate: intermediate, policy: policy)
        }
    }

    @Test
    func invalidLeafOIDFails() async throws {
        let verifier = try X509ChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        try await ChainVerifierTestCases.invalidLeafOIDFails { leaf, intermediate, policy in
            await verifier.verify(leaf: leaf, intermediate: intermediate, policy: policy)
        }
    }

    @Test
    func invalidIntermediateOIDFails() async throws {
        let verifier = try X509ChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        try await ChainVerifierTestCases.invalidIntermediateOIDFails { leaf, intermediate, policy in
            await verifier.verify(leaf: leaf, intermediate: intermediate, policy: policy)
        }
    }

    @Test
    func invalidCertificateDataThrows() throws {
        let invalidData = Data([0x00, 0x01, 0x02, 0x03])
        #expect(throws: (any Error).self) {
            _ = try X509ChainVerifier(rootCertificates: [invalidData])
        }
    }
}

// MARK: - SecChainVerifier

#if !os(Linux)
@Suite("SecChainVerifier")
struct SecChainVerifierTests {
    @Test
    func validChain() async throws {
        let verifier = SecChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        try await ChainVerifierTestCases.validChain { leaf, intermediate, policy in
            verifier.verify(leaf: leaf, intermediate: intermediate, policy: policy)
        }
    }

    @Test
    func wrongRootCertificateFails() async throws {
        let verifier = SecChainVerifier(rootCertificates: [])
        try await ChainVerifierTestCases.wrongRootCertificateFails { leaf, intermediate, policy in
            verifier.verify(leaf: leaf, intermediate: intermediate, policy: policy)
        }
    }

    @Test
    func expiredCertificatesFails() async throws {
        let verifier = SecChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        try await ChainVerifierTestCases.expiredCertificatesFails { leaf, intermediate, policy in
            verifier.verify(leaf: leaf, intermediate: intermediate, policy: policy)
        }
    }

    @Test
    func invalidLeafOIDFails() async throws {
        let verifier = SecChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        try await ChainVerifierTestCases.invalidLeafOIDFails { leaf, intermediate, policy in
            verifier.verify(leaf: leaf, intermediate: intermediate, policy: policy)
        }
    }

    @Test
    func invalidIntermediateOIDFails() async throws {
        #if os(macOS) || targetEnvironment(macCatalyst)
        // SecTrust on macOS does not enforce CA basic constraints on intermediates
        #else
        let verifier = SecChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        try await ChainVerifierTestCases.invalidIntermediateOIDFails { leaf, intermediate, policy in
            verifier.verify(leaf: leaf, intermediate: intermediate, policy: policy)
        }
        #endif
    }
}
#endif
