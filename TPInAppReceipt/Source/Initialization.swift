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
    /// Creates and returns the 'InAppReceipt' instance
    ///
    /// - Returns: 'InAppReceipt' instance
    /// - throws: An error in the InAppReceipt domain, if `InAppReceipt` cannot be created.
    public static func localReceipt() throws -> InAppReceipt
    {
        let receipt = try Bundle.main.appStoreReceiptData()
        return try InAppReceipt(receiptData: receipt)
    }
}

/// A Bundle extension helps to retrieve receipt data
fileprivate extension Bundle
{
    
    /// Creates and returns the 'Data' object
    ///
    /// - Returns: 'Data' object that represents local receipt
    /// - throws: An error if receipt file not found or 'Data' can't be created
    func appStoreReceiptData() throws -> Data
    {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptUrl.path) else
        {
            throw IARError.initializationFailed(reason: .appStoreReceiptNotFound)
        }
        
        return try Data(contentsOf: receiptUrl)
    }
}
