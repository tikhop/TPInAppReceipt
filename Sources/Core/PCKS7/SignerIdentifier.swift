import X509

/// An identifier for a signer in a PKCS#7 SignerInfo structure.
///
/// SignerIdentifier can identify a signer either by issuer and serial number or by subject key identifier.
public enum SignerIdentifier: Hashable, Sendable {
    /// The issuer and serial number of the signer's certificate.
    case issuerAndSerialNumber(IssuerAndSerialNumber)

    /// The subject key identifier of the signer's certificate.
    case subjectKeyIdentifier(SubjectKeyIdentifier)

    /// Creates a signer identifier from a certificate using its issuer and serial number.
    @inlinable
    public init(issuerAndSerialNumber certificate: Certificate) {
        self = .issuerAndSerialNumber(.init(issuer: certificate.issuer, serialNumber: certificate.serialNumber))
    }
}
