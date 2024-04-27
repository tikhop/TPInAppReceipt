<p align="center">
  <img height="160" src="https://github.com/tikhop/TPInAppReceipt/blob/master/www/logo.png" />
</p>


# TPInAppReceipt

![Swift](https://github.com/tikhop/TPInAppReceipt/workflows/Swift/badge.svg?branch=master)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/TPInAppReceipt.svg)](https://cocoapods.org/pods/TPInAppReceipt)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/cocoapods/p/TPInAppReceipt.svg?style=flat)]()
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/tikhop/TPInAppReceipt/master/LICENSE)

TPInAppReceipt is a lightweight, pure-Swift library for reading and validating Apple In App Purchase Receipt locally.

## Features

- [x] Read all In-App Receipt Attributes
- [x] Validate In-App Purchase Receipt (Signature, Bundle Version and Identifier, Hash)
- [x] Determine Eligibility for Introductory Offer
- [x] Use with StoreKitTest
- [x] Use in Objective-C projects

Installation
------------

> Note: [TPInAppReceipt in Objective-C project](https://github.com/tikhop/TPInAppReceipt/blob/master/Documentation/UseInObjCProject.md) - If you want to use TPInAppReceipt in Objective-C project please follow this guide. 

### CocoaPods

To integrate TPInAppReceipt into your project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '12.0'

target 'YOUR_TARGET' do
  use_frameworks!

  pod 'TPInAppReceipt'
end

```

Then, run the following command:

```bash
$ pod install
```

In any swift file you'd like to use TPInAppReceipt, import the framework with `import TPInAppReceipt`.

### Swift Package Manager

To integrate using Apple's Swift package manager, add the following as a dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/tikhop/TPInAppReceipt.git", .upToNextMajor(from: "3.0.0"))
```

Then, specify `"TPInAppReceipt"` as a dependency of the Target in which you wish to use TPInAppReceipt.

Lastly, run the following command:
```swift
swift package update
```

### Requirements

- iOS 12.0+ / OSX 10.13+
- Swift 5.9+

Usage
-------------

### Working With a Receipt

The [`InAppReceipt`](https://tikhop.github.io/TPInAppReceipt/Classes/InAppReceipt.html) object encapsulates information about a receipt and the purchases associated with it. To validate In-App Purchase Receipt you must create an `InAppReceipt` object.

#### Initializing Receipt

To create [`InAppReceipt`](https://tikhop.github.io/TPInAppReceipt/Classes/InAppReceipt.html) object you can either provide a raw receipt data or initialize a local receipt.

```swift
do {
  /// Initialize receipt
  let receipt = try InAppReceipt.localReceipt() 
  // let receipt = try InAppReceipt() // Returns local receipt 
  
  // let receiptData: Data = ...
  // let receipt = try InAppReceipt.receipt(from: receiptData)
  
} catch {
  print(error)
}


```

#### Validating Receipt

`TPInAppReceipt` provides a variety of convenience methods for validating In-App Purchase Receipt:

```swift

/// Verify hash 
try? receipt.verifyHash()

/// Verify bundle identifier
try? receipt.verifyBundleIdentifier()

/// Verify bundle version
try? receipt.verifyBundleVersion()

/// Verify signature
try? receipt.verifySignature()

/// Validate all at once 
do {
  try receipt.verify()
} catch IARError.validationFailed(reason: .hashValidation) {
  // Do smth
} catch IARError.validationFailed(reason: .bundleIdentifierVerification) {
  // Do smth
} catch IARError.validationFailed(reason: .signatureValidation) {
  // Do smth
} catch {
  // Do smth
}

```

> NOTE: Apple recommends to perform receipt validation right after your app is launched. For additional security, you may repeat this check periodically while your application is running.
> NOTE: If validation fails in iOS, try to refresh the receipt first.

#### Determining Eligibility for Introductory Offer  

If your App offers introductory pricing for auto-renewable subscriptions, you will need to dispay the correct price, either the intro or regular price.   
The [`InAppReceipt`](https://tikhop.github.io/TPInAppReceipt/Classes/InAppReceipt.html) class provides an interface for determining introductory price eligibility. At the simplest, just provide a `Set`  of product identifiers that belong to the same subscription group:

```swift
// Check whether user is eligible for any products within the same subscription group 
var isEligible = receipt.isEligibleForIntroductoryOffer(for: ["com.test.product.bronze", "com.test.product.silver", "com.test.product.gold"])
```

> Note: To determine if a user is eligible for an introductory offer, you must initialize and validate receipt first and only then check for eligibility.


#### Reading Receipt

```swift
/// Initialize receipt
let receipt = try! InAppReceipt.localReceipt() 

/// Base64 Encoded Receipt
let base64Receipt = receipt.base64
  
/// Check whether receipt contains any purchases
let hasPurchases = receipt.hasPurchases

/// All auto renewable `InAppPurchase`s,
let purchases: [InAppPurchase] = receipt.autoRenewablePurchases 

/// all ACTIVE auto renewable `InAppPurchase`s,
let activePurchases: [InAppPurchase] = receipt.activeAutoRenewableSubscriptionPurchases 

```

#### Useful methods

```swift

// Retrieve Original TransactionIdentifier for Product Name
receipt.originalTransactionIdentifier(ofProductIdentifier: subscriptionName)

// Retrieve Active Auto Renewable Subscription's Purchases for Product Name and Specific Date
receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: subscriptionName, forDate: Date())

// Retrieve All Purchases for Product Name
receipt.purchases(ofProductIdentifier: subscriptionName)

```

#### Refreshing/Requesting Receipt

When necessary, use this method to ensure the receipt you are working with is up-to-date. 

```swift
InAppReceipt.refresh { (error) in
  if let err = error
  {
    print(err)
  } else {
    initializeReceipt()
  }
}

```

## Essential Reading
* [Apple - About Receipt Validation](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Introduction.html)
* [Apple - Receipt Validation Programming Guide](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1)
* [Apple - Validating Receipts Locally](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateLocally.html)
* [fluffy.es - Tutorial: Read and validate in-app purchase receipt locally using TPInAppReceipt](https://fluffy.es/in-app-purchase-receipt-local/)
* [Faisal Bin Ahmed - All the wrong ways to persist in-app purchase status in your macOS app](https://medium.com/@Faisalbin/all-the-wrong-ways-to-persist-in-app-purchase-status-in-your-macos-app-ce6eb9bcb0c3)
* [objc.io - Receipt Validation](https://www.objc.io/issues/17-security/receipt-validation/)



## License

TPInAppReceipt is released under an MIT license. See [LICENSE](https://github.com/tikhop/TPInAppReceipt/blob/master/LICENSE) for more information.
