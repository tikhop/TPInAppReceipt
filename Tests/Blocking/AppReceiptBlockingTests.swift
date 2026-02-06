import Foundation
import Testing

@_spi(Blocking) @testable import TPInAppReceipt

@Suite("AppReceipt Blocking Mode")
struct AppReceiptBlockingTests {

    static let validatableReceipts: [(path: String, label: String)] = [
        ("Assets/receipt-sandbox-g5", "sandbox-g5"),
        ("Assets/receipt-production", "production"),
        ("Assets/receipt-xcode", "xcode"),
        ("Assets/receipt-xcode-with-purchases", "xcode-with-purchases"),
    ]

    // MARK: - Helpers

    private static func rootCertificateData(for receipt: AppReceipt) -> Data {
        receipt.environment == .xcode
            ? TestingUtility.loadXcodeRootCertificate()
            : TestingUtility.loadRootCertificate()
    }

    @Test("Blocking validation passes", arguments: validatableReceipts)
    func blockingValidationPasses(receipt arg: (path: String, label: String)) throws {
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

        let result = validator.validate_blocking(receipt)
        #expect(result.isValid)
    }
}
