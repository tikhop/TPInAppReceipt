<p align="center">
  <img height="160" src="https://github.com/tikhop/TPInAppReceipt/blob/master/www/logo.png" />
</p>

# TPInAppReceipt

![Swift](https://github.com/tikhop/TPInAppReceipt/workflows/Swift/badge.svg?branch=master)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/tikhop/TPInAppReceipt/master/LICENSE)

Local decoding and validation of Apple App Store receipts. Built on top of Apple's [swift-asn1](https://github.com/apple/swift-asn1), [swift-certificates](https://github.com/apple/swift-certificates), and [swift-crypto](https://github.com/apple/swift-crypto).

```swift
let receipt = try await AppReceipt.local

receipt.bundleIdentifier    // "com.example.app"
receipt.environment         // .production, .sandbox, .xcode
receipt.purchases           // [InAppPurchase]

let result = await receipt.validate()
```

## Requirements

- Swift 6.0+ / Xcode 16+
- macOS 10.15+ / iOS 13+ / tvOS 13+ / watchOS 6.2+ / visionOS 1+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/tikhop/TPInAppReceipt.git", from: "4.0.0")
]
```

```swift
.target(
    name: "YourTarget",
    dependencies: ["TPInAppReceipt"]
)
```

## Usage

### Decoding and Reading

```swift
import TPInAppReceipt

// Local receipt
let receipt = try await AppReceipt.local

// From raw data
let receipt = try AppReceipt.receipt(from: data)
```

Access receipt fields, query purchases, check subscriptions and introductory offer eligibility. See <doc:Working-with-Receipt> for details.

### Validating

Default validation: certificate chain + signature + hash + metadata.

```swift
let result = await receipt.validate()

switch result {
case .valid:
    break
case .invalid(let error):
    print(error)
}
```

Supports custom validators via `@VerifierBuilder`. See <doc:Validating-Receipt> for details.

### Blocking API

For contexts where async is not available. See <doc:Blocking-Mode>.

```swift
@_spi(Blocking) import TPInAppReceipt

let receipt = try AppReceipt.local_blocking
let result = receipt.validate_blocking()
```

## Migrating from v3

See <doc:Migrating-to-v4>.

## Essential Reading

* [Apple - About Receipt Validation](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Introduction.html)
* [Apple - Receipt Validation Programming Guide](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1)
* [Apple - Validating Receipts Locally](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateLocally.html)
* [fluffy.es - Tutorial: Read and validate in-app purchase receipt locally using TPInAppReceipt](https://fluffy.es/in-app-purchase-receipt-local/)
* [Faisal Bin Ahmed - All the wrong ways to persist in-app purchase status in your macOS app](https://medium.com/@Faisalbin/all-the-wrong-ways-to-persist-in-app-purchase-status-in-your-macos-app-ce6eb9bcb0c3)
* [objc.io - Receipt Validation](https://www.objc.io/issues/17-security/receipt-validation/)

## License

MIT
