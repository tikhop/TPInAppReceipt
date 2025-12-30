#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import SwiftASN1
import X509
import Crypto
import _CryptoExtras


public final class SignatureVerifier: ReceiptSignatureVerifier {
    public func verify(
        key: Certificate.PublicKey,
        algorithm: DigestAlgorithm,
        signedData: Data,
        signature: Data
    ) -> VerificationResult {
        let isValid = key.isValidSignature(
            signature,
            for: signedData,
            signatureAlgorithm: algorithm.signatureAlgorithm
        )

        return isValid ? .valid : .invalid(SignatureVerificationError.invalidSignature)
    }
}

extension SignatureVerifier: ReceiptVerifier {
    public func verify(_ receipt: ReceiptValidatable) -> VerificationResult {
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


fileprivate extension DigestAlgorithm {
    var signatureAlgorithm: Certificate.SignatureAlgorithm {
        switch self {
        case .sha1:
            return .sha1WithRSAEncryption
        case .sha256:
            return .sha256WithRSAEncryption
        @unknown default:
            fatalError("Unhandled case")
        }
    }
}

extension SignerInfo {
    var validationSignatureAlgorithm: Certificate.SignatureAlgorithm {
        switch (digestAlgorithm.algorithm, signatureAlgorithm.algorithm) {
            case (.AlgorithmIdentifier.sha1, .AlgorithmIdentifier.rsaEncryption):
            return .sha1WithRSAEncryption
        case (.AlgorithmIdentifier.sha256, .AlgorithmIdentifier.rsaEncryption):
            return .sha256WithRSAEncryption
        default:
            fatalError("Wrong signature algorithm")
        }
    }
}
