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
    case receiptHash = 5 //SHA-1 Hash
    case inAppPurchaseReceipt = 17
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
    public var bundleIdentifier: String
    public var appVersion: String
    public var originalAppVersion: String
    public var purchases: [InAppPurchase]
    public var expirationDate: String? = nil
    
    public var bundleIdentifierData: Data
    public var opaqueValue: Data
    public var receiptHash: Data
    
    public init(ans1Data: Data)
    {
        bundleIdentifier = ""
        appVersion = ""
        originalAppVersion = ""
        purchases = []
        bundleIdentifierData = Data()
        opaqueValue = Data()
        receiptHash = Data()
        
        ans1Data.enumerateASN1Attributes { (attributes) in
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
                    purchases.append(InAppPurchase(ans1Data: attributes.data))
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

public struct InAppPurchase
{
    public var quantity: Int
    public var productIdentifier: String
    public var transactionIdentifier: String
    public var originalTransactionIdentifier: String
    public var purchaseDateString: String
    public var originalPurchaseDateString: String
    public var subscriptionExpirationDateString: String? = nil
    public var cancellationDateString: String? = nil
    public var webOrderLineItemID: Int? = nil
    
    public init(ans1Data: Data)
    {
        originalTransactionIdentifier = ""
        productIdentifier = ""
        transactionIdentifier = ""
        purchaseDateString = ""
        originalPurchaseDateString = ""
        quantity = 0
        
        ans1Data.enumerateASN1Attributes { (attributes) in
            if let field = InAppReceiptField(rawValue: attributes.type)
            {
                let length = attributes.data.count
                
                var bytes = [UInt8](repeating:0, count: length)
                attributes.data.copyBytes(to: &bytes, count: length)
                
                var ptr = UnsafePointer<UInt8>?(bytes)
                
                switch field
                {
                case .quantity:
                    quantity = asn1ReadInteger(&ptr, bytes.count)
                
                case .productIdentifier:
                    productIdentifier = asn1ReadUTF8String(&ptr, bytes.count)!
                
                case .transactionIdentifier:
                    transactionIdentifier = asn1ReadUTF8String(&ptr, bytes.count)!
                
                case .purchaseDate:
                    purchaseDateString = asn1ReadASCIIString(&ptr, bytes.count)!
                
                case .originalTransactionIdentifier:
                    originalTransactionIdentifier = asn1ReadUTF8String(&ptr, bytes.count)!
                
                case .originalPurchaseDate:
                    originalPurchaseDateString = asn1ReadASCIIString(&ptr, bytes.count)!
                
                case .subscriptionExpirationDate:
                    subscriptionExpirationDateString = asn1ReadASCIIString(&ptr, bytes.count)
                
                case .cancellationDate:
                    cancellationDateString = asn1ReadASCIIString(&ptr, bytes.count)
                
                case .webOrderLineItemID:
                    webOrderLineItemID = asn1ReadInteger(&ptr, bytes.count)
                
                default:
                    print("attribute.type = \(attributes.type))")
                    asn1ConsumeObject(&ptr, bytes.count)
                }
            }
        }
    }
}

public extension InAppReceipt
{
    public var hasPurchases: Bool
    {
        return purchases.count > 0
    }
    
    public func originalTransactionIdentifier(ofProductIdentifier productIdentifier: String) -> String?
    {
        return purchases(ofProductIdentifier: productIdentifier).first?.originalTransactionIdentifier
    }
    
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

public extension InAppPurchase
{
    public var purchaseDate: Date
    {
        return purchaseDateString.date()
    }
    
    public var subscriptionExpirationDate: Date
    {
        assert(isRenewableSubscription, "\(productIdentifier) is not an auto-renewable subscription.")
        
        return subscriptionExpirationDateString!.date()
    }
    
    public var isRenewableSubscription: Bool
    {
        return self.subscriptionExpirationDateString != nil
    }
    
    public func isActiveAutoRenewableSubscription(forDate date: Date) -> Bool
    {
        assert(isRenewableSubscription, "\(productIdentifier) is not an auto-renewable subscription.")
        
        if(self.cancellationDateString != nil)
        {
            return false
        }
        
        return purchaseDate.compare(date) == .orderedDescending && date.compare(subscriptionExpirationDate) != .orderedDescending
    }
}
