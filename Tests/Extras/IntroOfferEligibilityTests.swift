import Foundation
import Testing

@testable import TPInAppReceipt

@Suite("IntroOfferEligibility")
struct IntroOfferEligibilityTests {
    // MARK: - Per-Product Eligibility

    @Test
    func eligibleWhenNoPurchases() {
        let payload = makePayload(purchases: [])
        #expect(payload.isEligibleForIntroOffer(for: "com.example.monthly"))
    }

    @Test
    func eligibleWhenProductNotPurchased() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.yearly", trial: false, intro: false)
        ])
        #expect(payload.isEligibleForIntroOffer(for: "com.example.monthly"))
    }

    @Test
    func eligibleWhenPurchasedWithoutTrialOrIntro() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly", trial: false, intro: false)
        ])
        #expect(payload.isEligibleForIntroOffer(for: "com.example.monthly"))
    }

    @Test
    func notEligibleWhenRedeemedTrial() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly", trial: true, intro: false)
        ])
        #expect(!payload.isEligibleForIntroOffer(for: "com.example.monthly"))
    }

    @Test
    func notEligibleWhenRedeemedIntroPrice() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly", trial: false, intro: true)
        ])
        #expect(!payload.isEligibleForIntroOffer(for: "com.example.monthly"))
    }

    @Test
    func notEligibleWhenRedeemedBothTrialAndIntro() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly", trial: true, intro: true)
        ])
        #expect(!payload.isEligibleForIntroOffer(for: "com.example.monthly"))
    }

    @Test
    func eligibleWhenOtherProductUsedTrial() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.yearly", trial: true, intro: false)
        ])
        #expect(payload.isEligibleForIntroOffer(for: "com.example.monthly"))
    }

    @Test
    func notEligibleWhenAnyPurchaseForProductUsedTrial() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly", trial: false, intro: false),
            makePurchase(productIdentifier: "com.example.monthly", trial: true, intro: false),
        ])
        #expect(!payload.isEligibleForIntroOffer(for: "com.example.monthly"))
    }

    // MARK: - Per-Group Eligibility

    @Test
    func groupEligibleWhenNoPurchases() {
        let payload = makePayload(purchases: [])
        let group: Set<String> = ["com.example.monthly", "com.example.yearly"]
        #expect(payload.isEligibleForIntroOffer(for: group))
    }

    @Test
    func groupEligibleWhenNoGroupProductPurchased() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.other", trial: true, intro: false)
        ])
        let group: Set<String> = ["com.example.monthly", "com.example.yearly"]
        #expect(payload.isEligibleForIntroOffer(for: group))
    }

    @Test
    func groupEligibleWhenGroupProductPurchasedWithoutTrialOrIntro() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly", trial: false, intro: false)
        ])
        let group: Set<String> = ["com.example.monthly", "com.example.yearly"]
        #expect(payload.isEligibleForIntroOffer(for: group))
    }

    @Test
    func groupNotEligibleWhenAnyGroupProductUsedTrial() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly", trial: true, intro: false)
        ])
        let group: Set<String> = ["com.example.monthly", "com.example.yearly"]
        #expect(!payload.isEligibleForIntroOffer(for: group))
    }

    @Test
    func groupNotEligibleWhenAnyGroupProductUsedIntroPrice() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.yearly", trial: false, intro: true)
        ])
        let group: Set<String> = ["com.example.monthly", "com.example.yearly"]
        #expect(!payload.isEligibleForIntroOffer(for: group))
    }

    @Test
    func groupNotEligibleWhenOneOfManyGroupProductsUsedTrial() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly", trial: false, intro: false),
            makePurchase(productIdentifier: "com.example.yearly", trial: true, intro: false),
        ])
        let group: Set<String> = ["com.example.monthly", "com.example.yearly"]
        #expect(!payload.isEligibleForIntroOffer(for: group))
    }

    @Test
    func groupEligibleWithMixedGroupAndNonGroupPurchases() {
        let payload = makePayload(purchases: [
            makePurchase(productIdentifier: "com.example.monthly", trial: false, intro: false),
            makePurchase(productIdentifier: "com.example.other", trial: true, intro: true),
        ])
        let group: Set<String> = ["com.example.monthly", "com.example.yearly"]
        #expect(payload.isEligibleForIntroOffer(for: group))
    }
}

// MARK: - Helpers

private func makePurchase(
    productIdentifier: String,
    trial: Bool,
    intro: Bool
) -> InAppPurchase {
    InAppPurchase(
        productIdentifier: productIdentifier,
        productType: .autoRenewableSubscription,
        transactionIdentifier: UUID().uuidString,
        originalTransactionIdentifier: UUID().uuidString,
        purchaseDate: Date(),
        originalPurchaseDate: Date(),
        subscriptionExpirationDate: nil,
        cancellationDate: nil,
        subscriptionTrialPeriod: trial,
        subscriptionIntroductoryPricePeriod: intro,
        webOrderLineItemID: nil,
        promotionalOfferIdentifier: nil,
        quantity: 1
    )
}

private func makePayload(purchases: [InAppPurchase]) -> InAppReceiptPayload {
    InAppReceiptPayload(
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
}
