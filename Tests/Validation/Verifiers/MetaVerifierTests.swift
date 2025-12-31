import Testing
import Foundation

@_spi(Blocking)
@testable import TPInAppReceipt

// MARK: - MetaVerifier Tests

@Suite("MetaVerifier Tests")
struct MetaVerifierTests {

    // MARK: - Valid Verification Tests

    @Test("Valid verification with matching bundle identifier and version")
    func testValidVerificationWithMatchingValues() {
        let verifier = MetaVerifier(
            expectedBundleIdentifier: "com.example.app",
            expectedAppVersion: "1.0.0"
        )

        let result = verifier.verify(
            bundleIdentifier: "com.example.app",
            versionIdentifier: "1.0.0"
        )

        #expect(result.isValid, "Verification should succeed with matching values")
    }

    @Test("Valid verification using provider-based initializer")
    func testValidVerificationWithProviders() {
        let verifier = MetaVerifier(
            appVersionProvider: { "2.5.1" },
            bundleIdentifierProvider: { "com.test.myapp" }
        )

        let result = verifier.verify(
            bundleIdentifier: "com.test.myapp",
            versionIdentifier: "2.5.1"
        )

        #expect(result.isValid, "Verification should succeed with provider-based verifier")
    }

    // MARK: - Invalid Bundle Identifier Tests

    @Test("Invalid verification with mismatched bundle identifier")
    func testInvalidVerificationWithMismatchedBundleId() {
        let verifier = MetaVerifier(
            expectedBundleIdentifier: "com.example.app",
            expectedAppVersion: "1.0.0"
        )

        let result = verifier.verify(
            bundleIdentifier: "com.different.app",
            versionIdentifier: "1.0.0"
        )

        #expect(result.isInvalid, "Verification should fail with mismatched bundle identifier")

        if case .invalid(let error) = result {
            #expect(error is MetaVerificationError, "Error should be MetaVerificationError")
            if let metaError = error as? MetaVerificationError {
                #expect(metaError == .bundleIdentifierMismatch, "Error should be bundleIdentifierMismatch")
            }
        }
    }

    @Test("Invalid verification with empty bundle identifier")
    func testInvalidVerificationWithEmptyBundleId() {
        let verifier = MetaVerifier(
            expectedBundleIdentifier: "com.example.app",
            expectedAppVersion: "1.0.0"
        )

        let result = verifier.verify(
            bundleIdentifier: "",
            versionIdentifier: "1.0.0"
        )

        #expect(result.isInvalid, "Verification should fail with empty bundle identifier")
    }

    @Test("Invalid verification with case-sensitive bundle identifier")
    func testInvalidVerificationWithCaseSensitiveBundleId() {
        let verifier = MetaVerifier(
            expectedBundleIdentifier: "com.example.app",
            expectedAppVersion: "1.0.0"
        )

        let result = verifier.verify(
            bundleIdentifier: "com.Example.App",
            versionIdentifier: "1.0.0"
        )

        #expect(result.isInvalid, "Verification should fail with different case bundle identifier")
    }

    // MARK: - Invalid Version Identifier Tests

    @Test("Invalid verification with mismatched version identifier")
    func testInvalidVerificationWithMismatchedVersion() {
        let verifier = MetaVerifier(
            expectedBundleIdentifier: "com.example.app",
            expectedAppVersion: "1.0.0"
        )

        let result = verifier.verify(
            bundleIdentifier: "com.example.app",
            versionIdentifier: "2.0.0"
        )

        #expect(result.isInvalid, "Verification should fail with mismatched version")

        if case .invalid(let error) = result {
            #expect(error is MetaVerificationError, "Error should be MetaVerificationError")
            if let metaError = error as? MetaVerificationError {
                #expect(metaError == .versionIdentifierMismatch, "Error should be versionIdentifierMismatch")
            }
        }
    }

    // MARK: - Both Mismatched Tests

    @Test("Invalid verification with both bundle ID and version mismatched")
    func testInvalidVerificationWithBothMismatched() {
        let verifier = MetaVerifier(
            expectedBundleIdentifier: "com.example.app",
            expectedAppVersion: "1.0.0"
        )

        let result = verifier.verify(
            bundleIdentifier: "com.different.app",
            versionIdentifier: "2.0.0"
        )

        #expect(result.isInvalid, "Verification should fail with both values mismatched")

        // The implementation checks version first, so we expect versionIdentifierMismatch
        if case .invalid(let error) = result {
            if let metaError = error as? MetaVerificationError {
                #expect(metaError == .versionIdentifierMismatch, "Error should be versionIdentifierMismatch")
            }
        }
    }

    // MARK: - Provider Tests

    @Test("Providers are called during verification")
    func testProvidersAreCalled() {
        nonisolated(unsafe) var versionProviderCalled = false
        nonisolated(unsafe) var bundleProviderCalled = false

        let verifier = MetaVerifier(
            appVersionProvider: {
                versionProviderCalled = true
                return "1.0.0"
            },
            bundleIdentifierProvider: {
                bundleProviderCalled = true
                return "com.example.app"
            }
        )

        _ = verifier.verify(
            bundleIdentifier: "com.example.app",
            versionIdentifier: "1.0.0"
        )

        #expect(versionProviderCalled, "Version provider should be called")
        #expect(bundleProviderCalled, "Bundle identifier provider should be called")
    }

    @Test("Providers can return dynamic values")
    func testProvidersReturnDynamicValues() {
        nonisolated(unsafe) var currentVersion = "1.0.0"
        nonisolated(unsafe) var currentBundleId = "com.example.app"

        let verifier = MetaVerifier(
            appVersionProvider: { currentVersion },
            bundleIdentifierProvider: { currentBundleId }
        )

        // First verification should succeed
        let result1 = verifier.verify(
            bundleIdentifier: "com.example.app",
            versionIdentifier: "1.0.0"
        )
        #expect(result1.isValid, "First verification should succeed")

        // Change the expected values
        currentVersion = "2.0.0"
        currentBundleId = "com.different.app"

        // Second verification with old values should fail
        let result2 = verifier.verify(
            bundleIdentifier: "com.example.app",
            versionIdentifier: "1.0.0"
        )
        #expect(result2.isInvalid, "Second verification should fail")

        // Third verification with new values should succeed
        let result3 = verifier.verify(
            bundleIdentifier: "com.different.app",
            versionIdentifier: "2.0.0"
        )
        #expect(result3.isValid, "Third verification should succeed")
    }
}
