# Use TPInAppReceipt in Objective-C project

Installation
------------

### CocoaPods

To integrate TPInAppReceipt into your Objective-C project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '9.0'

target 'YOUR_TARGET' do
use_frameworks!

pod 'TPInAppReceipt/Objc'
end

```

Then, run the following command:

```bash
$ pod install
```

In any swift file you'd like to use TPInAppReceipt, import the framework with `@import TPInAppReceipt;`.

### Swift Package Manager

To integrate using Apple's Swift package manager, add the following as a dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/tikhop/TPInAppReceipt.git", .upToNextMajor(from: "3.0.0"))
```

Then, specify `"TPInAppReceipt-Objc"` as a dependency of the Target in which you wish to use TPInAppReceipt.

Lastly, run the following command:
```swift
swift package update
```

Once you are done with SPM, you can import the framework with  `@import TPInAppReceipt_Objc;`.
