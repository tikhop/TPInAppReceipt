//
//  InAppReceiptManager.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 28/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import openssl

/// A InAppReceiptManager instance coordinates access to a local receipt.
public class InAppReceiptManager
{
    /// Creates and returns the 'InAppReceipt' instance
    ///
    /// - Returns: 'InAppReceipt' instance
    /// - throws: An error in the InAppReceipt domain, if `InAppReceipt` cannot be created.
    public func receipt() throws -> InAppReceipt
    {
        let receipt = try receiptData()
        return try InAppReceipt(receiptData: receipt)
    }
    
    /// Returns the default singleton instance.
    public static let shared: InAppReceiptManager = InAppReceiptManager()
}

public extension InAppReceiptManager
{
    /// Creates and returns the 'Data' object
    ///
    /// - Returns: 'Data' object that represents local receipt
    /// - throws: An error if receipt file not found or 'Data' can't be created
    public func receiptData() throws -> Data
    {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptUrl.path) else
        {
            throw IARError.initializationFailed(reason: .appStoreReceiptNotFound)
        }
        
        return try Data(contentsOf: receiptUrl)
    }
}

