import SwiftASN1

/// A PKCS#7 SignerInfo structure.
///
/// SignerInfo contains the signature and signer information for a piece of signed data.
public struct SignerInfo: Hashable, Sendable {
    /// Errors that occur in SignerInfo operations.
    public enum Error: Swift.Error {
        /// The version and signer identifier are incompatible.
        case versionAndSignerIdentifierMismatch(String)
    }

    /// The version of the SignerInfo structure.
    public var version: Version

    /// The identifier of the signer.
    public var signerIdentifier: SignerIdentifier

    /// The digest algorithm used by the signer.
    public var digestAlgorithm: AlgorithmIdentifier

    /// The signed attributes.
    public var signedAttrs: [Attribute]?

    /// The signature algorithm.
    public var signatureAlgorithm: AlgorithmIdentifier

    /// The signature value.
    public var signature: ASN1OctetString

    /// The unsigned attributes.
    public var unsignedAttrs: [Attribute]?

    /// Creates a SignerInfo with the specified values.
    @inlinable
    public init(
        version: Version,
        signerIdentifier: SignerIdentifier,
        digestAlgorithm: AlgorithmIdentifier,
        signedAttrs: [Attribute]? = nil,
        signatureAlgorithm: AlgorithmIdentifier,
        signature: ASN1OctetString,
        unsignedAttrs: [Attribute]? = nil
    ) {
        self.version = version
        self.signerIdentifier = signerIdentifier
        self.digestAlgorithm = digestAlgorithm
        self.signedAttrs = signedAttrs
        self.signatureAlgorithm = signatureAlgorithm
        self.signature = signature
        self.unsignedAttrs = unsignedAttrs
    }
}
