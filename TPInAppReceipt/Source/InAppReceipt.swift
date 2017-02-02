//
//  InAppReceipt.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 28/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import openssl

public enum InAppReceiptField: Int
{
    case bundleIdentifier = 2
    case appVersion = 3
    case opaqueValue = 4
    case receiptHash = 5 // SHA-1 Hash
    case inAppPurchaseReceipt = 17 // The receipt for an in-app purchase.
    case originalAppVersion = 19
    case expirationDate = 21
    
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
        self.pkcs7Container = pkcs7
        self.payload = InAppReceiptPayload(asn1Data: pkcs7.extractASN1Data())
    }
}

public extension InAppReceipt
{
    /// The app’s bundle identifier
    public var bundleIdentifier: String
    {
        return payload.bundleIdentifier
    }
    
    /// The app’s version number
    public var appVersion: String
    {
        return payload.appVersion
    }
    
    /// The version of the app that was originally purchased.
    public var originalAppVersion: String
    {
        return payload.originalAppVersion
    }
    
    /// In-app purchase's receipts
    public var purchases: [InAppPurchase]
    {
        return payload.purchases
    }
    
    /// The date that the app receipt expires
    public var expirationDate: String?
    {
        return payload.expirationDate
    }
    
    /// Returns `true` if any purchases exist, `false` otherwise
    public var hasPurchases: Bool
    {
        return purchases.count > 0
    }
    
    /// Return original transaction identifier if there is a purchase for a specific product identifier
    ///
    /// - parameter productIdentifier: Product name
    public func originalTransactionIdentifier(ofProductIdentifier productIdentifier: String) -> String?
    {
        return purchases(ofProductIdentifier: productIdentifier).first?.originalTransactionIdentifier
    }
    
    /// Returns `true` if there is a purchase for a specific product identifier, `false` otherwise
    ///
    /// - parameter productIdentifier: Product name
    public func containsPurchase(ofProductIdentifier productIdentifier: String) -> Bool
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
    public func purchases(ofProductIdentifier productIdentifier: String, sortedBy sort: ((InAppPurchase, InAppPurchase) -> Bool)? = nil) -> [InAppPurchase]
    {
        let filtered: [InAppPurchase] = purchases.filter({ return $0.productIdentifier == productIdentifier })
        
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
    public func activeAutoRenewableSubscriptionPurchases(ofProductIdentifier productIdentifier: String, forDate date: Date) -> InAppPurchase?
    {
        let filtered = purchases(ofProductIdentifier: productIdentifier) {
            return $0.subscriptionExpirationDate > $1.subscriptionExpirationDate
        }
        
        guard let lastPurchase = filtered.first else
        {
            return nil
        }
        
        return lastPurchase.isActiveAutoRenewableSubscription(forDate: date) ? lastPurchase : nil
    }
}

internal extension InAppReceipt
{
    /// Used to validate the receipt
    internal var bundleIdentifierData: Data
    {
        return payload.bundleIdentifierData
    }
    
    /// An opaque value used, with other data, to compute the SHA-1 hash during validation.
    internal var opaqueValue: Data
    {
        return payload.opaqueValue
    }
    
    /// A SHA-1 hash, used to validate the receipt.
    internal var receiptHash: Data
    {
        return payload.receiptHash
    }
    
    /// Computed SHA-1 hash, used to validate the receipt.
    /// Should be equal to `receiptHash` value
    internal var computedHashData: Data
    {
        let uuidData = DeviceGUIDRetriever.guid()
        let opaqueData = opaqueValue
        let bundleIdData = bundleIdentifierData
        
        var hash = Array<CUnsignedChar>(repeating: 0, count: 20)
        var ctx = SHA_CTX()
        
        SHA1_Init(&ctx)
        SHA1_Update(&ctx, uuidData.pointer, uuidData.count)
        SHA1_Update(&ctx, opaqueData.pointer, opaqueData.count)
        SHA1_Update(&ctx, bundleIdData.pointer, bundleIdData.count)
        SHA1_Final(&hash, &ctx);
        
        return Data(bytes: &hash, count: hash.count)
    }
}
