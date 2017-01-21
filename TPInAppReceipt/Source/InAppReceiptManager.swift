//
//  InAppReceiptManager.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 28/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import openssl

public class InAppReceiptManager
{
    public func receipt() throws -> InAppReceipt
    {
        let receipt = try receiptData()
        return try InAppReceipt(receiptData: receipt)
    }
    
    public static let shared: InAppReceiptManager = InAppReceiptManager()
}

fileprivate extension InAppReceiptManager
{
    fileprivate func receiptData() throws -> Data
    {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptUrl.path) else
        {
            throw IARError.initializationFailed(reason: .appStoreReceiptNotFound)
        }
        
        return try Data(contentsOf: receiptUrl)
    }
}
