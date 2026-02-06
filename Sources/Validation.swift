import Foundation
import X509

// MARK: - AppReceipt Validation

extension AppReceipt {
    /// Validates the receipt asynchronously.
    ///
    /// Performs validation of this receipt instance including certificate chain verification,
    /// signature verification, hash verification, and metadata validation.
    ///
    /// - Parameters:
    ///   - rootCertificate: Optional custom root certificate data. If not provided, the appropriate
    ///     Apple root certificate is selected based on the receipt's environment.
    ///   - deviceIdentifier: Optional device identifier data. If not provided, the system device
    ///     identifier is retrieved asynchronously.
    /// - Returns: A ``VerificationResult`` indicating whether the receipt is valid or invalid.
    @concurrent public func validate(
        rootCertificate: Data? = nil,
        deviceIdentifier: Data? = nil,
        needsMetadataVerification: Bool = true
    ) async -> VerificationResult {
        guard hasValidStructure else {
            return .invalid(ReceiptValidatorError.invalidReceiptStructure)
        }

        guard let root = await Self.appleRootCertificateData(using: rootCertificate, environment: environment) else {
            return .invalid(ReceiptValidatorError.rootCertificateInvalid(nil))
        }

        guard let deviceId = await Self.deviceIdentifier(using: deviceIdentifier) else {
            return .invalid(ReceiptValidatorError.deviceIdentifierIsNotFound)
        }

        do {
            let validator = try ReceiptValidator.default(
                rootCertificate: root,
                deviceIdentifier: deviceId,
                environment: environment,
                needsMetadataVerification: needsMetadataVerification
            )

            return await validator.validate(self)
        } catch {
            return .invalid(error)
        }
    }
}

extension AppReceipt: ReceiptValidatable {
    public var bundleIdentifierData: Data {
        payload.bundleIdentifierData
    }

    public var opaqueValue: Data {
        payload.opaqueValue
    }

    public var receiptHash: Data {
        payload.receiptHash
    }

    public var versionIdentifier: String {
        appVersion
    }

    public var certificates: [Certificate] {
        content.certificates
    }

    public var certificatesRaw: [Data] {
        content.certificatesRaw
    }

    public var validationTime: Date {
        creationDate
    }

    public var digestData: Data {
        payloadRawData
    }

    public var digestAlgorithm: DigestAlgorithm {
        signerInfo.digestAlgorithm == .sha1 ? .sha1 : .sha256
    }

    public var signature: Data {
        Data(signerInfo.signature.bytes)
    }

    // MARK: - Private Implementation

    var signerInfo: SignerInfo {
        guard let signer = content.signerInfos.first else {
            fatalError("Invalid Receipt: Expected one signer")
        }

        return signer
    }
}

// MARK: - Helpers
extension AppReceipt {
    fileprivate static func appleRootCertificateData(
        using rootCertificate: Data? = nil,
        environment: InAppReceiptPayload.Environment
    ) async -> Data? {
        guard let rootCertificate else {
            return await Bundle.appleRootCertificateData(testing: environment == .xcode)
        }

        return rootCertificate
    }

    fileprivate static func deviceIdentifier(using deviceIdentifier: Data?) async -> Data? {
        guard let deviceIdentifier else {
            return await DeviceIdentifier.data
        }

        return deviceIdentifier
    }
}
