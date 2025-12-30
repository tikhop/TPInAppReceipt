import Foundation
import Testing

@_spi(Blocking) @testable import TPInAppReceipt

@Suite("MetaVerifier")
struct MetaVerifierTests {
    // MARK: - Valid Verification

    @Test
    func validVerificationWithMatchingValues() {
        let verifier = MetaVerifier(
            expectedBundleIdentifier: "com.example.app",
            expectedAppVersion: "1.0.0"
        )

        let result = verifier.verify(
            bundleIdentifier: "com.example.app",
            versionIdentifier: "1.0.0"
        )

        #expect(result.isValid)
    }

    // MARK: - Invalid Verification

    @Test
    func mismatchedBundleIdentifierFails() {
        let verifier = MetaVerifier(
            expectedBundleIdentifier: "com.example.app",
            expectedAppVersion: "1.0.0"
        )

        let result = verifier.verify(
            bundleIdentifier: "com.different.app",
            versionIdentifier: "1.0.0"
        )

        #expect(result.isInvalid)
        if case let .invalid(error) = result {
            #expect(error is MetaVerificationError)
            if let metaError = error as? MetaVerificationError {
                #expect(metaError == .bundleIdentifierMismatch)
            }
        }
    }

    @Test
    func mismatchedVersionFails() {
        let verifier = MetaVerifier(
            expectedBundleIdentifier: "com.example.app",
            expectedAppVersion: "1.0.0"
        )

        let result = verifier.verify(
            bundleIdentifier: "com.example.app",
            versionIdentifier: "2.0.0"
        )

        #expect(result.isInvalid)
        if case let .invalid(error) = result {
            #expect(error is MetaVerificationError)
            if let metaError = error as? MetaVerificationError {
                #expect(metaError == .versionIdentifierMismatch)
            }
        }
    }

    @Test
    func caseSensitiveBundleIdentifierFails() {
        let verifier = MetaVerifier(
            expectedBundleIdentifier: "com.example.app",
            expectedAppVersion: "1.0.0"
        )

        let result = verifier.verify(
            bundleIdentifier: "com.Example.App",
            versionIdentifier: "1.0.0"
        )

        #expect(result.isInvalid)
    }

    // MARK: - Provider-Based Initialization

    @Test
    func providerBasedInitializerWorks() {
        nonisolated(unsafe) var currentVersion = "1.0.0"
        nonisolated(unsafe) var currentBundleId = "com.example.app"

        let verifier = MetaVerifier(
            appVersionProvider: { currentVersion },
            bundleIdentifierProvider: { currentBundleId }
        )

        let result1 = verifier.verify(
            bundleIdentifier: "com.example.app",
            versionIdentifier: "1.0.0"
        )
        #expect(result1.isValid)

        // Change expected values to verify providers return dynamic values
        currentVersion = "2.0.0"
        currentBundleId = "com.different.app"

        let result2 = verifier.verify(
            bundleIdentifier: "com.example.app",
            versionIdentifier: "1.0.0"
        )
        #expect(result2.isInvalid)
    }
}
