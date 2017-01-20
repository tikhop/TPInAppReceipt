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
    /// The app’s bundle identifier
    public var bundleIdentifier: String
    
    /// The app’s version number
    public var appVersion: String
    
    /// The version of the app that was originally purchased.
    public var originalAppVersion: String
    
    /// In-app purchase's receipts
    public var purchases: [InAppPurchase]
    
    /// The date that the app receipt expires
    public var expirationDate: String? = nil
    
    /// Used to validate the receipt
    public var bundleIdentifierData: Data
    
    /// An opaque value used, with other data, to compute the SHA-1 hash during validation.
    public var opaqueValue: Data
    
    /// A SHA-1 hash, used to validate the receipt.
    public var receiptHash: Data
    
    init(asn1Data: Data)
    {
        bundleIdentifier = ""
        appVersion = ""
        originalAppVersion = ""
        purchases = []
        bundleIdentifierData = Data()
        opaqueValue = Data()
        receiptHash = Data()
        
        asn1Data.enumerateASN1Attributes { (attributes) in
            if let field = InAppReceiptField(rawValue: attributes.type)
            {
                let length = attributes.data.count
                
                var bytes = [UInt8](repeating:0, count: length)
                attributes.data.copyBytes(to: &bytes, count: length)
                
                var ptr = UnsafePointer<UInt8>?(bytes)
                
                switch field
                {
                case .bundleIdentifier:
                    bundleIdentifierData = Data(bytes: bytes, count: length)
                    bundleIdentifier = asn1ReadUTF8String(&ptr, bytes.count)!
                case .appVersion:
                    appVersion = asn1ReadUTF8String(&ptr, bytes.count)!
                case .opaqueValue:
                    opaqueValue = Data(bytes: bytes, count: length)
                case .receiptHash:
                    receiptHash = Data(bytes: bytes, count: length)
                case .inAppPurchaseReceipt:
                    purchases.append(InAppPurchase(asn1Data: attributes.data))
                case .originalAppVersion:
                    originalAppVersion = asn1ReadUTF8String(&ptr, bytes.count)!
                case .expirationDate:
                    let str = asn1ReadASCIIString(&ptr, bytes.count)
                    expirationDate = str
                default:
                    print("attribute.type = \(attributes.type))")
                }
            }
        }
    }
}

public extension InAppReceipt
{
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

