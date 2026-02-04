import X509

/// The issuer and serial number of a certificate.
///
/// IssuerAndSerialNumber uniquely identifies a certificate by its issuer's distinguished name and serial number.
public struct IssuerAndSerialNumber: Hashable, Sendable {
    /// The issuer's distinguished name.
    public var issuer: DistinguishedName

    /// The certificate serial number.
    public var serialNumber: Certificate.SerialNumber

    /// Creates an IssuerAndSerialNumber with the specified values.
    @inlinable
    public init(
        issuer: DistinguishedName,
        serialNumber: Certificate.SerialNumber
    ) {
        self.issuer = issuer
        self.serialNumber = serialNumber
    }
}
