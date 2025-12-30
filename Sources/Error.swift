/// Errors that can occur when working with app receipts.
public enum AppReceiptError: Error, Sendable {
    /// The app store receipt was not found on the device.
    ///
    /// This typically occurs when trying to access the local receipt for an app
    /// that hasn't been purchased from the App Store.
    case appStoreReceiptNotFound

    /// The receipt content is invalid or corrupted.
    ///
    /// - Parameter error: The underlying error that caused the content to be invalid.
    case receiptContentInvalid(any Error)

    /// The receipt payload is missing or invalid.
    ///
    /// This indicates the receipt structure doesn't contain the expected payload data.
    case receiptPayloadMissingOrInvalid

    /// Receipt decoding failed.
    ///
    /// This occurs when the receipt data cannot be decoded from its ASN.1 format.
    /// - Parameter error: The underlying error that caused the decoding failure.
    case decodingFailed(any Error)
}
