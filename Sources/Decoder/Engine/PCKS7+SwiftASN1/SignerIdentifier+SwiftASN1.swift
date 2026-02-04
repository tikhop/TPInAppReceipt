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

import SwiftASN1
import X509

/// ``SignerIdentifier`` is defined in ASN.1 as:
/// ```
/// SignerIdentifier ::= CHOICE {
///   issuerAndSerialNumber IssuerAndSerialNumber,
///   subjectKeyIdentifier [0] SubjectKeyIdentifier }
///  ```
///
extension SignerIdentifier: DERParseable, BERParseable, DERSerializable, BERSerializable {
    @usableFromInline
    static let skiIdentifier = ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific)

    @inlinable
    public init(derEncoded node: ASN1Node) throws {
        switch node.identifier {
        case IssuerAndSerialNumber.defaultIdentifier:
            self = try .issuerAndSerialNumber(.init(derEncoded: node))

        case Self.skiIdentifier:
            self = try .subjectKeyIdentifier(
                .init(
                    keyIdentifier: ASN1OctetString(
                        derEncoded: node,
                        withIdentifier: Self.skiIdentifier
                    ).bytes
                )
            )

        default:
            throw ASN1Error.unexpectedFieldType(node.identifier)
        }
    }

    @inlinable
    public func serialize(into coder: inout DER.Serializer) throws {
        switch self {
        case let .issuerAndSerialNumber(issuerAndSerialNumber):
            try issuerAndSerialNumber.serialize(into: &coder)

        case let .subjectKeyIdentifier(subjectKeyIdentifier):
            try ASN1OctetString(contentBytes: subjectKeyIdentifier.keyIdentifier)
                .serialize(into: &coder, withIdentifier: Self.skiIdentifier)
        }
    }
}
