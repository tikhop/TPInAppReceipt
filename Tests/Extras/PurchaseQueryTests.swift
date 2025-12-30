import Foundation
import Testing

@testable import TPInAppReceipt

@Suite("PurchaseQueries")
struct PurchaseQueryTests {
    // MARK: - containsPurchase

    @Test
    func containsPurchaseWhenProductExists() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly")
        ])
        #expect(payload.containsPurchase(ofProductIdentifier: "com.example.monthly"))
    }

    @Test
    func doesNotContainPurchaseWhenProductAbsent() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly")
        ])
        #expect(!payload.containsPurchase(ofProductIdentifier: "com.example.yearly"))
    }

    @Test
    func doesNotContainPurchaseWhenEmpty() {
        let payload = makePayload(purchases: [])
        #expect(!payload.containsPurchase(ofProductIdentifier: "com.example.monthly"))
    }

    // MARK: - purchases(ofProductIdentifier:)

    @Test
    func filtersToMatchingProduct() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly"),
            makePurchase(productIdentifier: "com.example.yearly"),
            makePurchase(productIdentifier: "com.example.monthly"),
        ])
        let result = payload.purchases(ofProductIdentifier: "com.example.monthly")
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.productIdentifier == "com.example.monthly" })
    }

    @Test
    func defaultSortIsDateDescending() {
        let now = Date()
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly", purchaseDate: now.addingTimeInterval(-7200)),
            makePurchase(productIdentifier: "com.example.monthly", purchaseDate: now),
            makePurchase(productIdentifier: "com.example.monthly", purchaseDate: now.addingTimeInterval(-3600)),
        ])
        let result = payload.purchases(ofProductIdentifier: "com.example.monthly")
        #expect(result.count == 3)
        #expect(result[0].purchaseDate == now)
        #expect(result[2].purchaseDate == now.addingTimeInterval(-7200))
    }

    @Test
    func customSortAscending() {
        let now = Date()
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly", purchaseDate: now),
            makePurchase(productIdentifier: "com.example.monthly", purchaseDate: now.addingTimeInterval(-3600)),
        ])
        let result = payload.purchases(ofProductIdentifier: "com.example.monthly") {
            $0.purchaseDate < $1.purchaseDate
        }
        #expect(result[0].purchaseDate < result[1].purchaseDate)
    }

    @Test
    func returnsEmptyWhenNoMatch() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.yearly")
        ])
        #expect(payload.purchases(ofProductIdentifier: "com.example.monthly").isEmpty)
    }

    // MARK: - originalTransactionIdentifier

    @Test
    func returnsOriginalTransactionId() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly", originalTxId: "orig-001")
        ])
        #expect(payload.originalTransactionIdentifier(ofProductIdentifier: "com.example.monthly") == "orig-001")
    }

    @Test
    func returnsNilForMissingProduct() {
        let payload = makePayload(purchases: [])
        #expect(payload.originalTransactionIdentifier(ofProductIdentifier: "com.example.monthly") == nil)
    }

    // MARK: - activeAutoRenewableSubscriptionPurchases

    @Test
    func findsActiveSubscription() {
        let now = Date()
        let payload = makePayload(purchases: [
            makeSubscription(
                productIdentifier: "com.example.monthly",
                purchaseDate: now.addingTimeInterval(-3600),
                expirationDate: now.addingTimeInterval(3600)
            )
        ])
        let active = payload.activeAutoRenewableSubscriptionPurchases(
            ofProductIdentifier: "com.example.monthly",
            forDate: now
        )
        #expect(active != nil)
        #expect(active?.productIdentifier == "com.example.monthly")
    }

    @Test
    func returnsNilWhenSubscriptionExpired() {
        let now = Date()
        let payload = makePayload(purchases: [
            makeSubscription(
                productIdentifier: "com.example.monthly",
                purchaseDate: now.addingTimeInterval(-7200),
                expirationDate: now.addingTimeInterval(-3600)
            )
        ])
        let active = payload.activeAutoRenewableSubscriptionPurchases(
            ofProductIdentifier: "com.example.monthly",
            forDate: now
        )
        #expect(active == nil)
    }

    // MARK: - lastAutoRenewableSubscriptionPurchase

    @Test
    func returnsSubscriptionWithLatestExpiration() {
        let now = Date()
        let payload = makePayload(purchases: [
            makeSubscription(
                productIdentifier: "com.example.monthly",
                purchaseDate: now.addingTimeInterval(-7200),
                expirationDate: now.addingTimeInterval(-3600)
            ),
            makeSubscription(
                productIdentifier: "com.example.monthly",
                purchaseDate: now.addingTimeInterval(-3600),
                expirationDate: now.addingTimeInterval(3600)
            ),
        ])
        let last = payload.lastAutoRenewableSubscriptionPurchase(
            ofProductIdentifier: "com.example.monthly"
        )
        #expect(last?.subscriptionExpirationDate == now.addingTimeInterval(3600))
    }

    @Test
    func returnsNilWhenNoSubscriptions() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.consumable")
        ])
        #expect(
            payload.lastAutoRenewableSubscriptionPurchase(
                ofProductIdentifier: "com.example.consumable"
            ) == nil
        )
    }

    // MARK: - hasActiveAutoRenewableSubscription

    @Test
    func hasActiveSubscriptionWhenActive() {
        let now = Date()
        let payload = makePayload(purchases: [
            makeSubscription(
                productIdentifier: "com.example.monthly",
                purchaseDate: now.addingTimeInterval(-3600),
                expirationDate: now.addingTimeInterval(3600)
            )
        ])
        #expect(
            payload.hasActiveAutoRenewableSubscription(
                ofProductIdentifier: "com.example.monthly",
                forDate: now
            )
        )
    }

    @Test
    func noActiveSubscriptionWhenAllExpired() {
        let now = Date()
        let payload = makePayload(purchases: [
            makeSubscription(
                productIdentifier: "com.example.monthly",
                purchaseDate: now.addingTimeInterval(-7200),
                expirationDate: now.addingTimeInterval(-3600)
            )
        ])
        #expect(
            !payload.hasActiveAutoRenewableSubscription(
                ofProductIdentifier: "com.example.monthly",
                forDate: now
            )
        )
    }

    // MARK: - hasPurchases / autoRenewablePurchases

    @Test
    func hasPurchasesWhenNonEmpty() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly")
        ])
        #expect(payload.hasPurchases)
    }

    @Test
    func hasPurchasesIsFalseWhenEmpty() {
        let payload = makePayload(purchases: [])
        #expect(!payload.hasPurchases)
    }

    @Test
    func autoRenewablePurchasesFiltersCorrectly() {
        let now = Date()
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.consumable"),
            makeSubscription(
                productIdentifier: "com.example.monthly",
                purchaseDate: now.addingTimeInterval(-3600),
                expirationDate: now.addingTimeInterval(3600)
            ),
        ])
        let autoRenewable = payload.autoRenewablePurchases
        #expect(autoRenewable.count == 1)
        #expect(autoRenewable[0].productIdentifier == "com.example.monthly")
    }
}

// MARK: - Helpers

/// Wraps `InAppReceiptPayload` to expose AppReceipt-like query methods for testing
/// without needing a real PKCS#7 structure.
private struct PayloadQueryWrapper {
    let payload: InAppReceiptPayload

    var purchases: [InAppPurchase] { payload.purchases }
    var hasPurchases: Bool { !purchases.isEmpty }

    var autoRenewablePurchases: [InAppPurchase] {
        purchases.filter { $0.isRenewableSubscription }
    }

    func containsPurchase(ofProductIdentifier productIdentifier: String) -> Bool {
        purchases.contains { $0.productIdentifier == productIdentifier }
    }

    func purchases(
        ofProductIdentifier productIdentifier: String,
        sortedBy sort: ((InAppPurchase, InAppPurchase) -> Bool)? = nil
    ) -> [InAppPurchase] {
        let filtered = purchases.filter { $0.productIdentifier == productIdentifier }
        guard let sort else {
            return filtered.sorted { $0.purchaseDate > $1.purchaseDate }
        }
        return filtered.sorted { sort($0, $1) }
    }

    func originalTransactionIdentifier(ofProductIdentifier productIdentifier: String) -> String? {
        purchases(ofProductIdentifier: productIdentifier)
            .first?
            .originalTransactionIdentifier
    }

    func activeAutoRenewableSubscriptionPurchases(
        ofProductIdentifier productIdentifier: String,
        forDate date: Date
    ) -> InAppPurchase? {
        purchases(ofProductIdentifier: productIdentifier)
            .first { $0.isActiveAutoRenewableSubscription(forDate: date) }
    }

    func lastAutoRenewableSubscriptionPurchase(
        ofProductIdentifier productIdentifier: String
    ) -> InAppPurchase? {
        purchases(ofProductIdentifier: productIdentifier)
            .filter { $0.subscriptionExpirationDate != nil }
            .max { ($0.subscriptionExpirationDate ?? .distantPast) < ($1.subscriptionExpirationDate ?? .distantPast) }
    }

    func hasActiveAutoRenewableSubscription(
        ofProductIdentifier productIdentifier: String,
        forDate date: Date
    ) -> Bool {
        activeAutoRenewableSubscriptionPurchases(
            ofProductIdentifier: productIdentifier,
            forDate: date
        ) != nil
    }
}

private func makePayload(purchases: [InAppPurchase]) -> PayloadQueryWrapper {
    PayloadQueryWrapper(
        payload: InAppReceiptPayload(
            bundleIdentifier: "com.example.app",
            appVersion: "1.0",
            originalAppVersion: "1.0",
            originalPurchaseDate: Date(),
            purchases: purchases,
            expirationDate: nil,
            bundleIdentifierData: Data(),
            opaqueValue: Data(),
            receiptHash: Data(),
            creationDate: Date(),
            ageRating: nil,
            environment: .sandbox
        )
    )
}

private func makePurchase(
    productIdentifier: String,
    purchaseDate: Date = Date(),
    originalTxId: String = UUID().uuidString
) -> InAppPurchase {
    InAppPurchase(
        productIdentifier: productIdentifier,
        productType: .nonConsumable,
        transactionIdentifier: UUID().uuidString,
        originalTransactionIdentifier: originalTxId,
        purchaseDate: purchaseDate,
        originalPurchaseDate: purchaseDate,
        subscriptionExpirationDate: nil,
        cancellationDate: nil,
        subscriptionTrialPeriod: false,
        subscriptionIntroductoryPricePeriod: false,
        webOrderLineItemID: nil,
        promotionalOfferIdentifier: nil,
        quantity: 1
    )
}

private func makeSubscription(
    productIdentifier: String,
    purchaseDate: Date,
    expirationDate: Date,
    cancellationDate: Date? = nil
) -> InAppPurchase {
    InAppPurchase(
        productIdentifier: productIdentifier,
        productType: .autoRenewableSubscription,
        transactionIdentifier: UUID().uuidString,
        originalTransactionIdentifier: UUID().uuidString,
        purchaseDate: purchaseDate,
        originalPurchaseDate: purchaseDate,
        subscriptionExpirationDate: expirationDate,
        cancellationDate: cancellationDate,
        subscriptionTrialPeriod: false,
        subscriptionIntroductoryPricePeriod: false,
        webOrderLineItemID: nil,
        promotionalOfferIdentifier: nil,
        quantity: 1
    )
}
