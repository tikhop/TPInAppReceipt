#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension AppReceiptDecoder {
    /// The default receipt decoder using SwiftASN1.
    ///
    /// Creates a pre-configured decoder instance that uses the SwiftASN1 engine
    /// for decoding App Store receipts.
    public static var `default`: Self {
        .init(engine: SwiftASN1ReceiptDecoder())
    }
}

extension AppReceipt {
    /// Creates and decodes an ``AppReceipt`` instance from raw receipt data.
    ///
    /// Decodes the provided receipt data using the default ASN.1 decoder to create
    /// a fully parsed ``AppReceipt`` instance.
    ///
    /// - Parameter data: The raw receipt data (typically from the app bundle).
    /// - Returns: A decoded ``AppReceipt`` instance.
    /// - Throws: ``AppReceiptError/decodingFailed(_:)`` if the receipt data is invalid or cannot be decoded.
    public static func receipt(from data: Data) throws(AppReceiptError) -> AppReceipt {
        do {
            return try AppReceiptDecoder.default.decode(from: data)
        } catch let error as AppReceiptError {
            throw error
        } catch {
            throw .decodingFailed(error)
        }
    }

    /// Retrieves and decodes the local App Store receipt asynchronously.
    ///
    /// Loads the receipt bundled with the application from the App Store receipt URL and decodes it.
    ///
    /// - Returns: A decoded ``AppReceipt`` instance.
    /// - Throws: ``AppReceiptError/appStoreReceiptNotFound`` if the receipt is not available,
    ///   or ``AppReceiptError/decodingFailed(_:)`` if the receipt cannot be decoded.
    public static var local: AppReceipt {
        get async throws(AppReceiptError) {
            guard let data = await Bundle.main.appStoreReceiptData() else {
                throw AppReceiptError.appStoreReceiptNotFound
            }

            return try receipt(from: data)
        }
    }
}
