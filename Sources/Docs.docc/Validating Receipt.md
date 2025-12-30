# Validating a Receipt

Verify the authenticity and integrity of an App Store receipt.

## Default Validation

Runs four checks in parallel: certificate chain, signature, hash, and metadata.

```swift
let result = await receipt.validate()

switch result {
case .valid:
    break
case .invalid(let error):
    print(error)
}
```

The validator auto-selects the Apple root certificate based on the receipt's environment.

## Custom Validators

Build your own with `@VerifierBuilder`:

```swift
let validator = ReceiptValidator {
    X509ChainVerifier(rootCertificates: [rootCert])
    SignatureVerifier()
    HashVerifier(deviceIdentifier: deviceId)
    MetaVerifier(
        appVersionProvider: { Bundle.main.appVersion },
        bundleIdentifierProvider: { Bundle.main.bundleIdentifier }
    )
}

let result = await validator.validate(receipt)
```

Include or exclude any verifier. They run in parallel via `TaskGroup` — if any fails, the rest are cancelled.

## Built-in Verifiers

| Verifier | What it checks |
|----------|---------------|
| `X509ChainVerifier` | Certificate chain against Apple root (swift-certificates) |
| `SecChainVerifier` | Certificate chain via Security.framework |
| `SignatureVerifier` | PKCS#7 signature (swift-crypto) |
| `SecSignatureVerifier` | PKCS#7 signature via Security.framework |
| `HashVerifier` | SHA-1 hash: device ID + opaque value + bundle ID |
| `MetaVerifier` | Bundle identifier and app version match |

`X509`/`Signature` variants are async. `Sec` variants use Security.framework and work in blocking contexts.

## Error Types

- ``ReceiptValidatorError`` — invalid structure, missing root certificate, missing device identifier
- ``ChainVerificationError`` — certificate data invalid, chain validation failed, revocation check failed
- ``SignatureVerificationError`` — invalid key, invalid signature
- ``HashVerificationError`` — missing device identifier, hash mismatch
- ``MetaVerificationError`` — bundle identifier mismatch, version mismatch

See <doc:Architecture> for how the validation layer fits into the overall design.
