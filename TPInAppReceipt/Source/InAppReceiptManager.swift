//
//  InAppReceiptManager.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 28/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import openssl

public enum InAppReceiptError: Error
{
    case appStoreReceiptNotFound
    case internalError
}

public class InAppReceiptManager
{
    fileprivate let validator = InAppReceiptValidator()
    
    public func receipt(usingValidation: Bool = true) throws -> InAppReceipt
    {
        let pkcs7container = try pkcs7()
        
        if usingValidation
        {
            try validate(pkcs7: pkcs7container)
        }
        
        return InAppReceipt(asn1Data: pkcs7container.extractASN1Data())
    }
    
    public static let shared: InAppReceiptManager = InAppReceiptManager()
}

fileprivate extension InAppReceiptManager
{
    fileprivate func validate(pkcs7: PKCS7Wrapper) throws
    {
        try validator.verifySignature(pkcs7: pkcs7)
    }
    
    fileprivate func pkcs7() throws -> PKCS7Wrapper
    {
        let inAppData = try receiptData()
        return try PKCS7Wrapper(receipt: inAppData)
    }
    
    fileprivate func receiptData() throws -> Data
    {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptUrl.path) else
        {
            throw ReceiptValidatorError.appStoreReceiptNotFound
        }
        
        return try Data(contentsOf: receiptUrl)
    }
}
