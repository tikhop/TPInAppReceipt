import Crypto
import Foundation

// MARK: - Receipt Hash Verifier

public final class HashVerifier: ReceiptHashVerifier {
    private let deviceIdentifier: Data

    public init(deviceIdentifier: Data) {
        self.deviceIdentifier = deviceIdentifier
    }

    func computeHash(
        deviceIdentifier: Data,
        opaqueValue: Data,
        bundleIdentifierData: Data
    ) -> Data {
        var sha1 = Insecure.SHA1()
        sha1.update(data: deviceIdentifier)
        sha1.update(data: opaqueValue)
        sha1.update(data: bundleIdentifierData)

        let digest = sha1.finalize()
        return Data(digest)
    }

    public func verify(
        expectedHash: Data,
        opaqueValue: Data,
        bundleIdentifier: Data
    ) -> VerificationResult {
        let computedHash = computeHash(
            deviceIdentifier: deviceIdentifier,
            opaqueValue: opaqueValue,
            bundleIdentifierData: bundleIdentifier
        )

        return computedHash == expectedHash ? .valid : .invalid(HashVerificationError.hashMismatch)
    }
}

extension HashVerifier: ReceiptVerifier {
    public func verify(_ receipt: any ReceiptValidatable) async -> VerificationResult {
        verify(
            expectedHash: receipt.receiptHash,
            opaqueValue: receipt.opaqueValue,
            bundleIdentifier: receipt.bundleIdentifierData
        )
    }

    @_spi(Blocking)
    public func verify(_ receipt: any ReceiptValidatable) -> VerificationResult {
        verify(
            expectedHash: receipt.receiptHash,
            opaqueValue: receipt.opaqueValue,
            bundleIdentifier: receipt.bundleIdentifierData
        )
    }
}
