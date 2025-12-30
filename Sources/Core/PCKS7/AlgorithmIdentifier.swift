import SwiftASN1

/// An algorithm identifier with optional parameters.
///
/// AlgorithmIdentifier specifies an algorithm and any necessary parameters for its use.
public struct AlgorithmIdentifier: Hashable, Sendable {
    /// The object identifier of the algorithm.
    public var algorithm: ASN1ObjectIdentifier

    /// The algorithm parameters, if any.
    public var parameters: ASN1Any?

    /// Creates an AlgorithmIdentifier with the specified algorithm and parameters.
    @inlinable
    public init(algorithm: ASN1ObjectIdentifier, parameters: ASN1Any?) {
        self.algorithm = algorithm
        self.parameters = parameters
    }
}

// MARK: Algorithm Identifier Statics
extension AlgorithmIdentifier {
    public var rfc8446SignatureSchemeValue: UInt16 {
        switch self {
        case .sha1WithRSAEncryption:
            return 0x0201
        case .sha256WithRSAEncryption:
            return 0x0401
        default:
            fatalError("Not supported algorithm: \(self)")
        }
    }

    // MARK: For the RSA signature types, explicit ASN.1 NULL is equivalent to a missing parameters field.
    // We include both here, and the usage sites need to handle the equivalent.
    public static let sha1WithRSAEncryption = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha1WithRSAEncryption,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )

    public static let sha256WithRSAEncryption = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha256WithRSAEncryption,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )

    public static let rsaKey = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.rsaEncryption,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )

    public static let sha1 = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha1,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )

    public static let sha256 = AlgorithmIdentifier(
        algorithm: .AlgorithmIdentifier.sha256,
        parameters: try! ASN1Any(erasing: ASN1Null())
    )
}

extension AlgorithmIdentifier: CustomStringConvertible {
    public var description: String {
        switch self {
        case .sha1WithRSAEncryption:
            return "sha1WithRSAEncryption"
        case .sha256WithRSAEncryption:
            return "sha256WithRSAEncryption"
        case .sha1:
            return "sha1"
        case .sha256:
            return "sha256"
        default:
            return "AlgorithmIdentifier(\(self.algorithm) - \(String(reflecting: self.parameters)))"
        }
    }
}

extension ASN1ObjectIdentifier.AlgorithmIdentifier {
    public static let sha1WithRSAEncryption: ASN1ObjectIdentifier = [1, 2, 840, 113549, 1, 1, 5]
    public static let sha1: ASN1ObjectIdentifier = [1, 3, 14, 3, 2, 26]
    public static let sha256: ASN1ObjectIdentifier = [2, 16, 840, 1, 101, 3, 4, 2, 1]
    public static let rsa: ASN1ObjectIdentifier = [1, 2, 840, 113549, 1, 1, 1]
}
