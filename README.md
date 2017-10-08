[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/TPInAppReceipt.svg)](https://img.shields.io/cocoapods/v/TPInAppReceipt.svg)
[![Platform](https://img.shields.io/cocoapods/p/TPInAppReceipt.svg?style=flat)]()
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/tikhop/TPInAppReceipt/master/LICENSE)
# TPInAppReceipt

A lightweight iOS library for reading and validating In-App Receipt.

## Features

- [x] Parse the Payload and Extract the Receipt Attributes
- [x] Hash Verification
- [x] Verify the Receipt Signature
- [ ] Verify Version and Bundle Identifiers

Installation
------------

### CocoaPods

> CocoaPods 1.1.0.rc.2 is required to build MAPSDK.

To integrate TPInAppReceipt into your project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '8.3'

target 'YOUR_TARGET' do
    use_frameworks!

    pod 'TPInAppReceipt'
end

```

Then, run the following command:

```bash
$ pod install
```

### Requirements

- iOS 8.3+
- Xcode 8.0+
- Swift 3.0+

### Openssl

OpenSSL is included as a built by https://github.com/jasonacox/Build-OpenSSL-cURL

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

### Receipt Validation

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

#### Hash Validation

```swift
do {
    try r.verifyHash()
} catch ReceiptValidatorError.hashValidationFaied {
    // Do smth
} catch {
    // Do smth
}
```

#### Signature Validation

```swift
do {
    try r.verifySignature()
} catch {
    // Do smth
}
```
