#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import _CryptoExtras
import Crypto
import SwiftASN1
import X509

public struct SignatureVerifier: ReceiptSignatureVerifier {
    public func verify(
        key: Certificate.PublicKey,
        algorithm: DigestAlgorithm,
        signedData: Data,
        signature: Data
    ) -> VerificationResult {
        guard let signatureAlgorithm = algorithm.signatureAlgorithm else {
            return .invalid(SignatureVerificationError.invalidSignature)
        }

        let isValid = key.isValidSignature(
            signature,
            for: signedData,
            signatureAlgorithm: signatureAlgorithm
        )

        return isValid ? .valid : .invalid(SignatureVerificationError.invalidSignature)
    }
}

extension SignatureVerifier: ReceiptVerifier {
    public func verify(_ receipt: any ReceiptValidatable) -> VerificationResult {
        guard let leaf = receipt.certificates.first else {
            return .invalid(SignatureVerificationError.invalidKey)
        }

        return verify(
            key: leaf.publicKey,
            algorithm: receipt.digestAlgorithm,
            signedData: receipt.digestData,
            signature: receipt.signature
        )
    }
}

extension DigestAlgorithm {
    fileprivate var signatureAlgorithm: Certificate.SignatureAlgorithm? {
        switch self {
        case .sha1:
            return .sha1WithRSAEncryption
        case .sha256:
            return .sha256WithRSAEncryption
        @unknown default:
            return nil
        }
    }
}
