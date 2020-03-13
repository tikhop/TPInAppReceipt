<p align="center">
  <img height="160" src="www/logo.png" />
</p>


# TPInAppReceipt

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/TPInAppReceipt.svg)](https://cocoapods.org/pods/TPInAppReceipt)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/cocoapods/p/TPInAppReceipt.svg?style=flat)]()
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/tikhop/TPInAppReceipt/master/LICENSE)

A lightweight iOS/OSX library for reading and validating Apple In App Purchase Receipt locally.

## Features

- [x] ~~OpenSSL~~
- [x] Extract all In-App Receipt Attributes
- [x] Hash Verification
- [x] Verify Bundle Version and Identifiers
- [x] Signature Verification


Installation
------------

### CocoaPods

To integrate TPInAppReceipt into your project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '9.0'

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
.package(url: "https://github.com/tikhop/TPInAppReceipt.git", .upToNextMajor(from: "2.3.0"))
```

Then, specify `"TPInAppReceipt"` as a dependency of the Target in which you wish to use TPInAppReceipt.

Lastly, run the following command:
```swift
swift package update
```

**Note:**
Currenty, SwiftPM doesn't support the feature of adding resources to package and therefore you have to add the Apple Root Certificate manually. You can find it [here](https://www.apple.com/certificateauthority/). 


### Carthage

Make the following entry in your Cartfile:

```
github "tikhop/TPInAppReceipt" 
```

Then run `carthage update`.

If this is your first time using Carthage in the project, you'll need to go through some additional steps as explained [over at Carthage](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).


### Requirements

- iOS 9.0+ / OSX 10.11+
- Swift 5.0+

Usage
-------------

### Working With a Receipt

`InAppReceipt` is an object to incapsulate all necessary getters from a receipt payload and provides a comprehensive API for reading and validating in app receipt and related purchases.

#### Initializing Receipt

```swift
do {
  /// Initialize receipt
  let receipt = try InAppReceipt.localReceipt() 
  
  // let receiptData: Data = ...
  // let receipt = try InAppReceipt.receipt(from: receiptData)
  
} catch {
  print(error)
}


```

#### Reading Receipt

```swift
/// Base64 Encoded Receipt
let base64Receipt = receipt.base64
  
/// Initialize receipt
let receipt = try! InAppReceipt.localReceipt() 

/// Check whether receipt contains any purchases
let hasPurchases = receipt.hasPurchases

/// All auto renewable `InAppPurchase`s,
let purchases: [InAppPurchase] = receipt.autoRenewablePurchases: 

/// all ACTIVE auto renewable `InAppPurchase`s,
let activePurchases: [InAppPurchase] = receipt.activeAutoRenewableSubscriptionPurchases: 

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

#### Validating Receipt

```swift

/// Verify all at once

do {
    try r.verify()
} catch IARError.validationFailed(reason: .hashValidation) 
{
    // Do smth
} catch IARError.validationFailed(reason: .bundleIdentifierVefirication) 
{
    // Do smth
} catch IARError.validationFailed(reason: .signatureValidation) 
{
    // Do smth
} catch {
    // Do smth
}

/// Verify hash 
try? r.verifyHash()

/// Verify bundle identifier and version
try? r.verifyBundleIdentifierAndVersion()

/// Verify signature
try? r.verifySignature()

```

## Essential Reading
* [Apple - About Receipt Validation](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Introduction.html)
* [Apple - Receipt Validation Programming Guide](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1)
* [Apple - Validating Receipts Locally](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateLocally.html)
* [objc.io - Receipt Validation](https://www.objc.io/issues/17-security/receipt-validation/)

## License

TPInAppReceipt is released under an MIT license. See [LICENSE](https://github.com/tikhop/TPInAppReceipt/blob/master/LICENSE) for more information.
