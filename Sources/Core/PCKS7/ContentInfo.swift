import SwiftASN1

/// A PKCS#7 ContentInfo structure.
///
/// ContentInfo is a simple wrapper that associates content with a content type identifier.
public struct ContentInfo<D: Sendable>: Sendable {
    /// A type alias for the content type identifier.
    public typealias ContentType = ASN1ObjectIdentifier

    /// The object identifier of the content type.
    public let contentType: ContentType

    /// The content data.
    public let content: D

    /// Creates a ContentInfo with the specified type and content.
    @inlinable
    public init(contentType: ContentType, content: D) {
        self.contentType = contentType
        self.content = content
    }
}
