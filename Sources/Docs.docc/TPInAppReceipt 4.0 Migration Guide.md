# Migrating from v3 to v4

What changed and how to update your code.

## Dependencies

```swift
.package(url: "https://github.com/tikhop/TPInAppReceipt.git", from: "4.0.0")
```

## Platform Requirements

- iOS 12 → iOS 13
- macOS 10.13 → macOS 10.15
- tvOS 12 → tvOS 13
- Swift 5.9 → Swift 6.0

## Type Changes

```swift
// Before
let receipt = try InAppReceipt.localReceipt()
// or
let receipt = try InAppReceipt()

// After
let receipt = try await AppReceipt.local
```

```swift
// Before
let receipt = try InAppReceipt.receipt(from: data)

// After
let receipt = try AppReceipt.receipt(from: data)
```

## Validation

```swift
// Before
do {
    try receipt.verify()
} catch IARError.validationFailed(reason: .hashValidation) {
    // ...
}

// After
let result = await receipt.validate()
switch result {
case .valid:
    break
case .invalid(let error):
    // error is typed: ReceiptValidatorError, ChainVerificationError, etc.
    print(error)
}
```

Individual verification methods (`verifyHash()`, `verifySignature()`, `verifyBundleIdentifier()`) are removed. Use custom `ReceiptValidator` composition instead. See <doc:Validating-Receipt>.

## Error Types

| v3 | v4 |
|----|-----|
| `IARError` | `AppReceiptError` |
| `IARError.validationFailed(reason:)` | `ReceiptValidatorError`, `ChainVerificationError`, `HashVerificationError`, etc. |

## Property Changes

- `originalAppVersion` is now `String?` (was `String`)
- `ageRating` is now `String?` (was `String`)
- `environment` is now `InAppReceiptPayload.Environment` enum (was `String`). Update comparisons: `receipt.environment == .production` instead of `receipt.environment == "Production"`.
- `signature` is now `Data` (was `Data?`)
- `InAppPurchase` properties are now `let` (was `var`)
- `InAppPurchase.originalPurchaseDate` is now `Date?` (was `Date!`)
- `autoRenewablePurchases` — same API, works on `AppReceipt`
- `activeAutoRenewableSubscriptionPurchases` — same API

## Blocking API

If you prefer synchronous api, import the library with `@_spi(Blocking)` to access blocking variants of the async API.

```swift
@_spi(Blocking) import TPInAppReceipt

// Load receipt
let receipt = try AppReceipt.local_blocking

// Validate
let result = receipt.validate_blocking()
```

See <doc:Blocking-Mode> for more details.

## Receipt Refresh

```swift
// Before
InAppReceipt.refresh { error in
    // ...
}

// After
try await AppReceipt.refresh()
```

`cancelRefreshSession()` and `isReceiptRefreshingNow` are removed. Use Swift Concurrency task cancellation instead.

## Receipt Fields

`InAppReceiptField` has been renamed to `AppReceiptField` and changed from a struct with static constants to an enum. Purchase-specific fields are now in a separate `InAppPurchaseReceiptField` enum.

## Removed

- Objective-C bindings
- CocoaPods support
- `isValid` computed property — use `await receipt.validate()` instead
- `base64` computed property
- `SKSubscriptionGroup` class and related `SKProductsResponse` extensions
- `isEligibleForIntroductoryOffer(for: SKSubscriptionGroup)` overload — use `Set<String>` variant instead
