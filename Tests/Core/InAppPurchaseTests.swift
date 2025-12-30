import Foundation
import Testing

@testable import TPInAppReceipt

@Suite("InAppPurchase")
struct InAppPurchaseTests {
    // MARK: - isRenewableSubscription

    @Test
    func renewableWhenExpirationDatePresent() {
        let purchase = makePurchase(
            expirationDate: Date().addingTimeInterval(3600),
            cancellationDate: nil
        )
        #expect(purchase.isRenewableSubscription)
    }

    @Test
    func notRenewableWhenExpirationDateNil() {
        let purchase = makePurchase(expirationDate: nil, cancellationDate: nil)
        #expect(!purchase.isRenewableSubscription)
    }

    // MARK: - isActiveAutoRenewableSubscription

    @Test
    func activeWhenDateWithinRange() {
        let now = Date()
        let purchase = makePurchase(
            purchaseDate: now.addingTimeInterval(-3600),
            expirationDate: now.addingTimeInterval(3600),
            cancellationDate: nil
        )
        #expect(purchase.isActiveAutoRenewableSubscription(forDate: now))
    }

    @Test
    func inactiveWhenExpired() {
        let now = Date()
        let purchase = makePurchase(
            purchaseDate: now.addingTimeInterval(-7200),
            expirationDate: now.addingTimeInterval(-3600),
            cancellationDate: nil
        )
        #expect(!purchase.isActiveAutoRenewableSubscription(forDate: now))
    }

    @Test
    func inactiveWhenCancelled() {
        let now = Date()
        let purchase = makePurchase(
            purchaseDate: now.addingTimeInterval(-3600),
            expirationDate: now.addingTimeInterval(3600),
            cancellationDate: now.addingTimeInterval(-1800)
        )
        #expect(!purchase.isActiveAutoRenewableSubscription(forDate: now))
    }

    @Test
    func inactiveBeforePurchaseDate() {
        let now = Date()
        let purchase = makePurchase(
            purchaseDate: now.addingTimeInterval(3600),
            expirationDate: now.addingTimeInterval(7200),
            cancellationDate: nil
        )
        #expect(!purchase.isActiveAutoRenewableSubscription(forDate: now))
    }

    @Test
    func activeAtExactPurchaseDate() {
        let now = Date()
        let purchase = makePurchase(
            purchaseDate: now,
            expirationDate: now.addingTimeInterval(3600),
            cancellationDate: nil
        )
        #expect(purchase.isActiveAutoRenewableSubscription(forDate: now))
    }

    @Test
    func inactiveAtExactExpirationDate() {
        let now = Date()
        let purchase = makePurchase(
            purchaseDate: now.addingTimeInterval(-3600),
            expirationDate: now,
            cancellationDate: nil
        )
        #expect(!purchase.isActiveAutoRenewableSubscription(forDate: now))
    }
}

// MARK: - Helpers

private func makePurchase(
    purchaseDate: Date = Date(),
    expirationDate: Date?,
    cancellationDate: Date?
) -> InAppPurchase {
    InAppPurchase(
        productIdentifier: "com.example.subscription",
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
