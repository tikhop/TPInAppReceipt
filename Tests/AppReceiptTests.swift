import Foundation
import Testing
import X509

@testable import TPInAppReceipt

@Suite("AppReceipt")
struct AppReceiptTests {

    // MARK: - Receipt Paths

    static let allReceipts: [(path: String, label: String)] = [
        ("Assets/receipt-sandbox-g5", "sandbox-g5"),
        ("Assets/receipt-sandbox-legacy", "sandbox-legacy"),
        ("Assets/receipt-production", "production"),
        ("Assets/receipt-xcode", "xcode"),
        ("Assets/receipt-xcode-with-purchases", "xcode-with-purchases"),
    ]

    // MARK: - Decoding

    @Test("Decoding produces valid structure", arguments: allReceipts)
    func decodingProducesValidStructure(receipt arg: (path: String, label: String)) throws {
        let data = TestingUtility.readReceipt(arg.path)
        let receipt = try AppReceipt.receipt(from: data)

        #expect(receipt.hasValidStructure)
        #expect(!receipt.bundleIdentifier.isEmpty)
        #expect(!receipt.appVersion.isEmpty)
        #expect(!receipt.payloadRawData.isEmpty)
    }

    // MARK: - Async Validation

    @Test("Async validation passes", arguments: allReceipts)
    func asyncValidationPasses(receipt arg: (path: String, label: String)) async throws {
        #if !targetEnvironment(macCatalyst) && canImport(UIKit)
        let receipt = try TestingUtility.parseReceipt(arg.path)
        let result = await receipt.validate(needsMetadataVerification: false)
        #expect(result.isValid)
        #endif
    }

    // MARK: - Custom Validator

    @Test("Custom validator passes", arguments: allReceipts)
    func customValidatorPasses(receipt arg: (path: String, label: String)) async throws {
        let receipt = try TestingUtility.parseReceipt(arg.path)
        let rootCertData = Self.rootCertificateData(for: receipt)
        let chainVerifier = try SecChainVerifier(rootCertificates: [rootCertData])

        let validator = ReceiptValidator {
            chainVerifier
            SecSignatureVerifier()
            MetaVerifier(
                expectedBundleIdentifier: receipt.bundleIdentifier,
                expectedAppVersion: receipt.appVersion
            )
        }

        let result = await validator.validate(receipt)
        #expect(result.isValid)
    }

    // MARK: - Helpers

    private static func rootCertificateData(for receipt: AppReceipt) -> Data {
        receipt.environment == .xcode
            ? TestingUtility.loadXcodeRootCertificate()
            : TestingUtility.loadRootCertificate()
    }
}
