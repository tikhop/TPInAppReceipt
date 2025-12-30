public final class MetaVerifier: ReceiptMetaVerifier {
    public typealias AppVersionProvider = @Sendable () -> String
    public typealias AppBundleIdentifierProvider = @Sendable () -> String

    internal let appVersionProvider: AppVersionProvider
    internal let bundleIdentifierProvider: AppBundleIdentifierProvider

    public init(
        appVersionProvider: @escaping AppVersionProvider,
        bundleIdentifierProvider: @escaping AppBundleIdentifierProvider
    ) {
        self.appVersionProvider = appVersionProvider
        self.bundleIdentifierProvider = bundleIdentifierProvider
    }

    /// Creates a MetaVerifier with static expected values.
    /// Use this on servers when validating receipts from clients.
    public convenience init(
        expectedBundleIdentifier: String,
        expectedAppVersion: String
    ) {
        self.init(
            appVersionProvider: { expectedAppVersion },
            bundleIdentifierProvider: { expectedBundleIdentifier }
        )
    }

    public func verify(
        bundleIdentifier: String,
        versionIdentifier: String
    ) -> VerificationResult {
        guard appVersionProvider() == versionIdentifier else {
            return .invalid(MetaVerificationError.versionIdentifierMismatch)
        }

        guard bundleIdentifierProvider() == bundleIdentifier else {
            return .invalid(MetaVerificationError.bundleIdentifierMismatch)
        }

        return .valid
    }
}

extension MetaVerifier: ReceiptVerifier {
    public func verify(_ receipt: ReceiptValidatable) -> VerificationResult {
        return verify(
            bundleIdentifier: receipt.bundleIdentifier,
            versionIdentifier: receipt.versionIdentifier
        )
    }
}

#if os(iOS) || os(watchOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

import Foundation

// MARK: Native Providers

let nativeAppVersionProvider: MetaVerifier.AppVersionProvider = {
    #if targetEnvironment(macCatalyst) || os(macOS)
    let dictKey: String = "CFBundleShortVersionString"
    #else
    let dictKey: String = "CFBundleVersion"
    #endif

    guard let v = Bundle.main.infoDictionary?[dictKey] as? String else {
        fatalError("Version string not found in main bundle's info dictionary.")
    }

    return v
}

let nativeBundleIdentifierProvider: MetaVerifier.AppBundleIdentifierProvider = {
    guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
        fatalError("Bundle identifier not found.")
    }

    return bundleIdentifier
}
#endif
