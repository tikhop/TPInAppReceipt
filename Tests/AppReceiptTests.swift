import Foundation
import Testing
import X509

@testable import TPInAppReceipt

@Suite("AppReceipt")
struct AppReceiptTests {
    let knownDeviceUUID = UUID(uuidString: "956328D9-CC6A-47F4-BE40-6953FB0AB6C7")!

    // MARK: - Decoding & Metadata

    @Test
    func decodedReceiptExposesEnvironment() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        #expect(receipt.environment == .productionSandbox)
    }

    @Test
    func decodedReceiptExposesBundleIdentifier() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        #expect(!receipt.bundleIdentifier.isEmpty)
    }

    @Test
    func decodedReceiptExposesAppVersion() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        #expect(!receipt.appVersion.isEmpty)
    }

    @Test
    func creationDateIsReasonable() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let year2010 = Date(timeIntervalSince1970: 1_262_304_000)
        #expect(receipt.creationDate > year2010)
    }

    @Test
    func payloadRawDataIsNonEmpty() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        #expect(!receipt.payloadRawData.isEmpty)
    }

    @Test
    func hasValidStructure() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        #expect(receipt.hasValidStructure)
    }

    @Test
    func productionReceiptExposesCorrectEnvironment() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-production")
        #expect(receipt.environment == .production)
    }

    @Test
    func xcodeReceiptExposesCorrectEnvironment() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-no-orig-purchase-date")
        #expect(receipt.environment == .xcode)
    }

    // MARK: - Validation

    @Test
    func asyncValidationPassesWithCorrectCertAndDevice() async throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let rootCertData = TestingUtility.loadRootCertificate()
        let rootCert = try Certificate(derEncoded: rootCertData.bytes)

        let validator = ReceiptValidator {
            X509ChainVerifier(rootCertificates: [rootCert])
            SignatureVerifier()
            HashVerifier(deviceIdentifier: knownDeviceUUID.data)
        }

        let result = await validator.validate(receipt)
        #expect(result.isValid)
    }

    @Test
    func asyncValidationFailsWithWrongDevice() async throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let rootCertData = TestingUtility.loadRootCertificate()
        let rootCert = try Certificate(derEncoded: rootCertData.bytes)
        let wrongDevice = Data(repeating: 0xFF, count: 16)

        let validator = ReceiptValidator {
            X509ChainVerifier(rootCertificates: [rootCert])
            SignatureVerifier()
            HashVerifier(deviceIdentifier: wrongDevice)
        }

        let result = await validator.validate(receipt)
        #expect(result.isInvalid)
    }

    @Test
    func asyncValidationFailsWithWrongRootCertificate() async throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        let wrongCertData = TestingUtility.loadXcodeRootCertificate()
        let wrongCert = try Certificate(derEncoded: wrongCertData.bytes)

        let validator = ReceiptValidator {
            X509ChainVerifier(rootCertificates: [wrongCert])
            SignatureVerifier()
            HashVerifier(deviceIdentifier: knownDeviceUUID.data)
        }

        let result = await validator.validate(receipt)
        #expect(result.isInvalid)
    }

    // MARK: - Purchase Queries (negative cases)

    @Test
    func containsPurchaseReturnsFalseForUnknownProduct() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        #expect(!receipt.containsPurchase(ofProductIdentifier: "com.nonexistent.product.xyz"))
    }

    @Test
    func purchasesReturnsEmptyForUnknownProduct() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        #expect(receipt.purchases(ofProductIdentifier: "com.nonexistent.product.xyz").isEmpty)
    }

    @Test
    func originalTransactionIdentifierReturnsNilForUnknownProduct() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        #expect(receipt.originalTransactionIdentifier(ofProductIdentifier: "com.nonexistent.product.xyz") == nil)
    }

    @Test
    func noActiveSubscriptionForUnknownProduct() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        #expect(
            !receipt.hasActiveAutoRenewableSubscription(
                ofProductIdentifier: "com.nonexistent.product.xyz",
                forDate: Date()
            )
        )
    }

    @Test
    func lastAutoRenewableReturnsNilForUnknownProduct() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-from-known-device")
        #expect(
            receipt.lastAutoRenewableSubscriptionPurchase(
                ofProductIdentifier: "com.nonexistent.product.xyz"
            ) == nil
        )
    }

    // MARK: - Purchase Queries (positive cases via receipt-with-transaction)

    @Test
    func containsPurchaseReturnsTrueForExistingProduct() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-with-transaction")
        try #require(!receipt.purchases.isEmpty, "Receipt must contain purchases for this test")

        let productId = receipt.purchases[0].productIdentifier
        #expect(receipt.containsPurchase(ofProductIdentifier: productId))
    }

    @Test
    func purchasesFiltersToMatchingProduct() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-with-transaction")
        try #require(!receipt.purchases.isEmpty, "Receipt must contain purchases for this test")

        let productId = receipt.purchases[0].productIdentifier
        let filtered = receipt.purchases(ofProductIdentifier: productId)

        #expect(!filtered.isEmpty)
        #expect(filtered.allSatisfy { $0.productIdentifier == productId })
    }

    @Test
    func purchasesSortedByDateDescendingByDefault() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-with-transaction")
        try #require(!receipt.purchases.isEmpty, "Receipt must contain purchases for this test")

        let productId = receipt.purchases[0].productIdentifier
        let sorted = receipt.purchases(ofProductIdentifier: productId)

        for i in 0..<(sorted.count - 1) {
            #expect(sorted[i].purchaseDate >= sorted[i + 1].purchaseDate)
        }
    }

    @Test
    func purchasesWithCustomSort() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-with-transaction")
        try #require(!receipt.purchases.isEmpty, "Receipt must contain purchases for this test")

        let productId = receipt.purchases[0].productIdentifier
        let ascending = receipt.purchases(ofProductIdentifier: productId) {
            $0.purchaseDate < $1.purchaseDate
        }

        for i in 0..<(ascending.count - 1) {
            #expect(ascending[i].purchaseDate <= ascending[i + 1].purchaseDate)
        }
    }

    @Test
    func originalTransactionIdentifierReturnsValueForExistingProduct() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-with-transaction")
        try #require(!receipt.purchases.isEmpty, "Receipt must contain purchases for this test")

        let productId = receipt.purchases[0].productIdentifier
        #expect(receipt.originalTransactionIdentifier(ofProductIdentifier: productId) != nil)
    }

    @Test
    func hasPurchasesReflectsPurchasePresence() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-with-transaction")
        #expect(receipt.hasPurchases)
    }

    @Test
    func autoRenewablePurchasesFiltersSubscriptions() throws {
        let receipt = try TestingUtility.parseReceipt("Assets/receipt-with-transaction")
        let autoRenewable = receipt.autoRenewablePurchases
        #expect(autoRenewable.allSatisfy { $0.isRenewableSubscription })
    }
}
