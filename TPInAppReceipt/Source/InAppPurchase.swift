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
    /// The product identifier which purchase related to
    public var productIdentifier: String
    
    /// Transaction identifier
    public var transactionIdentifier: String
    
    /// Original Transaction identifier
    public var originalTransactionIdentifier: String
    
    /// Purchase Date in string format
    public var purchaseDateString: String
    
    /// Original Purchase Date in string format
    public var originalPurchaseDateString: String
    
    /// Subscription Expiration Date in string format. Returns `nil` if the purchase is not a renewable subscription
    public var subscriptionExpirationDateString: String? = nil
    
    /// Cancellation Date in string format. Returns `nil` if the purchase is not a renewable subscription
    public var cancellationDateString: String? = nil
    
    ///
    public var webOrderLineItemID: Int? = nil
    
    /// Quantity
    public var quantity: Int
    
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
    /// Purchase Date representation as a 'Date' object
    public var purchaseDate: Date
    {
        return purchaseDateString.rfc3339date()
    }
    
    /// Subscription Expiration Date representation as a 'Date' object
    public var subscriptionExpirationDate: Date
    {
        assert(isRenewableSubscription, "\(productIdentifier) is not an auto-renewable subscription.")
        
        return subscriptionExpirationDateString!.rfc3339date()
    }
    
    /// A Boolean value indicating whether the purchase is renewable subscription.
    public var isRenewableSubscription: Bool
    {
        return self.subscriptionExpirationDateString != nil
    }
    
    /// Check whether the subscription is active for a specific date
    ///
    /// - Parameter date: The date in which the auto-renewable subscription should be active.
    /// - Returns: true if the latest auto-renewable subscription is active for the given date, false otherwise.
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
