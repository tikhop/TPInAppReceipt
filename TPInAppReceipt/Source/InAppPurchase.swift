//
//  InAppPurchase.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 19/01/17.
//  Copyright © 2017 Pavel Tikhonenko. All rights reserved.
//

import Foundation

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
    
    public init(asn1Data: Data)
    {
        originalTransactionIdentifier = ""
        productIdentifier = ""
        transactionIdentifier = ""
        purchaseDateString = ""
        originalPurchaseDateString = ""
        quantity = 0
        
        asn1Data.enumerateASN1Attributes { (attributes) in
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

public extension InAppPurchase
{
    public var purchaseDate: Date
    {
        return purchaseDateString.rfc3339date()
    }
    
    public var subscriptionExpirationDate: Date
    {
        assert(isRenewableSubscription, "\(productIdentifier) is not an auto-renewable subscription.")
        
        return subscriptionExpirationDateString!.rfc3339date()
    }
    
    public var isRenewableSubscription: Bool
    {
        return self.subscriptionExpirationDateString != nil
    }
    
    public func isActiveAutoRenewableSubscription(forDate date: Date) -> Bool
    {
        assert(isRenewableSubscription, "\(productIdentifier) is not an auto-renewable subscription.")
        
        if(self.cancellationDateString != nil && self.cancellationDateString != "")
        {
            return false
        }
        
        return purchaseDate.compare(date) == .orderedAscending && date.compare(subscriptionExpirationDate) != .orderedDescending
    }
}
