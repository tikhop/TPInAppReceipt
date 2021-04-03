//
//  InAppPurchase.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 19/01/17.
//  Copyright © 2017-2021 Pavel Tikhonenko. All rights reserved.
//

import Foundation

public struct InAppPurchase
{
	public enum `Type`: Int32
	{
		/// Type that we can't recognize for some reason
		case unknown = -1
		
		/// Type that customers purchase once. They don't expire.
		case nonConsumable
		
		/// Type that are depleted after one use. Customers can purchase them multiple times.
		case consumable
		
		/// Type that customers purchase once and that renew automatically on a recurring basis until customers decide to cancel.
		case nonRenewingSubscription
		
		/// Type that customers purchase and it provides access over a limited duration and don't renew automatically. Customers can purchase them again.
		case autoRenewableSubscription
	}
	
    /// The product identifier which purchase related to
    public var productIdentifier: String
    
	/// Product type
	public var productType: Type = .unknown
	
    /// Transaction identifier
    public var transactionIdentifier: String
    
    /// Original Transaction identifier
    public var originalTransactionIdentifier: String
    
    /// Purchase Date
    public var purchaseDate: Date
    
    /// Original Purchase Date. Returns `nil` when testing with StoreKitTest
    public var originalPurchaseDate: Date! = nil
    
	/// Subscription Expiration Date. Returns `nil` if the purchase has been expired (in some cases)
    public var subscriptionExpirationDate: Date? = nil
    
    /// Cancellation Date. Returns `nil` if the purchase is not a renewable subscription
    public var cancellationDate: Date? = nil

    /// This value is `true`if the customer’s subscription is currently in the free trial period, or `false` if not.
    public var subscriptionTrialPeriod: Bool = false
    
    /// This value is `true` if the customer’s subscription is currently in an introductory price period, or `false` if not.
    public var subscriptionIntroductoryPricePeriod: Bool = false
    
    /// A unique identifier for purchase events across devices, including subscription-renewal events. This value is the primary key for identifying subscription purchases.
    public var webOrderLineItemID: Int? = nil
    
	/// The value is an identifier of the subscription offer that the user redeemed.
	/// Returns `nil` if  the user didn't use any subscription offers.
	public var promotionalOfferIdentifier: String? = nil
	
    /// The number of consumable products purchased
	/// The default value is `1` unless modified with a mutable payment. The maximum value is 10.
    public var quantity: Int = 1
}

public extension InAppPurchase
{
    /// A Boolean value indicating whether the purchase is renewable subscription.
    var isRenewableSubscription: Bool
    {
        return subscriptionExpirationDate != nil
    }
    
    /// Check whether the subscription is active for a specific date
    ///
    /// - Parameter date: The date in which the auto-renewable subscription should be active.
    /// - Returns: true if the latest auto-renewable subscription is active for the given date, false otherwise.
    func isActiveAutoRenewableSubscription(forDate date: Date) -> Bool
    {
        assert(isRenewableSubscription, "\(productIdentifier) is not an auto-renewable subscription.")
		
        if cancellationDate != nil
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
