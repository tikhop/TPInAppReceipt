//
//  InAppReceiptPayload.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 20/01/17.
//  Copyright © 2017 Pavel Tikhonenko. All rights reserved.
//

import Foundation

public struct InAppReceiptPayload
{
    /// In-app purchase's receipts
    public let purchases: [InAppPurchase]
    
    /// The app’s bundle identifier
    public let bundleIdentifier: String
    
    /// The app’s version number
    public let appVersion: String
    
    /// The version of the app that was originally purchased.
    public let originalAppVersion: String
    
    /// The date that the app receipt expires
    public let expirationDate: String?
    
    /// Used to validate the receipt
    public let bundleIdentifierData: Data
    
    /// An opaque value used, with other data, to compute the SHA-1 hash during validation.
    public let opaqueValue: Data
    
    /// A SHA-1 hash, used to validate the receipt.
    public let receiptHash: Data
    
    /// The date when the app receipt was created.
    public let receiptCreationDate: String
    
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
        var receiptCreationDate: String = ""
        
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
                    break //purchases.append(InAppPurchase(asn1Data: attributes.data))
                case .originalAppVersion:
                    originalAppVersion = asn1ReadUTF8String(&ptr, bytes.count)!
                case .expirationDate:
                    let str = asn1ReadASCIIString(&ptr, bytes.count)
                    expirationDate = str
                case .receiptCreationDate:
                    receiptCreationDate = asn1ReadASCIIString(&ptr, bytes.count)!
                default:
                    print("attribute.type = \(attributes.type))")
                }
            }
        }
        
        self.init(bundleIdentifier: bundleIdentifier, appVersion: appVersion, originalAppVersion: originalAppVersion, purchases: purchases, expirationDate: expirationDate, bundleIdentifierData: bundleIdentifierData, opaqueValue: opaqueValue, receiptHash: receiptHash, receiptCreationDate: receiptCreationDate)
    }
    
    init(bundleIdentifier: String, appVersion: String, originalAppVersion: String, purchases: [InAppPurchase], expirationDate: String?, bundleIdentifierData: Data, opaqueValue: Data, receiptHash: Data, receiptCreationDate: String)
    {
        self.bundleIdentifier = bundleIdentifier
        self.appVersion = appVersion
        self.originalAppVersion = originalAppVersion
        self.purchases = purchases
        self.expirationDate = expirationDate
        self.bundleIdentifierData = bundleIdentifierData
        self.opaqueValue = opaqueValue
        self.receiptHash = receiptHash
        self.receiptCreationDate = receiptCreationDate
    }
}


public extension InAppReceiptPayload
{
    init(noOpenSslData asn1Data: Data)
    {
        var bundleIdentifier = ""
        var appVersion = ""
        var originalAppVersion = ""
        var purchases = [InAppPurchase]()
        var bundleIdentifierData = Data()
        var opaqueValue = Data()
        var receiptHash = Data()
        var expirationDate: String? = ""
        var receiptCreationDate: String = ""
        
        asn1Data.enumerateASN1AttributesNoOpenssl { (attribute) in
            if let field = InAppReceiptField(rawValue: attribute.type)
            {
                var value = attribute.value.extractValue()
                
                if let v = value as? ASN1Object
                {
                    value = v.extractValue()
                }
                
                switch (field)
                {
                case .bundleIdentifier:
                    bundleIdentifier = value as! String
                    bundleIdentifierData = bundleIdentifier.data(using: .utf8)!
                case .appVersion:
                    appVersion = value as! String
                case .opaqueValue:
                    opaqueValue = value as! Data
                case .receiptHash:
                    receiptHash = value as! Data
                case .inAppPurchaseReceipt:
                    break
                case .originalAppVersion:
                    originalAppVersion = value as! String
                case .expirationDate:
                    expirationDate = value as? String
                case .receiptCreationDate:
                    receiptCreationDate = value as! String
                default:
                    print("attribute.type = \(String(describing: attribute.type)))")
                }
            }
        }
        
        self.init(bundleIdentifier: bundleIdentifier, appVersion: appVersion, originalAppVersion: originalAppVersion, purchases: purchases, expirationDate: expirationDate, bundleIdentifierData: bundleIdentifierData, opaqueValue: opaqueValue, receiptHash: receiptHash, receiptCreationDate: receiptCreationDate)
    }
}
