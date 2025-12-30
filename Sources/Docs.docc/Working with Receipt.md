# Working with a Receipt

Decode and read App Store receipt data.

## Decoding

```swift
import TPInAppReceipt

// Local receipt
let receipt = try await AppReceipt.local

// From raw data
let receipt = try AppReceipt.receipt(from: data)
```

`AppReceipt` is a typealias over `ContentInfo<SignedData<InAppReceiptPayload>>` — the full PKCS#7 structure is accessible.

## Reading

```swift
receipt.bundleIdentifier
receipt.appVersion
receipt.originalAppVersion   // String?
receipt.environment          // .production, .sandbox, .xcode, .productionSandbox
receipt.creationDate
receipt.expirationDate       // VPP only
```

See <doc:Receipt-Fields> for the full list of fields.

## Purchases

```swift
receipt.purchases              // [InAppPurchase]
receipt.hasPurchases
receipt.autoRenewablePurchases
receipt.activeAutoRenewableSubscriptionPurchases
```

Query by product:

```swift
receipt.purchases(ofProductIdentifier: "com.example.sub")
receipt.containsPurchase(ofProductIdentifier: "com.example.premium")

receipt.hasActiveAutoRenewableSubscription(
    ofProductIdentifier: "com.example.sub",
    forDate: Date()
)

receipt.lastAutoRenewableSubscriptionPurchase(
    ofProductIdentifier: "com.example.sub"
)
```

## Introductory Offer Eligibility

Pass product identifiers within the same subscription group:

```swift
receipt.isEligibleForIntroductoryOffer(
    for: ["com.example.bronze", "com.example.silver", "com.example.gold"]
)
```

## Refreshing

Request an updated receipt from the App Store:

```swift
try await AppReceipt.refresh()
```
