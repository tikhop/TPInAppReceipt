# Blocking Mode

Synchronous API for contexts where async is not available.

## Usage

```swift
@_spi(Blocking) import TPInAppReceipt

let receipt = try AppReceipt.local_blocking
let result = receipt.validate_blocking()
```

## How It Differs

The blocking validator uses Security.framework verifiers (`SecChainVerifier`, `SecSignatureVerifier`) instead of the async swift-certificates/swift-crypto ones. Hash and metadata verification are the same.

Blocking validation runs verifiers sequentially, not in parallel.
