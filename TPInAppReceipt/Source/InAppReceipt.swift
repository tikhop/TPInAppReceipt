//
//  InAppReceipt.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 28/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation

public struct InAppReceipt
{
    public let bundleIdentifier: String
    public let appVersion: String
    public let originalAppVersion: String
    public let purchases: [InAppPurchase]
    public let expirationDate: Date
    
    public let bundleIdentifierData: Data
    public let opaqueValue: Data
    public let receiptHash: Data
    
    public init(ans1Data: Data)
    {
        bundleIdentifier = ""
        appVersion = ""
        originalAppVersion = ""
        purchases = []
        expirationDate = Date()
        bundleIdentifierData = Data()
        opaqueValue = Data()
        receiptHash = Data()
        
        ans1Data.enumerateASN1Attributes { (attributes) in
            print("attributes.type: \(attributes.type)")
        }
    }
}

public struct InAppPurchase
{
    public let quantity: Int
    public let productIdentifier: String
    public let transactionIdentifier: String
    public let originalTransactionIdentifier: String
    public let purchaseDate: Date
    public let originalPurchaseDate: Date
    public let subscriptionExpirationDate: Date
    public let cancellationDate: Date
    public let webOrderLineItemID: Int
}
