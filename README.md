# TPInAppReceipt

A lightweight iOS library for reading and validating In-App Receipt.

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

OpenSSL is included as built by https://github.com/jasonacox/Build-OpenSSL-cURL

Usage
-------------

```
do {
  let receipt = try InAppReceiptManager.shared.receipt()
} catch {
  print(error)
}
```
