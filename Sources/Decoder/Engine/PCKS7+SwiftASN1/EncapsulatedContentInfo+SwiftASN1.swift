import SwiftASN1

/// ``CMSEncapsulatedContentInfo`` is defined in ASN.1 as:
/// ```
/// EncapsulatedContentInfo ::= SEQUENCE {
///   eContentType ContentType,
///   eContent [0] EXPLICIT OCTET STRING OPTIONAL }
/// ContentType ::= OBJECT IDENTIFIER
/// ```
///
extension EncapsulatedContentInfo: DERParseable where C: BERImplicitlyTaggable {}
extension EncapsulatedContentInfo: DERSerializable where C: BERImplicitlyTaggable {}
extension EncapsulatedContentInfo: DERImplicitlyTaggable where C: BERImplicitlyTaggable {}
extension EncapsulatedContentInfo: BERParseable where C: BERImplicitlyTaggable {}
extension EncapsulatedContentInfo: BERSerializable where C: BERImplicitlyTaggable {}
extension EncapsulatedContentInfo: BERImplicitlyTaggable where C: BERImplicitlyTaggable {
    @inlinable
    public static var defaultIdentifier: ASN1Identifier {
        .sequence
    }

    @inlinable
    public init(berEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try BER.sequence(rootNode, identifier: identifier) { nodes in
            let eContentType = try ASN1ObjectIdentifier(berEncoded: &nodes)
            let eContentRaw = try BER.optionalExplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) {
                node in
                try ASN1OctetString(berEncoded: node)
            }

            guard let eContentRaw else {
                return .init(eContentType: eContentType)
            }
            let eContent = try C(berEncoded: eContentRaw.bytes)
            return .init(eContentType: eContentType, eContent: eContent, eContentRaw: eContentRaw)
        }
    }

    @inlinable
    public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        try self.init(berEncoded: rootNode, withIdentifier: identifier)
    }

    @inlinable
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(
            identifier: identifier,
            { coder in
                try coder.serialize(eContentType)
                if let eContent {
                    try coder.serialize(explicitlyTaggedWithTagNumber: 0, tagClass: .contextSpecific) { coder in
                        try coder.serialize(eContent)
                    }
                }
            }
        )
    }
}
