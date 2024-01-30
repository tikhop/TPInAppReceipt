//
//  InAppReceipt.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 28/09/16.
//  Copyright © 2016-2021 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import ASN1Swift

public struct InAppReceiptField
{
	static let environment: Int32 = 0 // Sandbox, Production, ProductionSandbox
	static let bundleIdentifier: Int32 = 2
	static let appVersion: Int32 = 3
	static let opaqueValue: Int32 = 4
	static let receiptHash: Int32 = 5 // SHA-1 Hash
	static let ageRating: Int32 = 10 // SHA-1 Hash
	static let receiptCreationDate: Int32 = 12
	static let inAppPurchaseReceipt: Int32 = 17 // The receipt for an in-app purchase.
    static let originalAppPurchaseDate: Int32 = 18
	static let originalAppVersion: Int32 = 19
	static let expirationDate: Int32 = 21
    
    
	static let quantity: Int32 = 1701
	static let productIdentifier: Int32 = 1702
	static let transactionIdentifier: Int32 = 1703
	static let purchaseDate: Int32 = 1704
	static let originalTransactionIdentifier: Int32 = 1705
	static let originalPurchaseDate: Int32 = 1706
	static let productType: Int32 = 1707
	static let subscriptionExpirationDate: Int32 = 1708
	static let webOrderLineItemID: Int32 = 1711
	static let cancellationDate: Int32 = 1712
	static let subscriptionTrialPeriod: Int32 = 1713
	static let subscriptionIntroductoryPricePeriod: Int32 = 1719
	static let promotionalOfferIdentifier: Int32 = 1721
}

public class InAppReceipt
{
    /// PKCS7 container
    internal var receipt: _InAppReceipt
    
    /// Payload of the receipt.
    /// Payload object contains all meta information.
	internal var payload: InAppReceiptPayload { receipt.payload }
    
    /// root certificate path, used to check signature
    /// added for testing purpose , as unit test can't read main bundle
    internal var rootCertificatePath: String?
    
	/// Raw data
	private var rawData: Data
	
	/// Initialize a `InAppReceipt` using local receipt
	public convenience init() throws
	{
		let data = try Bundle.main.appStoreReceiptData()
		try self.init(receiptData: data)
	}
	
	///
	///
    /// Initialize a `InAppReceipt` with asn1 payload
    ///
    /// - parameter receiptData: `Data` object that represents receipt
	public init(receiptData: Data, rootCertPath: String? = nil) throws
	{
		self.receipt = try _InAppReceipt(rawData: receiptData)
		self.rawData = receiptData
		
		#if DEBUG
		let certificateName = "StoreKitTestCertificate"
		#else
		let certificateName = "AppleIncRootCertificate"
		#endif
		
		self.rootCertificatePath = rootCertPath ?? Bundle.lookUp(forResource: certificateName, ofType: "cer")
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
    
    /// Returns all auto renewable `InAppPurchase`s,
    var autoRenewablePurchases: [InAppPurchase]
    {
        return purchases.filter({ $0.isRenewableSubscription })
    }
    
    /// Returns all ACTIVE auto renewable `InAppPurchase`s,
    ///
    var activeAutoRenewableSubscriptionPurchases: [InAppPurchase]
    {
        return purchases.filter({ $0.isRenewableSubscription && $0.isActiveAutoRenewableSubscription(forDate: Date()) })
        
    }
    
    /// The date that the app receipt expires
    var expirationDate: Date?
    {
		return payload.expirationDate
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
		return payload.creationDate
    }
    
	var ageRating: String
	{
		return payload.ageRating
	}
	
    /// In App Receipt in base64
    var base64: String
    {
		return rawData.base64EncodedString()
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

    /// Returns the last `InAppPurchase` if there is one for a specific product identifier,
    /// `nil` otherwise
    ///
    /// - parameter productIdentifier: Product name
    func lastAutoRenewableSubscriptionPurchase(ofProductIdentifier productIdentifier: String) -> InAppPurchase?
    {
        var purchase: InAppPurchase? = nil
        let filtered = purchases(ofProductIdentifier: productIdentifier)
        
        var lastInterval: TimeInterval = 0
        for iap in filtered
		{            
            if let thisInterval = iap.subscriptionExpirationDate?.timeIntervalSince1970
			{
                if purchase == nil || thisInterval > lastInterval
				{
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

public extension InAppReceipt
{
	/// signature for validation
	var signature: Data?
	{
		return receipt.signatureData
	}
	
	var worldwideDeveloperCertificateData: Data?
	{
		return receipt.worldwideDeveloperCertificateData
	}
	
	var iTunesCertificateData: Data?
	{
		return receipt.iTunesCertificateData
	}
	
	var iTunesPublicKeyData: Data?
	{
		return receipt.iTunesPublicKeyData
	}
	
	var payloadRawData: Data
	{
		return payload.rawData
	}
}
