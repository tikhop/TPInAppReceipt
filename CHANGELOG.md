# Changelog

## 4.0.2

### Fixed

- Use `SecChainVerifier` for xCode env receipts 

## 4.0.1

### Fixed

- Compilation issue for Catalyst platform

## 4.0.0

### Breaking Changes

- `InAppReceipt` class replaced by `AppReceipt` typealias over `ContentInfo<SignedData<InAppReceiptPayload>>`
- Sync validation (`try receipt.verify()`) replaced by async (`await receipt.validate()`)
- Error types renamed: `IARError` → `AppReceiptError`, `ReceiptValidatorError`
- `originalAppVersion` is now `String?` (was `String`)
- `ageRating` is now `String?` (was `String`)
- Minimum platforms raised: iOS 13+, macOS 10.15+, tvOS 13+
- Swift tools version: 6.0
- Removed Objective-C support
- Removed CocoaPods support

### New

- Full PKCS#7 structure: `ContentInfo`, `SignedData`, `EncapsulatedContentInfo`, `SignerInfo`, `AlgorithmIdentifier`, etc.
- Composable validation via `@VerifierBuilder` and `ReceiptValidator`
- X.509 certificate chain verification using swift-certificates
- Signature verification using swift-crypto
- New receipt fields: `environment`, `appStoreID`, `transactionDate`, `fulfillmentToolVersion`, `developerID`, `downloadID`, `installerVersionID`
- `InAppReceiptPayload.Environment` enum (`.production`, `.sandbox`, `.xcode`, `.productionSandbox`)
- `InAppPurchase.Type` enum (`.consumable`, `.nonConsumable`, `.autoRenewableSubscription`, `.nonRenewingSubscription`)
- Blocking API via `@_spi(Blocking)`: `local_blocking`, `validate_blocking()`
- Pluggable decoder via `AppReceiptDecoder.Engine` protocol
- DocC documentation
- Privacy manifest (`PrivacyInfo.xcprivacy`)
- visionOS support

### Dependencies

- Removed: ASN1Swift
- Added: [swift-asn1](https://github.com/apple/swift-asn1) 1.5.0+, [swift-certificates](https://github.com/apple/swift-certificates) 1.15.1+, [swift-crypto](https://github.com/apple/swift-crypto) 4.2.0+
