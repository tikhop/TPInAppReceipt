[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/TPInAppReceipt.svg)](https://img.shields.io/cocoapods/v/TPInAppReceipt.svg)
[![Platform](https://img.shields.io/cocoapods/p/TPInAppReceipt.svg?style=flat)]()
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/tikhop/TPInAppReceipt/master/LICENSE)
# TPInAppReceipt

A lightweight iOS/OSX library for reading and validating Apple In-App Receipt locally.

## Features

- [x] Extract all In-App Receipt Attributes
- [x] Hash Verification
- [x] Verify Bundle Version and Identifiers
- [x] No More Openssl
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

### Requirements

- iOS 9.0+ / OSX 10.11+
- Swift 5.0+

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
