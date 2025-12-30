import Foundation
import SwiftASN1

/// ReceiptAttribute ::= SEQUENCE {
///     type    INTEGER,
///     version INTEGER,
///     value   OCTET STRING
/// }
public struct InAppReceiptPayloadAttribute: BERImplicitlyTaggable {
    public static let defaultIdentifier: SwiftASN1.ASN1Identifier = .sequence

    let type: Int
    let version: Int
    let value: ASN1OctetString

    public init(type: Int, version: Int, value: ASN1OctetString) {
        self.type = type
        self.version = version
        self.value = value
    }

    public init(berEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        self = try BER.sequence(berEncoded, identifier: identifier) { nodes in
            let type = try Int(berEncoded: &nodes)
            let version = try Int(berEncoded: &nodes)
            let octetString = try ASN1OctetString(berEncoded: &nodes)

            return .init(type: type, version: version, value: octetString)
        }
    }

    public init(derEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        try self.init(berEncoded: derEncoded, withIdentifier: identifier)
    }

    public func serialize(
        into coder: inout SwiftASN1.DER.Serializer,
        withIdentifier identifier: SwiftASN1.ASN1Identifier
    ) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(type)
            try coder.serialize(version)
            try coder.serialize(value)
        }
    }
}

extension InAppReceiptPayload: BERImplicitlyTaggable {
    public static var defaultIdentifier: SwiftASN1.ASN1Identifier {
        .set
    }

    public init(berEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        let attributes = try BER.set(
            of: InAppReceiptPayloadAttribute.self,
            identifier: identifier,
            rootNode: berEncoded
        )
        try self.init(set: attributes, rawBytes: berEncoded.encodedBytes)
    }

    public init(derEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        try self.init(berEncoded: derEncoded, withIdentifier: identifier)
    }

    public func serialize(into _: inout SwiftASN1.DER.Serializer, withIdentifier _: SwiftASN1.ASN1Identifier) throws {
        fatalError("TPInAppReceipt doesn't support encoding")
    }

    public init(set: [InAppReceiptPayloadAttribute], rawBytes _: ArraySlice<UInt8>) throws {
        var bundleIdentifier: String!
        var bundleIdentifierData: Data!
        var appVersion: String!
        var originalAppVersion: String!
        var originalPurchaseDate: Date?
        var purchases: [InAppPurchase] = []
        var opaqueValue: Data!
        var receiptHash: Data!
        var expirationDate: Date?
        var receiptCreationDate: Date!
        var ageRating: String!
        var environment: String!
        var appStoreID: Int?
        var transactionDate: Date?
        var fulfillmentToolVersion: Int?
        var developerID: Int?
        var downloadID: Int?
        var installerVersionID: Int?

        for att in set {
            guard let field = AppReceiptField(rawValue: att.type) else { continue }

            switch field {
            case .bundleIdentifier:
                bundleIdentifier = try String(att.value, as: .utf8)
                bundleIdentifierData = Data(att.value.bytes)
            case .appVersion:
                appVersion = try String(att.value, as: .utf8)
            case .opaqueValue:
                opaqueValue = Data(att.value.bytes)
            case .receiptHash:
                receiptHash = Data(att.value.bytes)
            case .inAppPurchaseReceipt:
                try purchases.append(InAppPurchase(berEncoded: att.value.bytes))
            case .originalAppVersion:
                originalAppVersion = try String(att.value, as: .utf8)
            case .originalAppPurchaseDate:
                originalPurchaseDate = try Date(att.value)
            case .expirationDate:
                expirationDate = try Date(att.value)
            case .receiptCreationDate:
                receiptCreationDate = try Date(att.value)
            case .ageRating:
                ageRating = try String(att.value, as: .ascii)
            case .environment:
                environment = try String(att.value, as: .utf8)
            case .appStoreID:
                let node = try DER.parse(att.value.bytes)
                appStoreID = try Int(derEncoded: node)
            case .transactionDate:
                transactionDate = try? Date(att.value)
            case .fulfillmentToolVersion:
                fulfillmentToolVersion = try Int(derEncoded: att.value.bytes)
            case .developerID:
                developerID = try Int(derEncoded: att.value.bytes)
            case .downloadID:
                downloadID = try Int(derEncoded: att.value.bytes)
            case .installerVersionID:
                installerVersionID = try Int(derEncoded: att.value.bytes)
            default:
                break
            }
        }

        self.init(
            bundleIdentifier: bundleIdentifier,
            appVersion: appVersion,
            originalAppVersion: originalAppVersion,
            originalPurchaseDate: originalPurchaseDate,
            purchases: purchases,
            expirationDate: expirationDate,
            bundleIdentifierData: bundleIdentifierData,
            opaqueValue: opaqueValue,
            receiptHash: receiptHash,
            creationDate: receiptCreationDate,
            ageRating: ageRating,
            environment: Environment(rawValue: environment),
            appStoreID: appStoreID,
            transactionDate: transactionDate,
            fulfillmentToolVersion: fulfillmentToolVersion,
            developerID: developerID,
            downloadID: downloadID,
            installerVersionID: installerVersionID
        )
    }
}

extension String {
    init(_ octetString: ASN1OctetString, as sourceEncoding: Encoding) throws {
        switch sourceEncoding {
        case Encoding.utf8:
            self = try String(ASN1UTF8String(derEncoded: octetString.bytes))
        case Encoding.ascii:
            self = try String(ASN1IA5String(derEncoded: octetString.bytes))
        default:
            fatalError("Unhandled string source encoding: \(sourceEncoding.rawValue)")
        }
    }
}

extension Date {
    init(_ octetString: ASN1OctetString) throws {
        let str = try ASN1IA5String(berEncoded: octetString.bytes)

        guard let date = Date.date(from: String(str)) else {
            throw ASN1Error.invalidASN1Object(reason: "Invalid date format")
        }

        self = date
    }
}
