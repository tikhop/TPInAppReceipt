import SwiftASN1
import X509

/// ``IssuerAndSerialNumber`` is defined in ASN.1 as:
/// ```
/// IssuerAndSerialNumber ::= SEQUENCE {
///         issuer Name,
///         serialNumber CertificateSerialNumber }
/// ```
/// The definition of `Name` is taken from X.501 [X.501-88], and the
/// definition of `CertificateSerialNumber` is taken from X.509 [X.509-97].
///

extension IssuerAndSerialNumber: DERImplicitlyTaggable {
    @inlinable
    public static var defaultIdentifier: ASN1Identifier {
        .sequence
    }

    @inlinable
    public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(rootNode, identifier: identifier) { nodes in
            let issuer = try DistinguishedName.derEncoded(&nodes)
            let serialNumber = try ArraySlice<UInt8>(derEncoded: &nodes)
            return .init(issuer: issuer, serialNumber: .init(bytes: serialNumber))
        }
    }

    @inlinable
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.issuer)
            try coder.serialize(self.serialNumber.bytes)
        }
    }
}

extension DistinguishedName {
    @inlinable
    static func derEncoded(_ sequenceNodeIterator: inout ASN1NodeCollection.Iterator) throws -> DistinguishedName {
        // This is a workaround for the fact that, even though the conformance to DERImplicitlyTaggable is
        // deprecated, Swift still prefers calling init(derEncoded:withIdentifier:) instead of this one.
        let dnFactory: (inout ASN1NodeCollection.Iterator) throws -> DistinguishedName =
            DistinguishedName.init(derEncoded:)
        return try dnFactory(&sequenceNodeIterator)
    }
}
