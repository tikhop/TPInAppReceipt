import SwiftASN1

/// A PKCS#7 Attribute structure.
///
/// An attribute contains a type identifier and associated values.
public struct Attribute: Hashable, Sendable {
    /// The object identifier of the attribute type.
    public var attrType: ASN1ObjectIdentifier

    /// The attribute values.
    public var attrValues: [ASN1Any]

    /// Creates an Attribute with the specified type and values.
    @inlinable
    public init(attrType: ASN1ObjectIdentifier, attrValues: [ASN1Any]) {
        self.attrType = attrType
        self.attrValues = attrValues
    }
}
