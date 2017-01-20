//
//  InAppReceiptManager.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 28/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import openssl

public enum ReceiptValidatorError: Error
{
    case appStoreReceiptNotFound
    case pkcs7ParsingError
    case receiptIsNotSigned
    case receiptSignedDataNotFound
    case receiptSignatureVerificationFailed
    case appleIncRootCertificateNotFound
    case unableToLoadAppleIncRootCertificate
    case internalError
}

public class InAppReceiptManager
{
    fileprivate let validator = InAppReceiptValidator()
    
    public func receipt() throws -> InAppReceipt
    {
        let receipt = try receiptData()
        let asn1Data = try extractASN1Data(fromReceipt: receipt)
        return InAppReceipt(ans1Data: asn1Data)
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
    
    fileprivate func extractASN1Data(fromReceipt receipt: Data) throws -> Data
    {
        var data: Data!
        
        let receiptBio = BIO_new(BIO_s_mem())
        
        var values = [UInt8](repeating:0, count:receipt.count)
        receipt.copyBytes(to: &values, count: receipt.count)
        
        BIO_write(receiptBio, values, Int32(receipt.count))
        
        guard let receiptPKCS7 = d2i_PKCS7_bio(receiptBio, nil) else
        {
            throw ReceiptValidatorError.pkcs7ParsingError
        }
        
        do {
            try validator.verifySignature(pkcs7: receiptPKCS7)
        }
        
        let contents: UnsafeMutablePointer<pkcs7_st> = receiptPKCS7.pointee.d.sign.pointee.contents
        let octets: UnsafeMutablePointer<ASN1_OCTET_STRING> = contents.pointee.d.data
        
        data = Data(bytes: octets.pointee.data, count: Int(octets.pointee.length))
        
        PKCS7_free(receiptPKCS7)
        
        return data
    }
    
    public static let shared: InAppReceiptManager = InAppReceiptManager()
}
