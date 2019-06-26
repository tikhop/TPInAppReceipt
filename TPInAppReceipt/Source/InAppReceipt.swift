//
//  InAppReceipt.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 28/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation

public enum InAppReceiptField: Int
{
    case bundleIdentifier = 2
    case appVersion = 3
    case opaqueValue = 4
    case receiptHash = 5 // SHA-1 Hash
    case inAppPurchaseReceipt = 17 // The receipt for an in-app purchase.
    case originalAppVersion = 19
    case expirationDate = 21
    case receiptCreationDate = 12
    
    case quantity = 1701
    case productIdentifier = 1702
    case transactionIdentifier = 1703
    case purchaseDate = 1704
    case originalTransactionIdentifier = 1705
    case originalPurchaseDate = 1706
    case subscriptionExpirationDate = 1708
    case webOrderLineItemID = 1711
    case cancellationDate = 1712
}

public struct InAppReceipt
{
    /// Raw pkcs7 container
    internal var pkcs7Container: PKCS7Wrapper
    
    /// Payload of the receipt.
    /// Payload object contains all meta information.
    internal var payload: InAppReceiptPayload
    
    /// Initialize a `InAppReceipt` with asn1 payload
    ///
    /// - parameter receiptData: `Data` object that represents receipt
    public init(receiptData: Data) throws
    {
        let pkcs7 = try PKCS7Wrapper(receipt: receiptData)
        self.init(pkcs7: pkcs7)
    }
    
    /// Initialize a `InAppReceipt` with asn1 payload
    ///
    /// - parameter pkcs7: `PKCS7Wrapper` pkcs7 container of the receipt 
    init(pkcs7: PKCS7Wrapper)
    {
        self.init(pkcs7: pkcs7, payload: InAppReceiptPayload(asn1Data: pkcs7.extractInAppPayload()!))
    }
    
    init(pkcs7: PKCS7Wrapper, payload: InAppReceiptPayload)
    {
        self.pkcs7Container = pkcs7
        self.payload = payload
    }
}

public extension InAppReceipt
{
    /// The app’s bundle identifier
    var bundleIdentifier: String
    {
        return payload.bundleIdentifier
    }
    
    /// The app’s version number
    var appVersion: String
    {
        return payload.appVersion
    }
    
    /// The version of the app that was originally purchased.
    var originalAppVersion: String
    {
        return payload.originalAppVersion
    }
    
    /// In-app purchase's receipts
    var purchases: [InAppPurchase]
    {
        return payload.purchases
    }
    
    /// The date that the app receipt expires
    var expirationDate: String?
    {
        return payload.expirationDate
    }
    
    /// Returns `true` if any purchases exist, `false` otherwise
    var hasPurchases: Bool
    {
        return purchases.count > 0
    }
    
    /// The date when the app receipt was created.
    var creationDate: String
    {
        return payload.creationDate
    }
    
    /// Return original transaction identifier if there is a purchase for a specific product identifier
    ///
    /// - parameter productIdentifier: Product name
    func originalTransactionIdentifier(ofProductIdentifier productIdentifier: String) -> String?
    {
        return purchases(ofProductIdentifier: productIdentifier).first?.originalTransactionIdentifier
    }
    
    /// Returns `true` if there is a purchase for a specific product identifier, `false` otherwise
    ///
    /// - parameter productIdentifier: Product name
    func containsPurchase(ofProductIdentifier productIdentifier: String) -> Bool
    {
        for item in purchases
        {
            if item.productIdentifier == productIdentifier
            {
                return true
            }
        }
        
        return false
    }
    
    /// Returns `[InAppPurchase]` if there are purchases for a specific product identifier,
    /// empty array otherwise
    ///
    /// - parameter productIdentifier: Product name
    /// - parameter sort: Sorting block
    func purchases(ofProductIdentifier productIdentifier: String,
                          sortedBy sort: ((InAppPurchase, InAppPurchase) -> Bool)? = nil) -> [InAppPurchase]
    {
        let filtered: [InAppPurchase] = purchases.filter({
            return $0.productIdentifier == productIdentifier
        })
        
        if let sort = sort
        {
            return filtered.sorted(by: {
                return sort($0, $1)
            })
        }else{
            return filtered.sorted(by: {
                return $0.purchaseDate > $1.purchaseDate
            })
        }
        
        
    }
    
    /// Returns `InAppPurchase` if there is a purchase for a specific product identifier,
    /// `nil` otherwise
    ///
    /// - parameter productIdentifier: Product name
    func activeAutoRenewableSubscriptionPurchases(ofProductIdentifier productIdentifier: String, forDate date: Date) -> InAppPurchase?
    {
        let filtered = purchases(ofProductIdentifier: productIdentifier)
        
        for purchase in filtered
        {
            if purchase.isActiveAutoRenewableSubscription(forDate: date)
            {
                return purchase
            }
        }

        return nil

    }

    /// Returns true if there is an active subscription for a specific product identifier on the date specified,
    /// false otherwise
    ///
    /// - parameter productIdentifier: Product name
    /// - parameter date: Date to check subscription against
    func hasActiveAutoRenewableSubscription(ofProductIdentifier productIdentifier: String, forDate date: Date) -> Bool
    {
        return activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: productIdentifier, forDate: date) != nil
    }
}

internal extension InAppReceipt
{
    /// Used to validate the receipt
    var bundleIdentifierData: Data
    {
        return payload.bundleIdentifierData
    }
    
    /// An opaque value used, with other data, to compute the SHA-1 hash during validation.
    var opaqueValue: Data
    {
        return payload.opaqueValue
    }
    
    /// A SHA-1 hash, used to validate the receipt.
    var receiptHash: Data
    {
        return payload.receiptHash
    }
}
