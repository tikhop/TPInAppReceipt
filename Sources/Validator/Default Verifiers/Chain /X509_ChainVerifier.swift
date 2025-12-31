#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

@_spi(FixedExpiryValidationTime)
import X509
import SwiftASN1
import Crypto

// MARK: - Chain Verifier
public final class X509ChainVerifier: ReceiptChainVerifier {
    private let store: CertificateStore

    public init(rootCertificates: [Data]) throws {
        let parsedCertificates = try rootCertificates.map { try Certificate(derEncoded: [UInt8]($0)) }
        self.store = CertificateStore(parsedCertificates)
    }

    public init(rootCertificates: [Certificate]) {
        self.store = CertificateStore(rootCertificates)
    }

    public func verify(
        leaf: Certificate,
        intermediate: [Certificate],
        policy: [ReceiptChainVerifierPolicy]
    ) async -> VerificationResult {
        let result = await verify(
            leaf: leaf,
            intermediate: intermediate,
            rootCertificate: store,
            policy: policy
        )

        if case .couldNotValidate(let terminalErrors) = result {
            for failure in terminalErrors {
                let failureReasonString = failure.policyFailureReason.description
                if failureReasonString.contains(Requester.OCSP_NETWORK_REQUEST_FAILED) {
                    return .invalid(ChainVerificationError.revocationCheckFailed)
                }
            }
            return .invalid(ChainVerificationError.chainValidationFailed)
        }

        return .valid
    }

    private func verify(
        leaf: Certificate,
        intermediate: [Certificate],
        rootCertificate: CertificateStore,
        policy: [ReceiptChainVerifierPolicy],
    ) async -> X509.CertificateValidationResult {
        var verifier = Verifier(rootCertificates: rootCertificate) {
            PolicySequence( policy.compactMap { $0.policy } )
        }

        let intermediateStore = CertificateStore(intermediate)
        return await verifier.validate(leaf: leaf, intermediates: intermediateStore)
    }
}

extension X509ChainVerifier: ReceiptVerifier {
    public func verify(_ receipt: ReceiptValidatable) async -> VerificationResult {
        let leaf = receipt.certificates[0]
        let intermediate = receipt.certificates[1]

        let policy: [ReceiptChainVerifierPolicy]
        if receipt.environment == .xcode {
            policy = []
        } else {
            policy = [
                .appleX509Basic,
                .appStoreReceipt,
                .validationTime(receipt.validationTime),
            ]
        }
        let result = await verify(
            leaf: leaf,
            intermediate: [intermediate],
            policy: policy
        )

        return result
    }
}

final class AppStoreOIDPolicy: VerifierPolicy {
    
    private static let NUMBER_OF_CERTS = 3
    private static let WWDR_INTERMEDIATE_OID: ASN1ObjectIdentifier = [1, 2, 840, 113635, 100, 6, 2, 1]
    private static let RECEIPT_SIGNER_OID: ASN1ObjectIdentifier = [1, 2, 840, 113635, 100, 6, 11, 1]
    
    init() {
        verifyingCriticalExtensions = []
    }
    
    var verifyingCriticalExtensions: [SwiftASN1.ASN1ObjectIdentifier]
    
    func chainMeetsPolicyRequirements(chain: X509.UnverifiedCertificateChain) async -> X509.PolicyEvaluationResult {
        if (chain.count != AppStoreOIDPolicy.NUMBER_OF_CERTS) {
            return X509.PolicyEvaluationResult.failsToMeetPolicy(reason: "Chain has unexpected length")
        }
        let intermediateCertificate = chain[1]
        let leafCertificate = chain[0]
        if (!intermediateCertificate.extensions.contains(where: { ext in
            ext.oid == AppStoreOIDPolicy.WWDR_INTERMEDIATE_OID
        })) {
            return X509.PolicyEvaluationResult.failsToMeetPolicy(reason: "Intermediate certificate does not contain WWDR OID")
        }
        if (!leafCertificate.extensions.contains(where: { ext in
            ext.oid == AppStoreOIDPolicy.RECEIPT_SIGNER_OID
        })) {
            return X509.PolicyEvaluationResult.failsToMeetPolicy(reason: "Leaf certificate does not contain Receipt Signing OID")
        }
        return X509.PolicyEvaluationResult.meetsPolicy
    }
}

final class Requester: OCSPRequester {

    static let OCSP_NETWORK_REQUEST_FAILED = "OCSP_NETWORK_REQUEST_FAILED"

    private let urlSession: URLSession

    /// Initializes a new instance of `URLSessionTransport` with a given `URLSession`.
    ///
    /// - Parameter urlSession: An optional `URLSession` instance to use. Defaults to `URLSession.shared`.
    public convenience init(sessionConfiguration: URLSessionConfiguration = .default) {
        self.init(urlSession: URLSession(configuration: sessionConfiguration))
    }

    /// Convenience initializer that creates a new instance of `URLSessionTransport` with a specific `URLSessionConfiguration`.
    ///
    /// - Parameter sessionConfiguration: The `URLSessionConfiguration` to use for the `URLSession`. Defaults to `.default`.
    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func query(request: [UInt8], uri: String) async -> X509.OCSPRequesterQueryResult {
        var urlRequest = URLRequest(url: URL(string: uri)!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = Data(request)
        urlRequest.setValue("application/ocsp-request", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/ocsp-response", forHTTPHeaderField: "Accept")
        urlRequest.setValue("\(request.count)", forHTTPHeaderField: "Content-Length")

        do {
            let (data, response) = try await urlSession.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw OCSPValidationError.networkError(underlyingError: URLError(.badServerResponse))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw OCSPValidationError.httpError(statusCode: UInt(httpResponse.statusCode))
            }

            return .response([UInt8](data))
        } catch let error as OCSPValidationError {
            return .terminalError(error)
        } catch {
            return .terminalError(OCSPValidationError.networkError(underlyingError: error))
        }
    }

    enum OCSPValidationError: Error, CustomStringConvertible {
        case fetchFailed
        case httpError(statusCode: UInt)
        case networkError(underlyingError: Error)

        var description: String {
            switch self {
            case .fetchFailed:
                return "\(Requester.OCSP_NETWORK_REQUEST_FAILED): Could not read response body"
            case .httpError(let statusCode):
                return "\(Requester.OCSP_NETWORK_REQUEST_FAILED): HTTP error \(statusCode)"
            case .networkError(let underlyingError):
                return "\(Requester.OCSP_NETWORK_REQUEST_FAILED): Network error - \(underlyingError.localizedDescription)"
            }
        }
    }
}

fileprivate extension ReceiptChainVerifierPolicy {
    var policy: VerifierPolicy? {
        switch self {
        case .appleX509Basic:
            return nil
        case .appStoreReceipt:
            return AppStoreOIDPolicy()
        case .validationTime(let time):
            return RFC5280Policy(fixedExpiryValidationTime: time)
        case .onlineValidationTime(let time):
            return OCSPVerifierPolicy(
                failureMode: .soft,
                requester: Requester(),
                fixedExpiryValidationTime: time
            )
        }
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, macCatalyst 13, visionOS 1.0, *)
public struct PolicySequence: VerifierPolicy {
    public var policies: [AnyPolicy]

    public init(_ policies: [AnyPolicy]) {
        self.policies = policies
    }

    public init(_ policies: [any VerifierPolicy]) {
        self.policies = policies.map { AnyPolicy($0) }
    }

    public var verifyingCriticalExtensions: [ASN1ObjectIdentifier] {
        policies.flatMap { $0.verifyingCriticalExtensions }
    }

    public mutating func chainMeetsPolicyRequirements(
        chain: UnverifiedCertificateChain
    ) async -> PolicyEvaluationResult {
        for i in policies.indices {
            switch await policies[i].chainMeetsPolicyRequirements(chain: chain) {
            case .meetsPolicy:
                continue
            case .failsToMeetPolicy(let reason):
                return .failsToMeetPolicy(reason: reason)
            }
        }
        return .meetsPolicy
    }
}

extension PolicyBuilder {
    @inlinable
    public static func buildArray(_ components: [VerifierPolicy]) -> some VerifierPolicy {
        PolicySequence(components.map { AnyPolicy($0) })
    }
}
