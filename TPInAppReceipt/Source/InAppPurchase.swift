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
    
    public init()
    {
        originalTransactionIdentifier = ""
        productIdentifier = ""
        transactionIdentifier = ""
        purchaseDateString = ""
        originalPurchaseDateString = ""
        quantity = 0
    }
    
    public init(asn1Data: Data)
    {
        self.init()
        
        let purchase = ASN1Object(data: asn1Data)
        purchase.enumerateInAppReceiptAttributes { (attribute) in
            if let field = InAppReceiptField(rawValue: attribute.type)
            {
                var value = attribute.value.extractValue()
                
                if let v = value as? ASN1Object
                {
                    value = v.extractValue()
                }
                
                switch field
                {
                case .quantity:
                    quantity = value as! Int
                case .productIdentifier:
                    productIdentifier = value as! String
                case .transactionIdentifier:
                    transactionIdentifier = value as! String
                case .purchaseDate:
                    purchaseDateString = value as! String
                case .originalTransactionIdentifier:
                    originalTransactionIdentifier = value as! String
                case .originalPurchaseDate:
                    originalPurchaseDateString = value as! String
                case .subscriptionExpirationDate:
                    subscriptionExpirationDateString = value as? String
                case .cancellationDate:
                    cancellationDateString = value as? String
                case .webOrderLineItemID:
                    webOrderLineItemID = value as? Int
                default:
                    break
                }
            }
        }
    }
}

public extension InAppPurchase
{
    /// Purchase Date representation as a 'Date' object
    var purchaseDate: Date
    {
        return purchaseDateString.rfc3339date()!
    }
    
    /// Subscription Expiration Date representation as a 'Date' object. Returns `nil` if the purchase has been expired (in some cases)
    var subscriptionExpirationDate: Date?
    {
        assert(isRenewableSubscription, "\(productIdentifier) is not an auto-renewable subscription.")
       
        return subscriptionExpirationDateString?.rfc3339date()
    }
    
    /// A Boolean value indicating whether the purchase is renewable subscription.
    var isRenewableSubscription: Bool
    {
        return self.subscriptionExpirationDateString != nil
    }
    
    /// Check whether the subscription is active for a specific date
    ///
    /// - Parameter date: The date in which the auto-renewable subscription should be active.
    /// - Returns: true if the latest auto-renewable subscription is active for the given date, false otherwise.
    func isActiveAutoRenewableSubscription(forDate date: Date) -> Bool
    {
        assert(isRenewableSubscription, "\(productIdentifier) is not an auto-renewable subscription.")
        
        if(self.cancellationDateString != nil && self.cancellationDateString != "")
        {
            return false
        }
        
        guard let expirationDate = subscriptionExpirationDate else
        {
            return false
        }
        
        return date >= purchaseDate && date < expirationDate
    }
}
