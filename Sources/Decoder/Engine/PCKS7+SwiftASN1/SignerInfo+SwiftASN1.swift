//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftCertificates open source project
//
// Copyright (c) 2023 Apple Inc. and the SwiftCertificates project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftCertificates project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import SwiftASN1

/// ``SignerInfo`` is defined in ASN.1 as:
/// ```
/// SignerInfo ::= SEQUENCE {
///   version CMSVersion,
///   sid SignerIdentifier,
///   digestAlgorithm DigestAlgorithmIdentifier,
///   signedAttrs [0] IMPLICIT SignedAttributes OPTIONAL,
///   signatureAlgorithm SignatureAlgorithmIdentifier,
///   signature SignatureValue,
///   unsignedAttrs [1] IMPLICIT UnsignedAttributes OPTIONAL }
///
/// SignatureValue ::= OCTET STRING
/// DigestAlgorithmIdentifier ::= AlgorithmIdentifier
/// SignatureAlgorithmIdentifier ::= AlgorithmIdentifier
/// ```
/// - Note: If the `SignerIdentifier` is the CHOICE `issuerAndSerialNumber`,
/// then the `version` MUST be 1.  If the `SignerIdentifier` is `subjectKeyIdentifier`,
/// then the `version` MUST be 3.
///
extension SignerInfo: DERImplicitlyTaggable, BERImplicitlyTaggable {
    @inlinable
    public static var defaultIdentifier: ASN1Identifier {
        .sequence
    }

    @inlinable
    public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(rootNode, identifier: identifier) { nodes in
            let version = try Version(rawValue: Int(derEncoded: &nodes))
            let signerIdentifier = try SignerIdentifier(derEncoded: &nodes)
            switch signerIdentifier {
            case .issuerAndSerialNumber:
                guard version == .v1 else {
                    throw Error.versionAndSignerIdentifierMismatch(
                        "expected \(Version.v1) but got \(version) where signerIdentifier is \(signerIdentifier)"
                    )
                }
            case .subjectKeyIdentifier:
                guard version == .v3 else {
                    throw Error.versionAndSignerIdentifierMismatch(
                        "expected \(Version.v3) but got \(version) where signerIdentifier is \(signerIdentifier)"
                    )
                }
            }
            let digestAlgorithm = try AlgorithmIdentifier(derEncoded: &nodes)

            let signedAttrs = try DER.optionalImplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) {
                node in
                try DER.set(
                    of: Attribute.self,
                    identifier: .init(tagWithNumber: 0, tagClass: .contextSpecific),
                    rootNode: node
                )
            }

            let signatureAlgorithm = try AlgorithmIdentifier(derEncoded: &nodes)
            let signature = try ASN1OctetString(derEncoded: &nodes)

            let unsignedAttrs = try DER.optionalImplicitlyTagged(&nodes, tagNumber: 1, tagClass: .contextSpecific) {
                node in
                try DER.set(
                    of: Attribute.self,
                    identifier: .init(tagWithNumber: 0, tagClass: .contextSpecific),
                    rootNode: node
                )
            }

            return .init(
                version: version,
                signerIdentifier: signerIdentifier,
                digestAlgorithm: digestAlgorithm,
                signedAttrs: signedAttrs,
                signatureAlgorithm: signatureAlgorithm,
                signature: signature,
                unsignedAttrs: unsignedAttrs
            )
        }
    }

    @inlinable
    public init(berEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try BER.sequence(rootNode, identifier: identifier) { nodes in
            let version = try Version(rawValue: Int(derEncoded: &nodes))
            let signerIdentifier = try SignerIdentifier(berEncoded: &nodes)
            switch signerIdentifier {
            case .issuerAndSerialNumber:
                guard version == .v1 else {
                    throw Error.versionAndSignerIdentifierMismatch(
                        "expected \(Version.v1) but got \(version) where signerIdentifier is \(signerIdentifier)"
                    )
                }
            case .subjectKeyIdentifier:
                guard version == .v3 else {
                    throw Error.versionAndSignerIdentifierMismatch(
                        "expected \(Version.v3) but got \(version) where signerIdentifier is \(signerIdentifier)"
                    )
                }
            }
            let digestAlgorithm = try AlgorithmIdentifier(berEncoded: &nodes)

            // SignedAttrs MUST be in DER: https://datatracker.ietf.org/doc/html/rfc5652#section-2
            let signedAttrs = try DER.optionalImplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) {
                node in
                try DER.set(
                    of: Attribute.self,
                    identifier: .init(tagWithNumber: 0, tagClass: .contextSpecific),
                    rootNode: node
                )
            }

            let signatureAlgorithm = try AlgorithmIdentifier(berEncoded: &nodes)
            let signature = try ASN1OctetString(berEncoded: &nodes)

            let unsignedAttrs = try BER.optionalImplicitlyTagged(&nodes, tagNumber: 1, tagClass: .contextSpecific) {
                node in
                try BER.set(
                    of: Attribute.self,
                    identifier: .init(tagWithNumber: 0, tagClass: .contextSpecific),
                    rootNode: node
                )
            }

            return .init(
                version: version,
                signerIdentifier: signerIdentifier,
                digestAlgorithm: digestAlgorithm,
                signedAttrs: signedAttrs,
                signatureAlgorithm: signatureAlgorithm,
                signature: signature,
                unsignedAttrs: unsignedAttrs
            )
        }
    }

    @inlinable
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.version.rawValue)
            try coder.serialize(self.signerIdentifier)
            try coder.serialize(self.digestAlgorithm)
            if let signedAttrs = self.signedAttrs {
                try coder.serializeSetOf(signedAttrs, identifier: .init(tagWithNumber: 0, tagClass: .contextSpecific))
            }
            try coder.serialize(self.signatureAlgorithm)
            try coder.serialize(self.signature)
            if let unsignedAttrs = self.unsignedAttrs {
                try coder.serializeSetOf(unsignedAttrs, identifier: .init(tagWithNumber: 1, tagClass: .contextSpecific))
            }
        }
    }
}

// MARK: - Attribute Getters

extension Array where Element == Attribute {
    @inlinable
    subscript(oid: ASN1ObjectIdentifier) -> Attribute? {
        if let attr = first(where: { $0.attrType == oid }) {
            return attr
        }
        return nil
    }
}

extension ASN1ObjectIdentifier {
    @usableFromInline
    static let messageDigest: Self = [1, 2, 840, 113_549, 1, 9, 4]

    @usableFromInline
    static let signingTime: Self = [1, 2, 840, 113_549, 1, 9, 5]

    @usableFromInline
    static let contentType: Self = [1, 2, 840, 113_549, 1, 9, 3]
}
