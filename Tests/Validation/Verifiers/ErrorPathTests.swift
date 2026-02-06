import Foundation
import SwiftASN1
import Testing
import X509

@testable import TPInAppReceipt

@Suite("Verifier Error Paths")
struct ErrorPathTests {
    // MARK: - MetaVerifier

    @Test
    func metaVerifierPropagatesProviderError() {
        let verifier = MetaVerifier(
            appVersionProvider: { throw MetaVerificationError.bundleInfoUnavailable },
            bundleIdentifierProvider: { "com.example.app" }
        )

        let result = verifier.verify(
            bundleIdentifier: "com.example.app",
            versionIdentifier: "1.0"
        )

        #expect(result.isInvalid)
        expectError(result, equals: MetaVerificationError.bundleInfoUnavailable)
    }

    @Test
    func metaVerifierPropagatesBundleIdProviderError() {
        let verifier = MetaVerifier(
            appVersionProvider: { "1.0" },
            bundleIdentifierProvider: { throw MetaVerificationError.bundleInfoUnavailable }
        )

        let result = verifier.verify(
            bundleIdentifier: "com.example.app",
            versionIdentifier: "1.0"
        )

        #expect(result.isInvalid)
        expectError(result, equals: MetaVerificationError.bundleInfoUnavailable)
    }

    // MARK: - HashVerifier

    @Test
    func hashMismatchReturnsSpecificError() {
        let verifier = HashVerifier(deviceIdentifier: Data(repeating: 0x00, count: 16))

        let result = verifier.verify(
            expectedHash: Data(repeating: 0xFF, count: 20),
            opaqueValue: Data(),
            bundleIdentifier: Data()
        )

        #expect(result.isInvalid)
        expectError(result, equals: HashVerificationError.hashMismatch)
    }

    // MARK: - SignatureVerifier (via ReceiptVerifier)

    @Test
    func signatureVerifierReturnsInvalidKeyWhenNoCertificates() {
        let verifier = SignatureVerifier()
        let receipt = MockReceipt.withNoCertificates()

        let result = verifier.verify(receipt)

        #expect(result.isInvalid)
        expectError(result, equals: SignatureVerificationError.invalidKey)
    }

    // MARK: - X509ChainVerifier (via ReceiptVerifier)

    @Test
    func chainVerifierReturnsInvalidCertificateDataWhenNoCertificates() async throws {
        let verifier = try X509ChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        let receipt = MockReceipt.withNoCertificates()

        let result = await verifier.verify(receipt)

        #expect(result.isInvalid)
        expectError(result, equals: ChainVerificationError.invalidCertificateData)
    }

    @Test
    func chainVerifierFailsWhenSingleNonXcodeCertificate() async throws {
        let pkcs7 = try TestingUtility.parseReceipt("Assets/receipt-sandbox-g5")
        let leaf = pkcs7.content.certificates[0]
        let verifier = try X509ChainVerifier(rootCertificates: [TestingUtility.loadRootCertificate()])
        // MockReceipt has .sandbox environment, so AppStoreOIDPolicy requires chain of 3
        let receipt = MockReceipt.withCertificates([leaf])

        let result = await verifier.verify(receipt)

        #expect(result.isInvalid)
        expectError(result, equals: ChainVerificationError.chainValidationFailed)
    }
}

// MARK: - Assertion Helpers

private func expectError<E: Error & Equatable>(
    _ result: TPInAppReceipt.VerificationResult,
    equals expected: E,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    guard case let .invalid(error) = result else {
        Issue.record("Expected .invalid but got .valid", sourceLocation: sourceLocation)
        return
    }
    guard let typed = error as? E else {
        Issue.record(
            "Expected \(E.self) but got \(type(of: error)): \(error)",
            sourceLocation: sourceLocation
        )
        return
    }
    #expect(typed == expected, sourceLocation: sourceLocation)
}

// MARK: - MockReceipt

private struct MockReceipt: ReceiptValidatable {
    var environment: InAppReceiptPayload.Environment
    var versionIdentifier: String
    var bundleIdentifier: String
    var bundleIdentifierData: Data
    var certificates: [Certificate]
    var certificatesRaw: [Data]
    var receiptHash: Data
    var opaqueValue: Data
    var digestData: Data
    var digestAlgorithm: DigestAlgorithm
    var signature: Data
    var validationTime: Date

    static func withNoCertificates() -> MockReceipt {
        MockReceipt(
            environment: .sandbox,
            versionIdentifier: "1.0",
            bundleIdentifier: "com.example.app",
            bundleIdentifierData: Data(),
            certificates: [],
            certificatesRaw: [],
            receiptHash: Data(),
            opaqueValue: Data(),
            digestData: Data(),
            digestAlgorithm: .sha1,
            signature: Data(),
            validationTime: Date()
        )
    }

    static func withCertificates(_ certs: [Certificate]) -> MockReceipt {
        MockReceipt(
            environment: .sandbox,
            versionIdentifier: "1.0",
            bundleIdentifier: "com.example.app",
            bundleIdentifierData: Data(),
            certificates: certs,
            certificatesRaw: [],
            receiptHash: Data(),
            opaqueValue: Data(),
            digestData: Data(),
            digestAlgorithm: .sha1,
            signature: Data(),
            validationTime: Date()
        )
    }
}
