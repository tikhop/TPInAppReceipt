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
    public let creationDate: String
    
    /// Initialize a `InAppReceipt` passing all values
    ///
    init(bundleIdentifier: String, appVersion: String, originalAppVersion: String, purchases: [InAppPurchase], expirationDate: String?, bundleIdentifierData: Data, opaqueValue: Data, receiptHash: Data, creationDate: String)
    {
        self.bundleIdentifier = bundleIdentifier
        self.appVersion = appVersion
        self.originalAppVersion = originalAppVersion
        self.purchases = purchases
        self.expirationDate = expirationDate
        self.bundleIdentifierData = bundleIdentifierData
        self.opaqueValue = opaqueValue
        self.receiptHash = receiptHash
        self.creationDate = creationDate
    }
}


public extension InAppReceiptPayload
{
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
        
        let payload = ASN1Object(data: asn1Data)
        payload.enumerateInAppReceiptAttributes { (attribute) in
            if let field = InAppReceiptField(rawValue: attribute.type)
            {
                var value = attribute.value.extractValue()
                var fValue = value
                
                if let v = value as? ASN1Object, v.identifier.encodingType != .constructed
                {
                    value = v.extractValue()
                }
                
                switch (field)
                {
                case .bundleIdentifier:
                    bundleIdentifier = value as! String
                    bundleIdentifierData = attribute.value.valueData!
                case .appVersion:
                    appVersion = value as! String
                case .opaqueValue:
                    opaqueValue = value as! Data
                case .receiptHash:
                    receiptHash = value as! Data
                case .inAppPurchaseReceipt:
                    let set = value as! ASN1Object
                    purchases.append(InAppPurchase(asn1Data: set.rawData))
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
        
        self.bundleIdentifier = bundleIdentifier
        self.appVersion = appVersion
        self.originalAppVersion = originalAppVersion
        self.purchases = purchases
        self.expirationDate = expirationDate
        self.bundleIdentifierData = bundleIdentifierData
        self.opaqueValue = opaqueValue
        self.receiptHash = receiptHash
        self.creationDate = receiptCreationDate
    }
}
