//
//  InAppReceiptManager.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 13.02.2020.
//  Copyright © 2020 Pavel Tikhonenko. All rights reserved.
//

#if canImport(StoreKit)

import Foundation
import StoreKit

fileprivate var refreshSession: RefreshSession?

public extension InAppReceipt
{
    /**
    *  Refresh local in-app receipt
    *  - Parameter completion: handler for result
    */
    static func refresh(completion: @escaping IAPRefreshRequestResult)
    {
        if refreshSession != nil { return }
        
        refreshSession = RefreshSession()
        refreshSession!.refresh { (error) in
            completion(error)
            InAppReceipt.destroyRefreshSession()
        }
    }
    
    static fileprivate func destroyRefreshSession()
    {
        refreshSession = nil
    }
}

public typealias IAPRefreshRequestResult = ((Error?) -> ())

fileprivate class RefreshSession : NSObject, SKRequestDelegate
{
    private let receiptRefreshRequest = SKReceiptRefreshRequest()
    private var completion: IAPRefreshRequestResult?
    
    private var backgroundTaskID: UIBackgroundTaskIdentifier?
    
    override init()
    {
        super.init()
        
        #if targetEnvironment(macCatalyst) || os(iOS) || os(tvOS)
        
        #endif
        
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "IARRefreshTask")
        {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
        
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
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error)
    {
        print("Something went wrong: \(error.localizedDescription)")
        
        requestDidFinish(with: error)
    }
    
    func requestDidFinish(with error: Error?)
    {
        UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
        
        DispatchQueue.main.async { [weak self] in
            self?.completion?(error)
        }
    }
}

#endif
