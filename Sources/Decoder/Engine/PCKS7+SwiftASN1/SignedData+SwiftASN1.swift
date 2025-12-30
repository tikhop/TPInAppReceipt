#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import SwiftASN1
import X509

/// ``SignedData`` is defined in ASN.1 as:
/// ```
/// SignedData ::= SEQUENCE {
///   version CMSVersion,
///   digestAlgorithms DigestAlgorithmIdentifiers,
///   encapContentInfo EncapsulatedContentInfo,
///   certificates [0] IMPLICIT CertificateSet OPTIONAL,
///   crls [1] IMPLICIT RevocationInfoChoices OPTIONAL,
///   signerInfos SignerInfos }
///
/// DigestAlgorithmIdentifiers ::= SET OF DigestAlgorithmIdentifier
/// DigestAlgorithmIdentifier ::= AlgorithmIdentifier
/// SignerInfos ::= SET OF SignerInfo
/// CertificateSet ::= SET OF CertificateChoices
///
/// CertificateChoices ::= CHOICE {
///  certificate Certificate,
///  extendedCertificate [0] IMPLICIT ExtendedCertificate, -- Obsolete
///  v1AttrCert [1] IMPLICIT AttributeCertificateV1,       -- Obsolete
///  v2AttrCert [2] IMPLICIT AttributeCertificateV2,
///  other [3] IMPLICIT OtherCertificateFormat }
///
/// OtherCertificateFormat ::= SEQUENCE {
///   otherCertFormat OBJECT IDENTIFIER,
///   otherCert ANY DEFINED BY otherCertFormat }
/// ```
/// - Note: At the moment we don't support `crls` (`RevocationInfoChoices`)
///
extension SignedData: DERParseable where C: BERImplicitlyTaggable {}
extension SignedData: DERSerializable where C: BERImplicitlyTaggable {}
extension SignedData: DERImplicitlyTaggable where C: BERImplicitlyTaggable {}
extension SignedData: BERParseable where C: BERImplicitlyTaggable {}
extension SignedData: BERSerializable where C: BERImplicitlyTaggable {}
extension SignedData: BERImplicitlyTaggable where C: BERImplicitlyTaggable {
    @inlinable
    public static var defaultIdentifier: SwiftASN1.ASN1Identifier {
        .sequence
    }

    @inlinable
    public init(berEncoded: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try BER.sequence(berEncoded, identifier: identifier) { nodes in
            let version = try Version(rawValue: Int(berEncoded: &nodes))
            let digestAlgorithms = try BER.set(of: AlgorithmIdentifier.self, identifier: .set, nodes: &nodes)

            let encapContentInfo = try EncapsulatedContentInfo<C>(berEncoded: &nodes)
            var certificatesRaw: [Data] = []
            let certificates = try BER.optionalImplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) {
                node in
                try BER.set(node, identifier: .init(tagWithNumber: 0, tagClass: .contextSpecific)) { iter in
                    var res: [Certificate] = []
                    while let next = iter.next() {
                        try res.append(Certificate(derEncoded: next))
                        certificatesRaw.append(Data(next.encodedBytes))
                    }
                    return res
                }
            }

            // we need to skip this node even though we don't support it
            _ = BER.optionalImplicitlyTagged(&nodes, tagNumber: 1, tagClass: .contextSpecific) { _ in }

            let signerInfos = try BER.set(of: SignerInfo.self, identifier: .set, nodes: &nodes)

            return .init(
                version: version,
                digestAlgorithms: digestAlgorithms,
                encapContentInfo: encapContentInfo,
                certificates: certificates ?? [],
                certificatesRaw: certificatesRaw,
                signerInfos: signerInfos
            )
        }
    }

    @inlinable
    public init(derEncoded: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        try self.init(berEncoded: derEncoded, withIdentifier: identifier)
    }

    @inlinable
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws
    {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(version.rawValue)
            try coder.serializeSetOf(self.digestAlgorithms)
            try coder.serialize(self.encapContentInfo)
            if !certificates.isEmpty {
                try coder.serializeSetOf(certificates, identifier: .init(tagWithNumber: 0, tagClass: .contextSpecific))
            }
            try coder.serializeSetOf(self.signerInfos, identifier: .set)
        }
    }
}
