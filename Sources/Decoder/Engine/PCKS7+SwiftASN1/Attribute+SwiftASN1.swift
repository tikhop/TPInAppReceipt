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

/// ``CMSAttribute`` is defined in ASN.1 as:
/// ```
/// Attribute ::= SEQUENCE {
///     attrType OBJECT IDENTIFIER,
///     attrValues SET OF AttributeValue }
///
/// AttributeValue ::= ANY
/// ```
extension Attribute: DERImplicitlyTaggable, BERImplicitlyTaggable {
    @inlinable
    public static var defaultIdentifier: ASN1Identifier {
        .sequence
    }

    @inlinable
    public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(rootNode, identifier: identifier) { nodes in
            let attrType = try ASN1ObjectIdentifier(derEncoded: &nodes)
            let attrValues = try DER.set(of: ASN1Any.self, identifier: .set, nodes: &nodes)

            return .init(attrType: attrType, attrValues: attrValues)
        }
    }

    @inlinable
    public init(berEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try BER.sequence(rootNode, identifier: identifier) { nodes in
            let attrType = try ASN1ObjectIdentifier(berEncoded: &nodes)
            let attrValues = try BER.set(of: ASN1Any.self, identifier: .set, nodes: &nodes)

            return .init(attrType: attrType, attrValues: attrValues)
        }
    }

    @inlinable
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.attrType)
            try coder.serializeSetOf(self.attrValues)
        }
    }
}
