#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// The payload of an app receipt extracted from a PKCS#7 container.
///
/// `InAppReceiptPayload` contains all the decoded information from an app receipt,
/// including app details, purchase history, and validation data.
public struct InAppReceiptPayload: Sendable, Hashable {
    public enum Environment: String, Hashable, Sendable {
        case production = "Production"
        case productionSandbox = "ProductionSandbox"
        case sandbox = "Sandbox"
        case xcode = "Xcode"
        case unknown = "Unknown"

        public init(rawValue: String) {
            switch rawValue {
            case "Production":
                self = .production
            case "ProductionSandbox":
                self = .productionSandbox
            case "Sandbox":
                self = .sandbox
            case "Xcode":
                self = .xcode
            default:
                self = .unknown
            }
        }
    }

    /// The in-app purchase receipts.
    public let purchases: [InAppPurchase]

    /// The app's bundle identifier.
    public let bundleIdentifier: String

    /// The app's version number.
    public let appVersion: String

    /// The version of the app that was originally purchased.
    public let originalAppVersion: String?

    /// The date when the app was originally purchased.
    public let originalPurchaseDate: Date?

    /// The date that the app receipt expires.
    ///
    /// This key is only present for apps purchased through the Volume Purchase Program.
    public let expirationDate: Date?

    /// The app's bundle identifier as raw data.
    ///
    /// Used to validate the receipt.
    public let bundleIdentifierData: Data

    /// An opaque value used, with other data, to compute the SHA-1 hash.
    public let opaqueValue: Data

    /// The SHA-1 hash, used to validate the receipt.
    public let receiptHash: Data

    /// The date when the app receipt was created.
    public let creationDate: Date

    /// The age rating of the app.
    public let ageRating: String?

    /// The receipt's environment.
    public let environment: Environment

    /// The Apple ID used to purchase the app.
    public let appStoreID: Int?

    /// The transaction date.
    public let transactionDate: Date?

    /// The fulfillment tool version.
    public let fulfillmentToolVersion: Int?

    /// The developer ID.
    public let developerID: Int?

    /// The download ID.
    public let downloadID: Int?

    /// The installer version ID.
    public let installerVersionID: Int?

    /// Creates an app receipt payload with the specified values.
    public init(
        bundleIdentifier: String,
        appVersion: String,
        originalAppVersion: String?,
        originalPurchaseDate: Date?,
        purchases: [InAppPurchase],
        expirationDate: Date?,
        bundleIdentifierData: Data,
        opaqueValue: Data,
        receiptHash: Data,
        creationDate: Date,
        ageRating: String?,
        environment: Environment,
        appStoreID: Int? = nil,
        transactionDate: Date? = nil,
        fulfillmentToolVersion: Int? = nil,
        developerID: Int? = nil,
        downloadID: Int? = nil,
        installerVersionID: Int? = nil
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.appVersion = appVersion
        self.originalAppVersion = originalAppVersion
        self.originalPurchaseDate = originalPurchaseDate
        self.purchases = purchases
        self.expirationDate = expirationDate
        self.bundleIdentifierData = bundleIdentifierData
        self.opaqueValue = opaqueValue
        self.receiptHash = receiptHash
        self.creationDate = creationDate
        self.ageRating = ageRating
        self.environment = environment
        self.appStoreID = appStoreID
        self.transactionDate = transactionDate
        self.fulfillmentToolVersion = fulfillmentToolVersion
        self.developerID = developerID
        self.downloadID = downloadID
        self.installerVersionID = installerVersionID
    }
}
