//
//  InAppReceipt.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 28/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation

public enum InAppReceiptField: Int
{
    case bundleIdentifier = 2
    case appVersion = 3
    case opaqueValue = 4
    case receiptHash = 5 //SHA-1 Hash
    case inAppPurchaseReceipt = 17
    case originalAppVersion = 19
    case expirationDate = 21
    
    case quantity = 1701
    case productIdentifier = 1702
    case transactionIdentifier = 1703
    case purchaseDate = 1704
    case originalTransactionIdentifier = 1705
    case originalPurchaseDate = 1706
    case subscriptionExpirationDate = 1708
    case webOrderLineItemID = 1711
    case cancellationDate = 1712
}

public struct InAppReceipt
{
    public var bundleIdentifier: String
    public let appVersion: String
    public let originalAppVersion: String
    public let purchases: [InAppPurchase]
    public let expirationDate: Date
    
    public let quantity: Int
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
        quantity = 0
        
        ans1Data.enumerateASN1Attributes { (attributes) in
            if let field = InAppReceiptField(rawValue: attributes.type)
            {
                let length = attributes.data.count
                
                var bytes = [UInt8](repeating:0, count: length)
                attributes.data.copyBytes(to: &bytes, count: length)
                
                var ptr = UnsafePointer<UInt8>?(bytes)
                
                switch field
                {
                case InAppReceiptField.bundleIdentifier:
                    let str = asn1ReadUTF8String(&ptr, bytes.count)
                    bundleIdentifier = str
                default:
                    print("attribute.type = \(attributes.type))")
                }
            }
            
            
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
