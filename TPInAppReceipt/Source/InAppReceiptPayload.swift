//
//  InAppReceiptPayload.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 20/01/17.
//  Copyright © 2017 Pavel Tikhonenko. All rights reserved.
//

import Foundation



struct InAppReceiptPayload
{
    /// The app’s bundle identifier
    public let bundleIdentifier: String
    
    /// The app’s version number
    public let appVersion: String
    
    /// The version of the app that was originally purchased.
    public let originalAppVersion: String
    
    /// In-app purchase's receipts
    public let purchases: [InAppPurchase]
    
    /// The date that the app receipt expires
    public let expirationDate: String?
    
    /// Used to validate the receipt
    public let bundleIdentifierData: Data
    
    /// An opaque value used, with other data, to compute the SHA-1 hash during validation.
    public let opaqueValue: Data
    
    /// A SHA-1 hash, used to validate the receipt.
    public let receiptHash: Data
    
    /// Initialize a `InAppReceipt` with asn1 payload
    ///
    /// - parameter asn1Data: `Data` object that represents receipt's payload
    init(asn1Data: Data)
    {
        var bundleIdentifier = ""
        var appVersion = ""
        var originalAppVersion = ""
        var purchases = [InAppPurchase]()
        var bundleIdentifierData = Data()
        var opaqueValue = Data()
        var receiptHash = Data()
        var expirationDate: String? = ""
        
        asn1Data.enumerateASN1Attributes { (attributes) in
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
                    bundleIdentifier = asn1ReadUTF8String(&ptr, bytes.count)!
                case .appVersion:
                    appVersion = asn1ReadUTF8String(&ptr, bytes.count)!
                case .opaqueValue:
                    opaqueValue = Data(bytes: bytes, count: length)
                case .receiptHash:
                    receiptHash = Data(bytes: bytes, count: length)
                case .inAppPurchaseReceipt:
                    purchases.append(InAppPurchase(asn1Data: attributes.data))
                case .originalAppVersion:
                    originalAppVersion = asn1ReadUTF8String(&ptr, bytes.count)!
                case .expirationDate:
                    let str = asn1ReadASCIIString(&ptr, bytes.count)
                    expirationDate = str
                default:
                    print("attribute.type = \(attributes.type))")
                }
            }
        }
        
        self.init(bundleIdentifier: bundleIdentifier, appVersion: appVersion, originalAppVersion: originalAppVersion, purchases: purchases, expirationDate: expirationDate, bundleIdentifierData: bundleIdentifierData, opaqueValue: opaqueValue, receiptHash: receiptHash)
    }
    
    fileprivate init(bundleIdentifier: String, appVersion: String, originalAppVersion: String, purchases: [InAppPurchase], expirationDate: String?, bundleIdentifierData: Data, opaqueValue: Data, receiptHash: Data)
    {
        self.bundleIdentifier = bundleIdentifier
        self.appVersion = appVersion
        self.originalAppVersion = originalAppVersion
        self.purchases = purchases
        self.expirationDate = expirationDate
        self.bundleIdentifierData = bundleIdentifierData
        self.opaqueValue = opaqueValue
        self.receiptHash = receiptHash
        
    }
}
