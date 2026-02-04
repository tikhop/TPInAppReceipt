import Foundation
import X509

@_spi(Blocking)
extension ReceiptValidator {
    /// Creates a default receipt validator with blocking verification methods.
    ///
    /// Initializes a ``ReceiptValidator`` configured with all verifiers
    /// to perform complete receipt validation in a blocking manner.
    ///
    /// - Parameters:
    ///   - rootCertificate: The root certificate data used to validate the certificate chain.
    ///   - deviceIdentifier: The device identifier data for hash verification.
    /// - Returns: A configured ``ReceiptValidator`` instance ready for receipt validation.
    static func default_blocking(
        rootCertificate: Data,
        deviceIdentifier: Data
    ) -> ReceiptValidator {
        ReceiptValidator {
            SecChainVerifier(rootCertificates: [rootCertificate])
            SecSignatureVerifier()
            HashVerifier(deviceIdentifier: deviceIdentifier)
            MetaVerifier(
                appVersionProvider: nativeAppVersionProvider,
                bundleIdentifierProvider: nativeBundleIdentifierProvider
            )
        }
    }

    /// Validates a receipt using blocking verification methods.
    ///
    /// Performs synchronous validation of the provided receipt by running it through
    /// all configured verifiers sequentially.
    ///
    /// - Parameter receipt: The receipt object to validate.
    /// - Returns: A ``VerificationResult`` indicating whether the receipt is valid or invalid.
    public func validate_blocking(_ receipt: any ReceiptValidatable) -> VerificationResult {
        for verifier in verifiers {
            if case let .invalid(error) = verifier.verify(receipt) {
                return .invalid(error)
            }
        }

        return .valid
    }
}

@_spi(Blocking)
extension Bundle {
    fileprivate static func appleRootCertificateData(testing: Bool) -> Data? {
        let filename = testing ? "StoreKitTestCertificate.cer" : "AppleIncRootCertificate.cer"
        guard let url = url(for: filename) else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    /// Retrieves the local App Store receipt data.
    ///
    /// Loads the receipt file bundled with the application from the App Store receipt URL.
    ///
    /// - Returns: The receipt data as ``Data``, or nil if the receipt file cannot be found or loaded.
    fileprivate func appStoreReceiptData() -> Data? {
        guard let receiptUrl = appStoreReceiptURL else { return nil }
        return try? Data(contentsOf: receiptUrl)
    }

    /// Retrieve local App Store Receipt Data in base64 string
    ///
    /// - Returns: ``Data`` object that represents local receipt
    /// - throws: An error if receipt file not found or ``Data`` can't be created
    public func appStoreReceiptBase64() -> String? {
        appStoreReceiptData()?.base64EncodedString()
    }
}

@_spi(Blocking)
extension AppReceipt {
    /// Retrieves the local App Store receipt from the application bundle.
    ///
    /// Loads and parses the receipt file stored locally within the application bundle.
    ///
    /// - Returns: An ``AppReceipt`` instance.
    /// - Throws: ``AppReceiptError/appStoreReceiptNotFound`` if the receipt is not available,
    ///   or ``AppReceiptError/decodingFailed(_:)`` if the receipt cannot be decoded.
    public static var local_blocking: AppReceipt {
        get throws(AppReceiptError) {
            guard let data = Bundle.main.appStoreReceiptData() else {
                throw AppReceiptError.appStoreReceiptNotFound
            }

            return try receipt(from: data)
        }
    }

    /// Validates the receipt using blocking verification methods.
    ///
    /// Performs synchronous validation of this receipt instance.
    ///
    /// - Parameters:
    ///   - rootCertificate: Optional custom root certificate data. If not provided, the appropriate
    ///     Apple root certificate is selected based on the receipt's environment.
    ///   - deviceIdentifier: Optional device identifier data. If not provided, the system device
    ///     identifier is used.
    /// - Returns: A ``VerificationResult`` indicating whether the receipt is valid or invalid.
    public func validate_blocking(
        rootCertificate: Data? = nil,
        deviceIdentifier: Data? = nil
    ) -> VerificationResult {
        guard hasValidStructure else {
            return .invalid(ReceiptValidatorError.invalidReceiptStructure)
        }

        let root = rootCertificate ?? Bundle.appleRootCertificateData(testing: environment == .xcode)

        guard let root else {
            return .invalid(ReceiptValidatorError.rootCertificateInvalid(nil))
        }

        let deviceId = deviceIdentifier ?? DeviceIdentifier.data_blocking

        guard let deviceId else {
            return .invalid(HashVerificationError.missingDeviceIdentifier)
        }

        let validator = ReceiptValidator.default_blocking(
            rootCertificate: root,
            deviceIdentifier: deviceId
        )
        return validator.validate_blocking(self)
    }
}

extension ReceiptVerifier {
    /// Verifies a receipt.
    ///
    /// This is a synchronous implementation that is not supported. Use the async version instead.
    ///
    /// - Parameter receipt: The receipt object to verify.
    /// - Returns: Never returns; always raises a fatal error.
    public func verify(_: any ReceiptValidatable) -> VerificationResult {
        fatalError("Use async version instead")
    }
}
