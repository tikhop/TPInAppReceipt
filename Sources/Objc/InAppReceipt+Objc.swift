//
//  InAppReceipt+Objc.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 24.05.2021.
//  Copyright © 2020-2021 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import TPInAppReceipt

// MARK: - InAppReceipt

@objc(InAppReceipt) public class InAppReceipt_Objc: NSObject
{
	private var wrappedReceipt: InAppReceipt
	
	/// Creates and returns the 'InAppReceipt' instance from data object
	///
	/// - Returns: 'InAppReceipt' instance
	/// - throws: An error in the InAppReceipt domain, if `InAppReceipt` cannot be created.
	@objc public class func receipt(from data: Data) throws -> InAppReceipt_Objc
	{
		return try InAppReceipt_Objc(receiptData: data)
	}
	
	/// Creates and returns the 'InAppReceipt' instance from data object
	///
	/// - Returns: 'InAppReceipt' instance
	/// - throws: An error in the InAppReceipt domain, if `InAppReceipt` cannot be created.
	@objc public class func receipt(from data: Data) -> InAppReceipt_Objc?
	{
		return try? InAppReceipt_Objc(receiptData: data)
	}
	
	/// Creates and returns the 'InAppReceipt' instance using local receipt
	///
	/// - Returns: 'InAppReceipt' instance
	/// - throws: An error in the InAppReceipt domain, if `InAppReceipt` cannot be created.
	@objc public class func local() throws -> InAppReceipt_Objc
	{
		let data = try Bundle.main.appStoreReceiptData()
		return try InAppReceipt_Objc.receipt(from: data)
	}
	
	/// Creates and returns the 'InAppReceipt' instance using local receipt
	///
	/// - Returns: 'InAppReceipt' instance
	/// - throws: An error in the InAppReceipt domain, if `InAppReceipt` cannot be created.
	@objc public class func local() -> InAppReceipt_Objc?
	{
		guard let data = try? Bundle.main.appStoreReceiptData() else { return nil }
		return InAppReceipt_Objc.receipt(from: data)
	}
	
	///
	///
	/// Initialize a `InAppReceipt` with asn1 payload
	///
	/// - parameter receiptData: `Data` object that represents receipt
	@objc public init(receiptData: Data, rootCertPath: String? = nil) throws
	{
		self.wrappedReceipt = try InAppReceipt.init(receiptData: receiptData, rootCertPath: rootCertPath)
	}
}

@objc public extension InAppReceipt_Objc
{
	/// The app’s bundle identifier
	var bundleIdentifier: String
	{
		return wrappedReceipt.bundleIdentifier
	}
	
	/// The app’s version number
	var appVersion: String
	{
		return wrappedReceipt.appVersion
	}
	
	/// The version of the app that was originally purchased.
	var originalAppVersion: String
	{
		return wrappedReceipt.originalAppVersion
	}
	
	/// In-app purchase's receipts
	var purchases: [InAppPurchase_Objc]
	{
		return wrappedReceipt.purchases.map { .init(purchase: $0) }
	}
	
	/// Returns all auto renewable `InAppPurchase`s,
	var autoRenewablePurchases: [InAppPurchase_Objc]
	{
		return wrappedReceipt.purchases.filter({ $0.isRenewableSubscription }).map { .init(purchase: $0) }
	}
	
	/// Returns all ACTIVE auto renewable `InAppPurchase`s,
	///
	var activeAutoRenewableSubscriptionPurchases: [InAppPurchase_Objc]
	{
		return wrappedReceipt.purchases.filter({ $0.isRenewableSubscription && $0.isActiveAutoRenewableSubscription(forDate: Date()) }).map { .init(purchase: $0) }
		
	}
	
	/// The date that the app receipt expires
	var expirationDate: Date?
	{
		return wrappedReceipt.expirationDate
	}
	
	/// Returns `true` if any purchases exist, `false` otherwise
	var hasPurchases: Bool
	{
		return purchases.count > 0
	}
	
	/// Returns `true` if any Active Auto Renewable purchases exist, `false` otherwise
	var hasActiveAutoRenewablePurchases: Bool
	{
		return activeAutoRenewableSubscriptionPurchases.count > 0
	}
	
	
	var creationDate: Date
	{
		return wrappedReceipt.creationDate
	}
	
	var ageRating: String
	{
		return wrappedReceipt.ageRating
	}
	/// In App Receipt in base64
	var base64: String
	{
		return wrappedReceipt.base64
	}
	
	/// Return original transaction identifier if there is a purchase for a specific product identifier
	///
	/// - parameter productIdentifier: Product name
	@objc func originalTransactionIdentifier(ofProductIdentifier productIdentifier: String) -> String?
	{
		return purchases(ofProductIdentifier: productIdentifier).first?.originalTransactionIdentifier
	}
	
	/// Returns `true` if there is a purchase for a specific product identifier, `false` otherwise
	///
	/// - parameter productIdentifier: Product name
	@objc func containsPurchase(ofProductIdentifier productIdentifier: String) -> Bool
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
	@objc func purchases(ofProductIdentifier productIdentifier: String,
				   sortedBy sort: ((InAppPurchase_Objc, InAppPurchase_Objc) -> Bool)? = nil) -> [InAppPurchase_Objc]
	{
		let filtered: [InAppPurchase_Objc] = purchases.filter({
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
	@objc func activeAutoRenewableSubscriptionPurchases(ofProductIdentifier productIdentifier: String, forDate date: Date) -> InAppPurchase_Objc?
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
	
	/// Returns the last `InAppPurchase` if there is one for a specific product identifier,
	/// `nil` otherwise
	///
	/// - parameter productIdentifier: Product name
	@objc func lastAutoRenewableSubscriptionPurchase(ofProductIdentifier productIdentifier: String) -> InAppPurchase_Objc?
	{
		var purchase: InAppPurchase_Objc? = nil
		let filtered = purchases(ofProductIdentifier: productIdentifier)
		
		var lastInterval: TimeInterval = 0
		for iap in filtered
		{
			if !(iap.productIdentifier == productIdentifier) {
				continue
			}
			
			if let thisInterval = iap.subscriptionExpirationDate?.timeIntervalSince1970 {
				if purchase == nil || thisInterval > lastInterval {
					purchase = iap
					lastInterval = thisInterval
				}
			}
		}
		
		return purchase
	}
	
	/// Returns true if there is an active subscription for a specific product identifier on the date specified,
	/// false otherwise
	///
	/// - parameter productIdentifier: Product name
	/// - parameter date: Date to check subscription against
	@objc func hasActiveAutoRenewableSubscription(ofProductIdentifier productIdentifier: String, forDate date: Date) -> Bool
	{
		return activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: productIdentifier, forDate: date) != nil
	}
}

// MARK: - InAppPurchase

@objc(InAppPurchase) public class InAppPurchase_Objc: NSObject
{
	@objc public enum `Type`: Int32
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
	
	private let purchase: InAppPurchase
	
	/// The product identifier which purchase related to
	@objc public var productIdentifier: String { purchase.productIdentifier }
	
	/// Product type
	@objc public var productType: Type { Type(rawValue: purchase.productType.rawValue) ?? .unknown }
	
	/// Transaction identifier
	@objc public var transactionIdentifier: String { purchase.transactionIdentifier }
	
	/// Original Transaction identifier
	@objc public var originalTransactionIdentifier: String { purchase.originalTransactionIdentifier }
	
	/// Purchase Date
	@objc public var purchaseDate: Date { purchase.purchaseDate }
	
	/// Original Purchase Date
	@objc public var originalPurchaseDate: Date { purchase.originalPurchaseDate }
	
	/// Subscription Expiration Date. Returns `nil` if the purchase has been expired (in some cases)
	@objc public var subscriptionExpirationDate: Date? { purchase.subscriptionExpirationDate }
	
	/// Cancellation Date. Returns `nil` if the purchase is not a renewable subscription
	@objc public var cancellationDate: Date? { purchase.cancellationDate }
	
	/// This value is `true`if the customer’s subscription is currently in the free trial period, or `false` if not.
	@objc public var subscriptionTrialPeriod: Bool { purchase.subscriptionTrialPeriod }
	
	/// This value is `true` if the customer’s subscription is currently in an introductory price period, or `false` if not.
	@objc public var subscriptionIntroductoryPricePeriod: Bool { purchase.subscriptionIntroductoryPricePeriod }
	
	/// A unique identifier for purchase events across devices, including subscription-renewal events. This value is the primary key for identifying subscription purchases.
	@objc public var webOrderLineItemID: Int { purchase.webOrderLineItemID ?? NSNotFound }
	
	/// The value is an identifier of the subscription offer that the user redeemed.
	/// Returns `nil` if  the user didn't use any subscription offers.
	@objc public var promotionalOfferIdentifier: String? { purchase.promotionalOfferIdentifier }
	
	/// The number of consumable products purchased
	/// The default value is `1` unless modified with a mutable payment. The maximum value is 10.
	@objc public var quantity: Int { purchase.quantity }
	
	init(purchase: InAppPurchase)
	{
		self.purchase = purchase
	}
}

@objc public extension InAppPurchase_Objc
{
	/// A Boolean value indicating whether the purchase is renewable subscription.
	@objc var isRenewableSubscription: Bool
	{
		return purchase.isRenewableSubscription
	}
	
	/// Check whether the subscription is active for a specific date
	///
	/// - Parameter date: The date in which the auto-renewable subscription should be active.
	/// - Returns: true if the latest auto-renewable subscription is active for the given date, false otherwise.
	@objc func isActiveAutoRenewableSubscription(forDate date: Date) -> Bool
	{
		return purchase.isActiveAutoRenewableSubscription(forDate: date)
	}
}

// MARK: - Validation

/// A InAppReceipt extension helps to validate the receipt
@objc public extension InAppReceipt_Objc
{
	/// Verify In App Receipt
	///
	/// - throws: An error in the InAppReceipt domain, if verification fails
	@objc func verify() throws
	{
		try wrappedReceipt.verifyHash()
		try wrappedReceipt.verifyBundleIdentifierAndVersion()
		try wrappedReceipt.verifySignature()
	}
	
	/// Verify only hash
	/// Should be equal to `receiptHash` value
	///
	/// - throws: An error in the InAppReceipt domain, if verification fails
	@objc func verifyHash() throws
	{
		try wrappedReceipt.verifyHash()
	}
	
	/// Verify that the bundle identifier in the receipt matches a hard-coded constant containing the CFBundleIdentifier value you expect in the Info.plist file. If they do not match, validation fails.
	/// Verify that the version identifier string in the receipt matches a hard-coded constant containing the CFBundleShortVersionString value (for macOS) or the CFBundleVersion value (for iOS) that you expect in the Info.plist file.
	///
	///
	/// - throws: An error in the InAppReceipt domain, if verification fails
	@objc func verifyBundleIdentifierAndVersion() throws
	{
		try wrappedReceipt.verifyBundleIdentifierAndVersion()
	}
	
	/// Verify signature inside pkcs7 container
	///
	/// - throws: An error in the InAppReceipt domain, if verification can't be completed
	@objc func verifySignature() throws
	{
		try wrappedReceipt.verifySignature()
	}
}
