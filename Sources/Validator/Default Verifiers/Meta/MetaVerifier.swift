public final class MetaVerifier: ReceiptMetaVerifier {
    public typealias AppVersionProvider = @Sendable () throws -> String
    public typealias AppBundleIdentifierProvider = @Sendable () throws -> String

    let appVersionProvider: AppVersionProvider
    let bundleIdentifierProvider: AppBundleIdentifierProvider

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
        do {
            let expectedVersion = try appVersionProvider()
            guard expectedVersion == versionIdentifier else {
                return .invalid(MetaVerificationError.versionIdentifierMismatch)
            }

            let expectedBundleIdentifier = try bundleIdentifierProvider()
            guard expectedBundleIdentifier == bundleIdentifier else {
                return .invalid(MetaVerificationError.bundleIdentifierMismatch)
            }

            return .valid
        } catch {
            return .invalid(error)
        }
    }
}

extension MetaVerifier: ReceiptVerifier {
    public func verify(_ receipt: any ReceiptValidatable) -> VerificationResult {
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
    let dictKey = "CFBundleShortVersionString"
    #else
    let dictKey = "CFBundleVersion"
    #endif

    guard let v = Bundle.main.infoDictionary?[dictKey] as? String else {
        throw MetaVerificationError.bundleInfoUnavailable
    }

    return v
}

let nativeBundleIdentifierProvider: MetaVerifier.AppBundleIdentifierProvider = {
    guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
        throw MetaVerificationError.bundleInfoUnavailable
    }

    return bundleIdentifier
}
#endif
