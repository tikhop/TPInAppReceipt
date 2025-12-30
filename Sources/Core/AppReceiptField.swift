/// The field types present in an app receipt ASN.1 structure.
public enum AppReceiptField: Int, Sendable {
    /// The receipt's environment (Xcode, Production, or ProductionSandbox).
    case environment = 0

    /// The App Store ID
    case appStoreID = 1

    /// The app's bundle identifier.
    case bundleIdentifier = 2

    /// The app's version number.
    case appVersion = 3

    /// An opaque value used to compute the SHA-1 hash during validation.
    case opaqueValue = 4

    /// The SHA-1 hash used to validate the receipt.
    case receiptHash = 5

    /// Reserved for future use.
    case unknown_6 = 6

    /// Reserved for future use.
    case unknown_7 = 7

    /// The transaction date.
    case transactionDate = 8

    /// The fulfillment tool version.
    case fulfillmentToolVersion = 9

    /// The age rating of the app.
    case ageRating = 10

    /// The developer ID.
    case developerID = 11

    /// The date when the app receipt was created.
    case receiptCreationDate = 12

    /// Reserved for future use.
    case unknown_13 = 13

    /// Reserved for future use.
    case unknown_14 = 14

    /// The download ID.
    case downloadID = 15

    /// The installer version ID.
    case installerVersionID = 16

    /// The receipt for an in-app purchase.
    case inAppPurchaseReceipt = 17

    /// The date when the app was originally purchased.
    case originalAppPurchaseDate = 18

    /// The version of the app that was originally purchased.
    case originalAppVersion = 19

    /// Reserved for future use.
    case unknown_20 = 20

    /// The date that the app receipt expires.
    case expirationDate = 21

    /// Reserved for future use.
    case unknown_25 = 25
}

/// The field types present in an in-app purchase receipt ASN.1 structure.
public enum InAppPurchaseReceiptField: Int, Sendable {
    /// The number of items purchased.
    case quantity = 1701

    /// The product identifier of the item that was purchased.
    case productIdentifier = 1702

    /// The transaction identifier of the item that was purchased.
    case transactionIdentifier = 1703

    /// The date and time that the item was purchased.
    case purchaseDate = 1704

    /// The transaction identifier of the original purchase.
    case originalTransactionIdentifier = 1705

    /// The date of the original transaction.
    case originalPurchaseDate = 1706

    /// The type of in-app product.
    case productType = 1707

    /// The expiration date for the subscription.
    case subscriptionExpirationDate = 1708

    /// Unknown field.
    case unknown_1709 = 1709

    /// Unknown field.
    case unknown_1710 = 1710

    /// The primary key for identifying subscription purchases.
    case webOrderLineItemID = 1711

    /// The time and date of the cancellation.
    case cancellationDate = 1712

    /// Whether the subscription is in the free trial period.
    case subscriptionTrialPeriod = 1713

    /// Unknown field.
    case unknown_1714 = 1714

    /// Unknown field.
    case unknown_1715 = 1715

    /// Unknown field.
    case unknown_1716 = 1716

    /// Unknown field.
    case unknown_1717 = 1717

    /// Unknown field.
    case unknown_1718 = 1718

    /// Whether the subscription is in the introductory price period.
    case subscriptionIntroductoryPricePeriod = 1719

    /// The identifier of the subscription offer the user redeemed.
    case promotionalOfferIdentifier = 1721

    /// Unknown field.
    case unknown_1722 = 1722
}
