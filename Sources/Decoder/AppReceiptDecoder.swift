#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A decoder for app receipts.
///
/// `AppReceiptDecoder` uses a decoding engine to extract receipt data.
public final class AppReceiptDecoder: Sendable {
    /// A protocol for decoding app receipt data.
    ///
    /// Implement this protocol to provide custom receipt decoding logic.
    public protocol Engine: Sendable {
        /// Decodes an app receipt.
        ///
        /// - Parameter data: The receipt data to decode.
        /// - Returns: The decoded app receipt.
        /// - Throws: ``AppReceiptError/decodingFailed(_:)`` if the data is invalid.
        func decode(from data: Data) throws -> AppReceipt
    }

    let engine: Engine

    /// Creates a decoder with the specified decoding engine.
    ///
    /// - Parameter engine: The engine to use for decoding.
    public init(engine: Engine) {
        self.engine = engine
    }

    /// Decodes an app receipt.
    ///
    /// - Parameter data: The receipt data to decode.
    /// - Returns: The decoded app receipt.
    /// - Throws: ``AppReceiptError/decodingFailed(_:)`` if the data is invalid.
    func decode(from data: Data) throws -> AppReceipt {
        try engine.decode(from: data)
    }
}
