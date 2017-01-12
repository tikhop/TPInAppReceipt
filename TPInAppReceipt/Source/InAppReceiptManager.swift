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
            try validatePKCS7(receiptPKCS7)
        }
        
        guard let appleRootURL = Bundle.init(for: type(of: self)).url(forResource: "AppleIncRootCertificate", withExtension: "cer") else
        {
            throw ReceiptValidatorError.appleIncRootCertificateNotFound
        }
        
        let appleRootData = try Data(contentsOf: appleRootURL)
        
        
        if appleRootData.count == 0
        {
            throw ReceiptValidatorError.unableToLoadAppleIncRootCertificate
        }
        
        if !verify(pkcs7: receiptPKCS7, withCertificateData: appleRootData)
        {
            throw ReceiptValidatorError.receiptSignatureVerificationFailed
        }
        
        let contents: UnsafeMutablePointer<pkcs7_st> = receiptPKCS7.pointee.d.sign.pointee.contents
        let octets: UnsafeMutablePointer<ASN1_OCTET_STRING> = contents.pointee.d.data
        
        data = Data(bytes: octets.pointee.data, count: Int(octets.pointee.length))
        
        PKCS7_free(receiptPKCS7)
        
        return data
    }
    
    fileprivate func validatePKCS7(_ pkcs7: UnsafeMutablePointer<PKCS7>) throws
    {
        if OBJ_obj2nid(pkcs7.pointee.type) != NID_pkcs7_signed
        {
            throw ReceiptValidatorError.receiptIsNotSigned
        }
        
        if OBJ_obj2nid(pkcs7.pointee.d.sign.pointee.contents.pointee.type) != NID_pkcs7_data
        {
            throw ReceiptValidatorError.receiptSignedDataNotFound
        }
    }
    
    fileprivate func verify(pkcs7: UnsafeMutablePointer<PKCS7>, withCertificateData data: Data)  -> Bool
    {
        let verified: Int32 = 1
        
        let appleRootBIO = BIO_new(BIO_s_mem())
        
        var appleRootBytes = [UInt8](repeating:0, count:data.count)
        data.copyBytes(to: &appleRootBytes, count: data.count)
        BIO_write(appleRootBIO, appleRootBytes, Int32(data.count))
        
        let appleRootX509 = d2i_X509_bio(appleRootBIO, nil)
        let store = X509_STORE_new()
        
        X509_STORE_add_cert(store, appleRootX509)
        OpenSSL_add_all_digests()
        
        let result = PKCS7_verify(pkcs7, nil, store, nil, nil, 0)

        X509_STORE_free(store)
        EVP_cleanup()
        
        return verified == result
    }
    
    public static let shared: InAppReceiptManager = InAppReceiptManager()
}
