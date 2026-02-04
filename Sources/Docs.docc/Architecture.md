# Architecture

How the library is structured and where to plug in custom implementations.

## Overview

The library has three layers: **Core** (data models), **Decoder** (parsing), and **Validator** (verification). Both Decoder and Validator are pluggable.

```
┌──────────────────────────────────────────────┐
│              Public API                      │
│         AppReceipt extensions                │
├──────────────────────────────────────────────┤
│                                              │
│  ┌─────────────┐  ┌──────────────────────┐   │
│  │   Decoder   │  │     Validator        │   │
│  │             │  │                      │   │
│  │  Engine     │  │  ReceiptValidator    │   │
│  │  protocol   │  │  @VerifierBuilder    │   │
│  │             │  │                      │   │
│  │  SwiftASN1  │  │  X509ChainVerifier   │   │
│  │  (default)  │  │  SignatureVerifier   │   │
│  │             │  │  HashVerifier        │   │
│  │             │  │  MetaVerifier        │   │
│  │             │  │                      │   │
│  └─────────────┘  └──────────────────────┘   │
│                                              │
├──────────────────────────────────────────────┤
│                  Core                        │
│                                              │
│  ContentInfo<SignedData<InAppReceiptPayload>>│
│  InAppPurchase, SignerInfo, etc.             │
│                                              │
│  PKCS#7 types: ContentInfo, SignedData,      │
│  EncapsulatedContentInfo, SignerInfo,        │
│  AlgorithmIdentifier, Attribute, Version     │
└──────────────────────────────────────────────┘
```

## Core

`AppReceipt` is a typealias:

```swift
public typealias AppReceipt = ContentInfo<SignedData<InAppReceiptPayload>>
```

The generic PKCS#7 types (`ContentInfo`, `SignedData`, `EncapsulatedContentInfo`, `SignerInfo`, etc.) model the full ASN.1 structure. `InAppReceiptPayload` and `InAppPurchase` hold the decoded receipt data.

All types are `Sendable` and `Hashable`.

## Decoder

```
┌──────────────────┐
│ AppReceiptDecoder│
│                  │
│  engine: Engine  │───▶ Protocol
└──────────────────┘
         │
         ▼
┌──────────────────────────┐
│ SwiftASN1ReceiptDecoder  │  (default)
│                          │
│ Uses swift-asn1 BER/DER  │
│ parsing + PKCS7+SwiftASN1│
│ extensions               │
└──────────────────────────┘
```

`AppReceiptDecoder` takes an `Engine` — a protocol with a single `decode(from:)` method. The default engine is `SwiftASN1ReceiptDecoder` which uses Apple's swift-asn1 for BER/DER parsing.

To use a custom decoder:

```swift
struct MyEngine: AppReceiptDecoder.Engine {
    func decode(from data: Data) throws -> AppReceipt {
        // custom parsing
    }
}

let decoder = AppReceiptDecoder(engine: MyEngine())
let receipt = try decoder.decode(from: data)
```

## Validator

```
┌──────────────────────┐
│  ReceiptValidator    │
│                      │
│  @VerifierBuilder    │
│  verifiers: [any     │
│   ReceiptVerifier]   │
└──────────┬───────────┘
           │
           │  TaskGroup (parallel)
           │
     ┌─────┼─────┬──────────┐
     ▼     ▼     ▼          ▼
  Chain  Sig   Hash      Meta
```

`ReceiptValidator` composes `ReceiptVerifier` conformances via `@VerifierBuilder`. Default validation runs four verifiers in parallel using `TaskGroup`. If any fails, the rest are cancelled.

### Implementing a Custom Verifier

```swift
struct MyVerifier: ReceiptVerifier {
    func verify(_ receipt: ReceiptValidatable) async -> VerificationResult {
        // custom check
        return .valid
    }
}

let validator = ReceiptValidator {
    X509ChainVerifier(rootCertificates: [rootCert])
    MyVerifier()
}
```

### Verifier Variants

Each verification concern has two implementations:

| Concern | Async (default) | Blocking (Security.framework) |
|---------|-----------------|-------------------------------|
| Chain   | `X509ChainVerifier` | `SecChainVerifier` |
| Signature | `SignatureVerifier` | `SecSignatureVerifier` |
| Hash | `HashVerifier` | `HashVerifier` (same) |
| Meta | `MetaVerifier` | `MetaVerifier` (same) |

The async variants use swift-certificates and swift-crypto. The `Sec` variants use Apple's Security.framework and are used in the blocking validation path.
