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
    public var appVersion: String
    public var originalAppVersion: String
    public var purchases: [InAppPurchase]
    public var expirationDate: String? = nil
    
    public var bundleIdentifierData: Data
    public var opaqueValue: Data
    public var receiptHash: Data
    
    public init(ans1Data: Data)
    {
        bundleIdentifier = ""
        appVersion = ""
        originalAppVersion = ""
        purchases = []
        bundleIdentifierData = Data()
        opaqueValue = Data()
        receiptHash = Data()
        
        ans1Data.enumerateASN1Attributes { (attributes) in
            if let field = InAppReceiptField(rawValue: attributes.type)
            {
                let length = attributes.data.count
                
                var bytes = [UInt8](repeating:0, count: length)
                attributes.data.copyBytes(to: &bytes, count: length)
                
                var ptr = UnsafePointer<UInt8>?(bytes)
                
                switch field
                {
                case .bundleIdentifier:
                    bundleIdentifierData = Data(bytes: bytes, count: length)
                    bundleIdentifier = asn1ReadUTF8String(&ptr, bytes.count)
                case .appVersion:
                    appVersion = asn1ReadUTF8String(&ptr, bytes.count)
                case .opaqueValue:
                    opaqueValue = Data(bytes: bytes, count: length)
                case .receiptHash:
                    receiptHash = Data(bytes: bytes, count: length)
                case .inAppPurchaseReceipt:
                    purchases.append(InAppPurchase(ans1Data: attributes.data))
                case .originalAppVersion:
                    originalAppVersion = asn1ReadUTF8String(&ptr, bytes.count)
                case .expirationDate:
                    let str = asn1ReadASCIIString(&ptr, bytes.count)
                    expirationDate = str
                default:
                    print("attribute.type = \(attributes.type))")
                }
            }
            
            
        }
    }
}

public struct InAppPurchase
{
    public var quantity: Int
    public var productIdentifier: String
    public var transactionIdentifier: String
    public var originalTransactionIdentifier: String
    public var purchaseDate: String
    public var originalPurchaseDate: String
    public var subscriptionExpirationDate: String? = nil
    public var cancellationDate: String? = nil
    public var webOrderLineItemID: Int? = nil
    
    public init(ans1Data: Data)
    {
        originalTransactionIdentifier = ""
        productIdentifier = ""
        transactionIdentifier = ""
        purchaseDate = ""
        originalPurchaseDate = ""
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
                case .quantity:
                    quantity = asn1ReadInteger(&ptr, l: bytes.count)
                case .productIdentifier:
                    productIdentifier = asn1ReadUTF8String(&ptr, bytes.count)
                case .transactionIdentifier:
                    transactionIdentifier = asn1ReadUTF8String(&ptr, bytes.count)
                case .purchaseDate:
                    purchaseDate = asn1ReadASCIIString(&ptr, bytes.count)
                case .originalTransactionIdentifier:
                    originalTransactionIdentifier = asn1ReadUTF8String(&ptr, bytes.count)
                case .originalPurchaseDate:
                    originalPurchaseDate = asn1ReadUTF8String(&ptr, bytes.count)
                case .expirationDate:
                    subscriptionExpirationDate = asn1ReadUTF8String(&ptr, bytes.count)
                case .cancellationDate:
                    cancellationDate = asn1ReadUTF8String(&ptr, bytes.count)
                case .webOrderLineItemID:
                    webOrderLineItemID = asn1ReadInteger(&ptr, l: bytes.count)
                default:
                    print("attribute.type = \(attributes.type))")
                }
            }
            
            
        }
    }
}
