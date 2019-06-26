[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/TPInAppReceipt.svg)](https://img.shields.io/cocoapods/v/TPInAppReceipt.svg)
[![Platform](https://img.shields.io/cocoapods/p/TPInAppReceipt.svg?style=flat)]()
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/tikhop/TPInAppReceipt/master/LICENSE)
# TPInAppReceipt

A lightweight iOS library for reading and validating Apple In-App Receipt.

## Features

- [x] Extract all In-App Receipt Attributes
- [x] Hash Verification
- [x] Signature Verification
- [ ] Verify Version and Bundle Identifiers

Installation
------------

### CocoaPods

To integrate TPInAppReceipt into your project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '9.0'

target 'YOUR_TARGET' do
    use_frameworks!

    pod 'TPInAppReceipt'
    pod 'TPInAppReceipt/SignatureVerification' //If you want to validate receipt's certificates 
end

```

Then, run the following command:

```bash
$ pod install
```

### Requirements

- iOS 9.0+ / OSX 10.11+
- Xcode 8.0+
- Swift 5.0+

### Openssl (Only for `TPInAppReceipt/SignatureVerification`)

OpenSSL is included as a framework from https://github.com/krzyzanowskim/OpenSSL

Usage
-------------

### Working With a Receipt

```swift
do {
  let receipt = try InAppReceipt.localReceipt() 
  
  //let receiptData: Data = ...
  //let receipt = try InAppReceipt.receipt(from: receiptData)
} catch {
  print(error)
}
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

#### In App Receipt Hash Validation

```swift
do {
    try r.verifyHash()
} catch ReceiptValidatorError.hashValidationFaied {
    // Do smth
} catch {
    // Do smth
}
```

### Receipt Validation (Only for TPInAppReceipt/SignatureVerification pod)

```swift
do {
    try r.verify()
} catch ReceiptValidatorError.hashValidationFaied {
    // Do smth
} catch ReceiptValidatorError.receiptSignatureVerificationFailed {
    // Do smth
} catch {
    // Do smth
}
```

In the above example, the validation process goes through the all verification steps. First, it verifies signature and make sure that it's valid. Second, it makes the hash validation by computing the hash of the GUID and matching with receipt's hash.

#### Signature Validation

```swift
do {
    try r.verifySignature()
} catch {
    // Do smth
}
```
