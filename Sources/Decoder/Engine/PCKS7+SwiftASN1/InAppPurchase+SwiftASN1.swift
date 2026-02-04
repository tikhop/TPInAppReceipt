import Foundation
import SwiftASN1

extension InAppPurchase: BERImplicitlyTaggable {
    public static let defaultIdentifier: SwiftASN1.ASN1Identifier = .set

    public init(berEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        let attributes = try BER.set(
            of: InAppReceiptPayloadAttribute.self,
            identifier: identifier,
            rootNode: berEncoded
        )
        try self.init(set: attributes)
    }

    public init(derEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        try self.init(berEncoded: derEncoded, withIdentifier: identifier)
    }

    public func serialize(into _: inout DER.Serializer, withIdentifier _: SwiftASN1.ASN1Identifier) throws {}

    public init(set: [InAppReceiptPayloadAttribute]) throws {
        var originalTransactionIdentifier = ""
        var productIdentifier = ""
        var transactionIdentifier = ""
        var purchaseDate: Date!
        var originalPurchaseDate: Date?
        var quantity = 1
        var productType: InAppPurchase.`Type` = .unknown
        var subscriptionExpirationDate: Date? = nil
        var cancellationDate: Date? = nil
        var webOrderLineItemID: Int? = nil
        var subscriptionTrialPeriod = false
        var subscriptionIntroductoryPricePeriod = false
        var promotionalOfferIdentifier: String? = nil

        for att in set {
            guard let field = InAppPurchaseReceiptField(rawValue: att.type) else { continue }

            switch field {
            case .quantity:
                let node = try DER.parse(att.value.bytes)
                quantity = try Int(derEncoded: node)

            case .productIdentifier:
                productIdentifier = try String(att.value, as: .utf8)

            case .productType:
                let node = try DER.parse(att.value.bytes)
                let typeValue = try Int32(derEncoded: node)
                productType = Type(rawValue: typeValue) ?? .unknown

            case .transactionIdentifier:
                transactionIdentifier = (try? String(att.value, as: .utf8)) ?? ""

            case .purchaseDate:
                purchaseDate = try Date(att.value)

            case .originalTransactionIdentifier:
                originalTransactionIdentifier = try String(att.value, as: .utf8)

            case .originalPurchaseDate:
                originalPurchaseDate = try Date(att.value)

            case .subscriptionExpirationDate:
                subscriptionExpirationDate = try? Date(att.value)

            case .cancellationDate:
                cancellationDate = try? Date(att.value)

            case .webOrderLineItemID:
                let node = try DER.parse(att.value.bytes)
                webOrderLineItemID = try Int(derEncoded: node)

            case .subscriptionTrialPeriod:
                let node = try DER.parse(att.value.bytes)
                let value = try Int(derEncoded: node)
                subscriptionTrialPeriod = value != 0

            case .subscriptionIntroductoryPricePeriod:
                let node = try DER.parse(att.value.bytes)
                let value = try Int(derEncoded: node)
                subscriptionIntroductoryPricePeriod = value != 0

            case .promotionalOfferIdentifier:
                promotionalOfferIdentifier = try? String(att.value, as: .utf8)

            default:
                continue
            }
        }

        self.init(
            productIdentifier: productIdentifier,
            productType: productType,
            transactionIdentifier: transactionIdentifier,
            originalTransactionIdentifier: originalTransactionIdentifier,
            purchaseDate: purchaseDate,
            originalPurchaseDate: originalPurchaseDate,
            subscriptionExpirationDate: subscriptionExpirationDate,
            cancellationDate: cancellationDate,
            subscriptionTrialPeriod: subscriptionTrialPeriod,
            subscriptionIntroductoryPricePeriod: subscriptionIntroductoryPricePeriod,
            webOrderLineItemID: webOrderLineItemID,
            promotionalOfferIdentifier: promotionalOfferIdentifier,
            quantity: quantity
        )
    }
}
