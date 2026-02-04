#if canImport(Security)

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

@preconcurrency import Security
import SwiftASN1
import X509

public struct SecSignatureVerifier {
    public init() {}

    public func verify(
        key: Data,
        algorithm: DigestAlgorithm,
        signedData: Data,
        signature: Data
    ) -> VerificationResult {
        let keyDict: [String: Any] = [
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
        ]

        guard
            let publicKeySec = SecKeyCreateWithData(
                key as CFData,
                keyDict as CFDictionary,
                nil
            )
        else {
            return .invalid(SignatureVerificationError.invalidKey)
        }

        var umErrorCF: Unmanaged<CFError>? = nil
        guard
            SecKeyVerifySignature(
                publicKeySec,
                algorithm.secKeyAlgorithm,
                signedData as CFData,
                signature as CFData,
                &umErrorCF
            )
        else {
            return .invalid(SignatureVerificationError.invalidSignature)
        }

        return .valid
    }
}

extension SecSignatureVerifier: ReceiptVerifier {
    public func verify(_ receipt: any ReceiptValidatable) -> VerificationResult {
        guard let publicKey = receipt.publicKey,
            let key = try? Data(publicKey.intoBytes())
        else {
            return .invalid(SignatureVerificationError.invalidKey)
        }

        return verify(
            key: key,
            algorithm: receipt.digestAlgorithm,
            signedData: receipt.digestData,
            signature: receipt.signature
        )
    }
}

extension DigestAlgorithm {
    fileprivate var secKeyAlgorithm: SecKeyAlgorithm {
        switch self {
        case .sha1:
            return .rsaSignatureMessagePKCS1v15SHA1
        case .sha256:
            return .rsaSignatureMessagePKCS1v15SHA256
        }
    }
}

extension DERSerializable {
    func intoBytes() throws -> Data {
        var serializer = DER.Serializer()
        try serializer.serialize(self)
        return Data(serializer.serializedBytes)
    }
}
#endif
