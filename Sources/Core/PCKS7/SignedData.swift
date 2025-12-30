#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import X509

/// A PKCS#7 SignedData structure.
///
/// SignedData is the ASN.1 structure defined in RFC 2315 that contains signed content,
/// certificates, and signer information.
public struct SignedData<C: Sendable & Hashable>: Hashable, Sendable {
    /// The version of the SignedData structure.
    public var version: Version

    /// The digest algorithms used by the signers.
    public var digestAlgorithms: [AlgorithmIdentifier]

    /// The content that is signed.
    public var encapContentInfo: EncapsulatedContentInfo<C>

    /// The X.509 certificates used for validation.
    public var certificates: [Certificate]

    /// The raw DER-encoded certificate data.
    public var certificatesRaw: [Data]

    /// The signer information and signatures.
    public var signerInfos: [SignerInfo]

    /// Creates a SignedData structure with the specified values.
    @inlinable
    public init(
        version: Version,
        digestAlgorithms: [AlgorithmIdentifier],
        encapContentInfo: EncapsulatedContentInfo<C>,
        certificates: [Certificate],
        certificatesRaw: [Data] = [],
        signerInfos: [SignerInfo]
    ) {
        self.version = version
        self.digestAlgorithms = digestAlgorithms
        self.encapContentInfo = encapContentInfo
        self.certificates = certificates
        self.certificatesRaw = certificatesRaw
        self.signerInfos = signerInfos
    }
}
