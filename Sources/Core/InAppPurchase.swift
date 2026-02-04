#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A record of an in-app purchase transaction.
public struct InAppPurchase: Sendable, Hashable {
    /// The type of in-app purchase product.
    public enum `Type`: Int32, Sendable {
        /// An unknown in-app purchase type.
        case unknown = -1

        /// A non-consumable in-app purchase.
        case nonConsumable

        /// A consumable in-app purchase.
        case consumable

        /// A non-renewing subscription.
        case nonRenewingSubscription

        /// An auto-renewable subscription.
        case autoRenewableSubscription
    }

    /// The product identifier of the item that was purchased.
    public let productIdentifier: String

    /// The type of in-app product.
    public let productType: Type

    /// The transaction identifier of the item that was purchased.
    public let transactionIdentifier: String

    /// The transaction identifier of the original purchase.
    public let originalTransactionIdentifier: String

    /// The date and time that the item was purchased.
    public let purchaseDate: Date

    /// The date of the original transaction.
    ///
    /// Returns `nil` when testing with StoreKitTest.
    public let originalPurchaseDate: Date?

    /// The expiration date for the subscription.
    ///
    /// Only present for auto-renewable subscription receipts.
    public let subscriptionExpirationDate: Date?

    /// The date Apple customer support canceled a transaction or the date of an upgrade transaction.
    ///
    /// Present for auto-renewable subscriptions, non-consumable products, and non-renewing subscriptions
    /// when the transaction has been canceled or refunded. Returns `nil` if the purchase has not been
    /// canceled or refunded.
    public let cancellationDate: Date?

    /// Whether the subscription is in the free trial period.
    public let subscriptionTrialPeriod: Bool

    /// Whether the subscription is in the introductory price period.
    public let subscriptionIntroductoryPricePeriod: Bool

    /// The primary key for identifying subscription purchases.
    ///
    /// This value is a unique ID that identifies purchase events across devices,
    /// including subscription renewal purchase events.
    public let webOrderLineItemID: Int?

    /// The identifier of the subscription offer the user redeemed.
    public let promotionalOfferIdentifier: String?

    /// The number of items purchased.
    public let quantity: Int

    /// Creates an in-app purchase record with the specified values.
    public init(
        productIdentifier: String,
        productType: Type,
        transactionIdentifier: String,
        originalTransactionIdentifier: String,
        purchaseDate: Date,
        originalPurchaseDate: Date?,
        subscriptionExpirationDate: Date?,
        cancellationDate: Date?,
        subscriptionTrialPeriod: Bool,
        subscriptionIntroductoryPricePeriod: Bool,
        webOrderLineItemID: Int?,
        promotionalOfferIdentifier: String?,
        quantity: Int
    ) {
        self.productIdentifier = productIdentifier
        self.productType = productType
        self.transactionIdentifier = transactionIdentifier
        self.originalTransactionIdentifier = originalTransactionIdentifier
        self.purchaseDate = purchaseDate
        self.originalPurchaseDate = originalPurchaseDate
        self.subscriptionExpirationDate = subscriptionExpirationDate
        self.cancellationDate = cancellationDate
        self.subscriptionTrialPeriod = subscriptionTrialPeriod
        self.subscriptionIntroductoryPricePeriod = subscriptionIntroductoryPricePeriod
        self.webOrderLineItemID = webOrderLineItemID
        self.promotionalOfferIdentifier = promotionalOfferIdentifier
        self.quantity = quantity
    }
}

extension InAppPurchase {
    /// A Boolean value indicating whether the purchase is a renewable subscription.
    public var isRenewableSubscription: Bool {
        subscriptionExpirationDate != nil
    }

    /// Returns whether the auto-renewable subscription is active for the specified date.
    ///
    /// - Parameter date: The date to check subscription activity.
    /// - Returns: `true` if the subscription is active on the given date, `false` otherwise.
    public func isActiveAutoRenewableSubscription(forDate date: Date) -> Bool {
        assert(isRenewableSubscription, "\(productIdentifier) is not an auto-renewable subscription.")

        if cancellationDate != nil {
            return false
        }

        guard let expirationDate = subscriptionExpirationDate else {
            return false
        }

        return date >= purchaseDate && date < expirationDate
    }
}
