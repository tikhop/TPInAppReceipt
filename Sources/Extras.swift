//
//  Extras.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 13.02.2020.
//  Copyright © 2021 Pavel Tikhonenko. All rights reserved.
//

#if canImport(StoreKit)

import Foundation
import StoreKit

@available(watchOSApplicationExtension 6.2, *)
fileprivate var refreshSession: RefreshSession?

@available(tvOS 12.0, *)
@available(macOS 10.14, *)
@available(iOS 12.0, *)
public class SKSubscriptionGroup
{
	let identifier: GroupIdentifier
	var products: Set<SKProduct> = []
	
	init(with identifier: GroupIdentifier)
	{
		self.identifier = identifier
		self.products = []
	}
	
	init(with products: Set<SKProduct>)
	{
		guard let gid = products.first?.subscriptionGroupIdentifier else
		{
			fatalError("All products must have subscriptionGroupIdentifier")
		}
		
		self.identifier = gid
		self.products = products
	}
	
	func insert(product: SKProduct)
	{
		if identifier != product.subscriptionGroupIdentifier
		{
			fatalError("`Product.subscriptionGroupIdentifier` must be equal to current identifier")
		}
		
		products.insert(product)
	}
	
	func contains(_ productIdentifier: String) -> Bool
	{
		return products.contains(where: { $0.productIdentifier == productIdentifier })
	}
}

public typealias GroupIdentifier = String

@available(macOS 10.14, *)
public extension SKProductsResponse
{
	/// Build a `SKSubscriptionGroup` object
	///
	/// We assume that all retrieved products `(SKProduct)` belong to the same subscription group
	///
	/// - Returns  `SKSubscriptionGroup`. Empty if no subscription groups found
	var subscriptionGroup: SKSubscriptionGroup
	{
		var group: SKSubscriptionGroup!
		
		for p in products
		{
			guard let pgid = p.subscriptionGroupIdentifier else
			{
				continue
			}
			
			if group == nil
			{
				group = SKSubscriptionGroup(with: pgid)
			}
			
			group.insert(product: p)
		}
		
		guard let g = group else
		{
			fatalError("`group` can't be nil.")
		}
		
		return g
	}
	
	/// Build a dictionary that contains the subscription groups
	///
	/// The dictionary contains `SKSubscriptionGroup` objects where the key is a group identifier `GroupIdentifier`
	///
	/// - Returns  `[GroupIdentifier: SKSubscriptionGroup]`. Empty if no subscription groups found
	var subscriptionGroups: [GroupIdentifier: SKSubscriptionGroup]
	{
		var groups: [GroupIdentifier: SKSubscriptionGroup] = [:]
		
		for p in products
		{
			guard let gid = p.subscriptionGroupIdentifier else
			{
				continue
			}
			
			guard let group = groups[gid] else
			{
				let g = SKSubscriptionGroup(with: gid)
				g.insert(product: p)
				
				groups[gid] = g
				
				continue
			}
			
			group.insert(product: p)
		}
		
		return groups
	}
}

@available(macOS 10.14, *)
public extension InAppReceipt
{
    
	///  Refresh local in-app receipt
	///
    ///  - Parameter completion: handler for result
    @available(watchOSApplicationExtension 6.2, *)
    static func refresh(completion: @escaping IAPRefreshRequestResult)
    {
        if refreshSession != nil
		{
			completion(IARError.receiptRefreshingInProgress)
			return
		}
        
        refreshSession = RefreshSession()
        refreshSession!.refresh { (error) in
            completion(error)
            InAppReceipt.destroyRefreshSession()
        }
    }

	///  Cancel refreshing local in-app receipt
	@available(watchOSApplicationExtension 6.2, *)
	static func cancelRefreshSession()
	{
		refreshSession?.cancel()
		destroyRefreshSession()
	}
	
    @available(watchOSApplicationExtension 6.2, *)
    static fileprivate func destroyRefreshSession()
    {
        refreshSession = nil
    }
	
	/// Check whether receipt is refreshing now
	///
	/// - Returns `true` if receipt is refreshing now, otherwise `false`
	@available(watchOSApplicationExtension 6.2, *)
	static var isReceiptRefreshingNow: Bool
	{
		refreshSession != nil
	}
	
	/// Check whether user is eligible for introductory offer for any products within the same subscription group
	///
	/// - Returns `false` if user isn't eligible for introductory offer, otherwise `true`
	func isEligibleForIntroductoryOffer(for group: SKSubscriptionGroup) -> Bool
	{
		let array = purchases.filter { $0.subscriptionTrialPeriod || $0.subscriptionIntroductoryPricePeriod }
			.filter { group.contains($0.productIdentifier) }
		
		return array.isEmpty
	}
}

public typealias IAPRefreshRequestResult = ((Error?) -> ())

@available(watchOSApplicationExtension 6.2, *)
fileprivate class RefreshSession : NSObject, SKRequestDelegate
{
    private let receiptRefreshRequest = SKReceiptRefreshRequest()
    private var completion: IAPRefreshRequestResult?
    
    override init()
    {
        super.init()

        receiptRefreshRequest.delegate = self
    }
    
    func refresh(completion: @escaping IAPRefreshRequestResult)
    {
        self.completion = completion
        
        receiptRefreshRequest.start()
    }
    
    func requestDidFinish(_ request: SKRequest)
    {
        requestDidFinish(with: nil)
        receiptRefreshRequest.cancel()
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error)
    {
        print("Something went wrong: \(error.localizedDescription)")
        
        requestDidFinish(with: error)
    }
    
    func requestDidFinish(with error: Error?)
    {
        DispatchQueue.main.async { [weak self] in
			self?.completion?(error)
        }
        receiptRefreshRequest.cancel()
    }
	
	func cancel()
	{
		receiptRefreshRequest.cancel()
	}
}

#endif

public typealias SubscriptionGroup = Set<String>

public extension InAppReceipt
{
	/// Check whether user is eligible for introductory offer for any products within the same subscription group
	///
	/// - Returns `false` if user isn't eligible for introductory offer, otherwise `true`
	func isEligibleForIntroductoryOffer(for group: SubscriptionGroup) -> Bool
	{
		let array = purchases.filter { $0.subscriptionTrialPeriod || $0.subscriptionIntroductoryPricePeriod }
			.filter { group.contains($0.productIdentifier) }
		
		return array.isEmpty
	}
	
	/// Check whether user is eligible for introductory offer for a specific product
	///
	/// - Returns `false` if user isn't eligible for introductory offer, otherwise `true`
	func isEligibleForIntroductoryOffer(for productIdentifier: String) -> Bool
	{
		let array = purchases.filter { $0.subscriptionTrialPeriod || $0.subscriptionIntroductoryPricePeriod }
			.filter { $0.productIdentifier == productIdentifier }
			
		return array.isEmpty
	}
}
