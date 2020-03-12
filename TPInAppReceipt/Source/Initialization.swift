//
//  Initialization.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 05/02/17.
//  Copyright © 2017 Pavel Tikhonenko. All rights reserved.
//

import Foundation

/// An InAppReceipt extension helps to initialize the receipt
public extension InAppReceipt
{
    /// Creates and returns the 'InAppReceipt' instance from data object
    ///
    /// - Returns: 'InAppReceipt' instance
    /// - throws: An error in the InAppReceipt domain, if `InAppReceipt` cannot be created.
    static func receipt(from data: Data) throws -> InAppReceipt
    {
        return try InAppReceipt(receiptData: data)
    }
    
    /// Creates and returns the 'InAppReceipt' instance using local receipt
    ///
    /// - Returns: 'InAppReceipt' instance
    /// - throws: An error in the InAppReceipt domain, if `InAppReceipt` cannot be created.
    static func localReceipt() throws -> InAppReceipt
    {
        let data = try Bundle.main.appStoreReceiptData()
        return try InAppReceipt.receipt(from: data)
    }
}

/// A Bundle extension helps to retrieve receipt data
public extension Bundle
{
    /// Retrieve local App Store Receip Data
    ///
    /// - Returns: 'Data' object that represents local receipt
    /// - throws: An error if receipt file not found or 'Data' can't be created
    func appStoreReceiptData() throws -> Data
    {
        guard let receiptUrl = appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptUrl.path) else
        {
            throw IARError.initializationFailed(reason: .appStoreReceiptNotFound)
        }
        
        return try Data(contentsOf: receiptUrl)
    }
    
    /// Retrieve local App Store Receip Data in base64 string
    ///
    /// - Returns: 'Data' object that represents local receipt
    /// - throws: An error if receipt file not found or 'Data' can't be created
    func appStoreReceiptBase64() throws -> String
    {
        return try appStoreReceiptData().base64EncodedString()
    }
    
    class func lookUp(forResource name: String, ofType ext: String?) -> String?
    {
        return Bundle(for: _DummyClass.self).path(forResource: name, ofType: ext)
    }
}

class _DummyClass {}
