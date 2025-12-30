import Foundation

extension Bundle {
    /// Appropriate app version for receipt validation
    var appVersion: String? {
        #if targetEnvironment(macCatalyst) || os(macOS)
        let dictKey = "CFBundleShortVersionString"
        #else
        let dictKey = "CFBundleVersion"
        #endif

        return infoDictionary?[dictKey] as? String
    }

    /// Retrieve local App Store Receipt Data
    ///
    /// - Returns: 'Data' object that represents local receipt
    /// - throws: An error if receipt file not found or 'Data' can't be created
    func appStoreReceiptData() async -> Data? {
        guard let receiptUrl = appStoreReceiptURL else { return nil }
        return try? await Data.readBytes(from: receiptUrl)
    }

    /// Retrieve local App Store Receipt Data in base64 string
    ///
    /// - Returns: 'Data' object that represents local receipt
    /// - throws: An error if receipt file not found or 'Data' can't be created
    public func appStoreReceiptBase64() async -> String? {
        await appStoreReceiptData()?.base64EncodedString()
    }

    static func appleRootCertificateData(testing: Bool) async -> Data? {
        let filename = testing ? "StoreKitTestCertificate.cer" : "AppleIncRootCertificate.cer"
        guard let url = url(for: filename) else {
            return nil
        }

        return try? await Data.readBytes(from: url)
    }

    static func url(for file: String) -> URL? {
        for bundle in [Bundle.module, Bundle.main] {
            if let url = bundle.url(forResource: file, withExtension: "") {
                return url
            }
        }

        return nil
    }
}
