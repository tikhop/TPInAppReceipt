#if canImport(Security)

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

@preconcurrency import Security
import X509

// MARK: - "Legacy" Chain Verifier

public struct SecChainVerifier: ReceiptChainVerifier, Sendable {
    private let rootCertificates: [SecCertificate]

    public init(rootCertificates: [Data]) throws {
        var rootSecCertificates: [SecCertificate] = []
        for cert in rootCertificates {
            guard let cert = SecCertificateCreateWithData(nil, cert as CFData) else {
                throw ChainVerificationError.invalidCertificateData
            }
            rootSecCertificates.append(cert)
        }

        self.rootCertificates = rootSecCertificates
    }

    func verify(
        leaf: SecCertificate,
        intermediate: [SecCertificate],
        policy: [ReceiptChainVerifierPolicy]
    ) -> VerificationResult {
        var trust: SecTrust?

        var certificates: [SecCertificate] = [leaf]
        certificates.append(contentsOf: intermediate)

        let status = SecTrustCreateWithCertificates(certificates as CFArray, nil, &trust)
        guard status == errSecSuccess, let trustRef = trust else {
            return .invalid(ChainVerificationError.chainValidationFailed)
        }

        // Set anchor certificates and use only these anchors (not system roots)
        guard SecTrustSetAnchorCertificates(trustRef, rootCertificates as CFArray) == errSecSuccess else {
            return .invalid(ChainVerificationError.chainValidationFailed)
        }

        guard SecTrustSetAnchorCertificatesOnly(trustRef, true) == errSecSuccess else {
            return .invalid(ChainVerificationError.chainValidationFailed)
        }

        var secPolicies: [SecPolicy] = []

        for p in policy {
            if let secPolicy = p.policy {
                secPolicies.append(secPolicy)
            } else if case let .validationTime(data) = p {
                if SecTrustSetVerifyDate(trustRef, data as CFDate) != errSecSuccess {
                    return .invalid(ChainVerificationError.chainValidationFailed)
                }
            }
        }

        guard !secPolicies.isEmpty else {
            return .invalid(ChainVerificationError.chainValidationFailed)
        }

        guard SecTrustSetPolicies(trustRef, secPolicies as CFArray) == errSecSuccess else {
            return .invalid(ChainVerificationError.chainValidationFailed)
        }

        var error: CFError?
        let trusted = SecTrustEvaluateWithError(trustRef, &error)

        guard trusted && error == nil else {
            return .invalid(ChainVerificationError.chainValidationFailed)
        }

        return .valid
    }

    public func verify(
        leaf: Certificate,
        intermediate: [Certificate],
        policy: [ReceiptChainVerifierPolicy]
    ) -> VerificationResult {
        do {
            let leaf = try SecCertificate.makeWithCertificate(leaf)
            let intermediate = try intermediate.map { try SecCertificate.makeWithCertificate($0) }

            return verify(
                leaf: leaf,
                intermediate: intermediate,
                policy: policy
            )
        } catch {
            return .invalid(ChainVerificationError.invalidCertificateData)
        }
    }
}

extension SecChainVerifier: ReceiptVerifier {
    public func verify(_ receipt: any ReceiptValidatable) -> VerificationResult {
        guard let leaf = receipt.leafCertificate else {
            return .invalid(ChainVerificationError.invalidCertificateData)
        }

        return verify(
            leaf: leaf,
            intermediate: receipt.intermediateCertificates,
            policy: receipt.verificationPolicy
        )
    }
}

extension ReceiptChainVerifierPolicy {
    fileprivate var policy: SecPolicy? {
        switch self {
        case .appleX509Basic:
            return SecPolicyCreateWithProperties(kSecPolicyAppleX509Basic, nil)
        case .appStoreReceipt:
            return SecPolicyCreateWithProperties(kSecPolicyMacAppStoreReceipt, nil)
        case .validationTime:
            return nil
        case .onlineValidationTime:
            let revocationOptions: [CFString: Any] = [
                kSecPolicyRevocationFlags: kSecRevocationOCSPMethod | kSecRevocationCRLMethod
            ]

            return SecPolicyCreateWithProperties(
                kSecPolicyAppleRevocation,
                revocationOptions as CFDictionary
            )
        }
    }
}

#endif
