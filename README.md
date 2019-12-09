<p align="center">
  <img height="160" src="https://ucb12bed9ca2dd405ac9cfb1627a.previews.dropboxusercontent.com/p/thumb/AAornRdeKaqkww9YgqVWhoytoVkzA8Xr4H7RxSwMQ1aHrbIEUXqlhiRrc-zrMpGf1a5h7-UD75E5AZkSfS4oddVCakHUgdBgfMXmf1iw6BvTMU0mM7LjXhU6LLsiG1FrQgavpWD5aGarAMnjT5GoHLLVitpNT-RLscUmoWk0toOlhANGEmMxzMdsSSb-VAcutAybVmlRVMtQBohy35FR7oEyTYyRB6UmrcOAtaAzojVTwu5w4osCVjUi8FiLvJX55IiKLsJcRbBHqiCr-H0x3VxxUdUcgG1Dl32Vich6zAJ4_fJRLX3ULQD_PF8mnV4JjiT-Cgoam0SDkewgpZ0gT6etW8KFyO1wpWzBexz-W4R7gHVKz1_Zw2ujI-w_dhcPWtnIZJ50RBqk4Cuv4bxbsWwx/p.png?fv_content=true&size_mode=5" />
</p>


# TPInAppReceipt

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/TPInAppReceipt.svg)](https://cocoapods.org/pods/TPInAppReceipt)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/cocoapods/p/TPInAppReceipt.svg?style=flat)]()
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/tikhop/TPInAppReceipt/master/LICENSE)

A lightweight iOS/OSX library for reading and validating Apple In-App Receipt locally.

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
} catch IARError.validationFailed(reason: .hashValidation) {
    // Do smth
} catch {
    // Do smth
}
```

## License

TPInAppReceipt is released under an MIT license. See [LICENSE](https://github.com/tikhop/TPInAppReceipt/blob/master/LICENSE) for more information.
