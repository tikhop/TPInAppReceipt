import SwiftASN1

/// ContentInfo ::= SEQUENCE {
///   contentType ContentType,
///   content [0] EXPLICIT ANY DEFINED BY contentType OPTIONAL }
///
/// ContentType ::= OBJECT IDENTIFIER

extension ContentInfo: DERParseable where D: BERImplicitlyTaggable {}
extension ContentInfo: DERSerializable where D: BERImplicitlyTaggable {}
extension ContentInfo: DERImplicitlyTaggable where D: BERImplicitlyTaggable {}
extension ContentInfo: BERParseable where D: BERImplicitlyTaggable {}
extension ContentInfo: BERSerializable where D: BERImplicitlyTaggable {}
extension ContentInfo: BERImplicitlyTaggable where D: BERImplicitlyTaggable {
    @inlinable
    public static var defaultIdentifier: ASN1Identifier {
        .sequence
    }

    @inlinable
    public init(berEncoded node: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try BER.sequence(node, identifier: identifier) { nodes in
            let contentType = try ContentType(berEncoded: &nodes)

            let content = try BER.explicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { node in
                try D(berEncoded: node)
            }

            return .init(contentType: contentType, content: content)
        }
    }

    @inlinable
    public init(derEncoded node: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        try self.init(berEncoded: node, withIdentifier: identifier)
    }

    @inlinable
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.contentType)
            try coder.serialize(self.content)
        }
    }
}
