//
//  InAppReceiptManager.swift
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

public extension InAppReceipt
{
    /**
    *  Refresh local in-app receipt
    *  - Parameter completion: handler for result
    */
    @available(watchOSApplicationExtension 6.2, *)
    static func refresh(completion: @escaping IAPRefreshRequestResult)
    {
        if refreshSession != nil { return }
        
        refreshSession = RefreshSession()
        refreshSession!.refresh { (error) in
            completion(error)
            InAppReceipt.destroyRefreshSession()
        }
    }

    @available(watchOSApplicationExtension 6.2, *)
    static fileprivate func destroyRefreshSession()
    {
        refreshSession = nil
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
}

#endif

extension InAppReceipt
{
	/// Check whether user is eligible for introductory offer
	///
	/// - Returns `false` if user isn't eligible for introductory offer, otherwise `true`
	func isEligibleForIntroductoryOffer(for productIdentifiers: [String]) -> Bool
	{
		let purchases = purchases.filter { $0.subscriptionTrialPeriod || $0.subscriptionIntroductoryPricePeriod }
			.filter { productIdentifiers.contains($0.productIdentifier) }
		
		return purchases.isEmpty
	}
	
	/// Check whether user is eligible for introductory offer
	///
	/// - Returns `false` if user isn't eligible for introductory offer, otherwise `true`
	func isEligibleForIntroductoryOffer(for productIdentifier: String) -> Bool
	{
		let purchases = purchases.filter { ($0.subscriptionTrialPeriod || $0.subscriptionIntroductoryPricePeriod) && $0.productIdentifier == productIdentifier }
		
		return purchases.isEmpty
	}
}
