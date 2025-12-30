import SwiftASN1

/// A PKCS#7 EncapsulatedContentInfo structure.
///
/// EncapsulatedContentInfo contains the type and value of the content being protected.
public struct EncapsulatedContentInfo<C: Sendable & Hashable>: Hashable, Sendable {
    /// The object identifier of the content type.
    public var eContentType: ASN1ObjectIdentifier

    /// The decoded content.
    public var eContent: C?

    /// The raw DER-encoded content.
    public var eContentRaw: ASN1OctetString?

    /// Creates an EncapsulatedContentInfo with the specified type and content.
    @inlinable
    public init(
        eContentType: ASN1ObjectIdentifier,
        eContent: C? = nil,
        eContentRaw: ASN1OctetString? = nil
    ) {
        self.eContentType = eContentType
        self.eContent = eContent
        self.eContentRaw = eContentRaw
    }
}
