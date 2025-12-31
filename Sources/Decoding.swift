#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public extension AppReceiptDecoder {
    /// The default receipt decoder using SwiftASN1.
    ///
    /// Creates a pre-configured decoder instance that uses the SwiftASN1 engine
    /// for decoding App Store receipts.
    static var `default`: Self {
        .init(engine: SwiftASN1ReceiptDecoder())
    }
}

public extension AppReceipt {
    /// Creates and decodes an ``AppReceipt`` instance from raw receipt data.
    ///
    /// Decodes the provided receipt data using the default ASN.1 decoder to create
    /// a fully parsed ``AppReceipt`` instance.
    ///
    /// - Parameter data: The raw receipt data (typically from the app bundle).
    /// - Returns: A decoded ``AppReceipt`` instance.
    /// - Throws: An error if the receipt data is invalid or cannot be decoded.
    static func receipt(from data: Data) throws -> AppReceipt {
        return try AppReceiptDecoder.default.decode(from: data)
    }

    /// Retrieves and decodes the local App Store receipt asynchronously.
    ///
    /// Loads the receipt bundled with the application from the App Store receipt URL and decodes it.
    ///
    /// - Returns: A decoded ``AppReceipt`` instance if the receipt exists, or nil if not available.
    /// - Throws: An error if the receipt cannot be decoded.
    static var local: AppReceipt? {
        get async throws {
            guard let data = await Bundle.main.appStoreReceiptData() else {
                return nil
            }

            return try receipt(from: data)
        }
    }
}
