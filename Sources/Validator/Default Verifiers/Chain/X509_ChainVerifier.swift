#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import Crypto
import SwiftASN1
@_spi(FixedExpiryValidationTime) import X509

// MARK: - Chain Verifier

public final class X509ChainVerifier: ReceiptChainVerifier {
    private let store: CertificateStore

    public init(rootCertificates: [Data]) throws {
        let parsedCertificates = try rootCertificates.map { try Certificate(derEncoded: [UInt8]($0)) }
        store = CertificateStore(parsedCertificates)
    }

    public init(rootCertificates: [Certificate]) {
        store = CertificateStore(rootCertificates)
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

        if case let .couldNotValidate(terminalErrors) = result {
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
            PolicySequence(policy.compactMap { $0.policy })
        }

        let intermediateStore = CertificateStore(intermediate)
        return await verifier.validate(leaf: leaf, intermediates: intermediateStore)
    }
}

extension X509ChainVerifier: ReceiptVerifier {
    public func verify(_ receipt: any ReceiptValidatable) async -> VerificationResult {
        guard let leaf = receipt.leafCertificate else {
            return .invalid(ChainVerificationError.invalidCertificateData)
        }

        guard receipt.certificates.count > 1 else {
            return .invalid(ChainVerificationError.invalidCertificateData)
        }

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
    private static let WWDR_INTERMEDIATE_OID: ASN1ObjectIdentifier = [1, 2, 840, 113_635, 100, 6, 2, 1]
    private static let RECEIPT_SIGNER_OID: ASN1ObjectIdentifier = [1, 2, 840, 113_635, 100, 6, 11, 1]

    init() {
        verifyingCriticalExtensions = []
    }

    var verifyingCriticalExtensions: [SwiftASN1.ASN1ObjectIdentifier]

    func chainMeetsPolicyRequirements(chain: X509.UnverifiedCertificateChain) async -> X509.PolicyEvaluationResult {
        if chain.count != AppStoreOIDPolicy.NUMBER_OF_CERTS {
            return X509.PolicyEvaluationResult.failsToMeetPolicy(reason: "Chain has unexpected length")
        }
        let intermediateCertificate = chain[1]
        let leafCertificate = chain[0]
        if !intermediateCertificate.extensions.contains(where: { ext in
            ext.oid == AppStoreOIDPolicy.WWDR_INTERMEDIATE_OID
        }) {
            return X509.PolicyEvaluationResult.failsToMeetPolicy(
                reason: "Intermediate certificate does not contain WWDR OID"
            )
        }
        if !leafCertificate.extensions.contains(where: { ext in
            ext.oid == AppStoreOIDPolicy.RECEIPT_SIGNER_OID
        }) {
            return X509.PolicyEvaluationResult.failsToMeetPolicy(
                reason: "Leaf certificate does not contain Receipt Signing OID"
            )
        }
        return X509.PolicyEvaluationResult.meetsPolicy
    }
}

// MARK: - OCSP Requester

#if canImport(Darwin)

final class Requester: OCSPRequester {
    static let OCSP_NETWORK_REQUEST_FAILED = "OCSP_NETWORK_REQUEST_FAILED"

    private let urlSession: URLSession

    convenience init(sessionConfiguration: URLSessionConfiguration = .default) {
        self.init(urlSession: URLSession(configuration: sessionConfiguration))
    }

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    init() {
        self.urlSession = URLSession(configuration: .default)
    }

    func query(request: [UInt8], uri: String) async -> X509.OCSPRequesterQueryResult {
        guard let url = URL(string: uri) else {
            return .terminalError(OCSPValidationError.fetchFailed)
        }

        var urlRequest = URLRequest(url: url)
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
            case let .httpError(statusCode):
                return "\(Requester.OCSP_NETWORK_REQUEST_FAILED): HTTP error \(statusCode)"
            case let .networkError(underlyingError):
                return
                    "\(Requester.OCSP_NETWORK_REQUEST_FAILED): Network error - \(underlyingError.localizedDescription)"
            }
        }
    }
}

#else

import AsyncHTTPClient

final class Requester: OCSPRequester {
    static let OCSP_NETWORK_REQUEST_FAILED = "OCSP_NETWORK_REQUEST_FAILED"

    private let client: HTTPClient

    init() {
        self.client = HTTPClient(eventLoopGroupProvider: .singleton)
    }

    func query(request: [UInt8], uri: String) async -> X509.OCSPRequesterQueryResult {
        do {
            var urlRequest = HTTPClientRequest(url: uri)
            urlRequest.method = .POST
            urlRequest.headers.add(name: "Content-Type", value: "application/ocsp-request")
            urlRequest.body = .bytes(request)

            let response = try await client.execute(urlRequest, timeout: .seconds(30))

            guard response.status.code == 200 else {
                throw OCSPValidationError.httpError(statusCode: UInt(response.status.code))
            }

            var body = try await response.body.collect(upTo: 1024 * 1024)
            guard let data = body.readBytes(length: body.readableBytes) else {
                throw OCSPValidationError.fetchFailed
            }

            return .response(data)
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
            case let .httpError(statusCode):
                return "\(Requester.OCSP_NETWORK_REQUEST_FAILED): HTTP error \(statusCode)"
            case let .networkError(underlyingError):
                return
                    "\(Requester.OCSP_NETWORK_REQUEST_FAILED): Network error - \(underlyingError.localizedDescription)"
            }
        }
    }
}

#endif

extension ReceiptChainVerifierPolicy {
    fileprivate var policy: VerifierPolicy? {
        switch self {
        case .appleX509Basic:
            return nil
        case .appStoreReceipt:
            return AppStoreOIDPolicy()
        case let .validationTime(time):
            return RFC5280Policy(fixedExpiryValidationTime: time)
        case let .onlineValidationTime(time):
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
            case let .failsToMeetPolicy(reason):
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
