//
//  InAppReceipt+OpenSSL.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 26/06/2019.
//  Copyright © 2019 Pavel Tikhonenko. All rights reserved.
//

import Foundation
//import OpenSSL

/// A InAppReceipt extension helps to validate the receipt
public extension InAppReceipt
{
    /// Verify receipt in a complex way.
    /// Validate signature and hash
    ///
    /// - throws: An error in the InAppReceipt domain, if verification can't be completed
    public func verify() throws
    {
        try verifySignature()
        try verifyHash()
    }
    
    /// Verify only signature
    ///
    /// - throws: An error in the InAppReceipt domain, if verification can't be completed
    public func verifySignature() throws
    {
        try pkcs7Container.verifySignature()
    }
}

/// A PKCS7Wrapper extension helps to validate the receipt's signature
extension PKCS7Wrapper
{
    /// Verify signature inside pkcs7 container
    ///
    /// - throws: An error in the InAppReceipt domain, if verification can't be completed
    func verifySignature() throws
    {
        
        var p: UnsafePointer<UInt8>? = UnsafePointer(rawBuffer.baseAddress)
        
        guard let receiptPKCS7 = d2i_PKCS7(nil, &p, rawBuffer.count) else
        {
            throw IARError.initializationFailed(reason: .pkcs7ParsingError)
        }
        
        defer {
            PKCS7_free(receiptPKCS7)
        }
        
        try checkSignatureExistance(pkcs7: receiptPKCS7)
        let appleCertificate = try appleCertificateData()
        try verifySignature(pkcs7: receiptPKCS7, withCertificateData: appleCertificate)
    }
    
    /// Verify signature inside pkcs7 container using openssl library
    ///
    /// - throws: An error in the InAppReceipt domain, if verification can't be completed
    fileprivate func verifySignature(pkcs7: UnsafeMutablePointer<PKCS7>, withCertificateData data: Data) throws
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
        
        BIO_free(appleRootBIO)
        X509_STORE_free(store)
        EVP_cleanup()
        
        if verified != result
        {
            throw IARError.validationFailed(reason: .signatureValidation(.invalidSignature))
        }
    }
    
    /// Verifies existance of the signature inside pkcs7 container
    ///
    /// - throws: An error in the InAppReceipt domain, if verification can't be completed
    fileprivate func checkSignatureExistance(pkcs7: UnsafeMutablePointer<PKCS7>) throws
    {
        if OBJ_obj2nid(pkcs7.pointee.type) != NID_pkcs7_signed
        {
            throw IARError.validationFailed(reason: .signatureValidation(.receiptIsNotSigned))
        }
        
        if OBJ_obj2nid(pkcs7.pointee.d.sign.pointee.contents.pointee.type) != NID_pkcs7_data
        {
            throw IARError.validationFailed(reason: .signatureValidation(.receiptSignedDataNotFound))
        }
    }
    
    /// Load 'AppleIncRootCertificate' file and create 'Data' using content of the file
    ///
    /// - Returns: 'Data' object that represents Apple Root Certificate
    /// - throws: An error if receipt file not found or 'Data' can't be created
    fileprivate func appleCertificateData() throws -> Data
    {
        guard let appleRootURL = Bundle.init(for: type(of: self)).url(forResource: "AppleIncRootCertificate", withExtension: "cer") else
        {
            throw IARError.validationFailed(reason: .signatureValidation(.appleIncRootCertificateNotFound))
        }
        
        let appleRootData = try Data(contentsOf: appleRootURL)
        
        if appleRootData.count == 0
        {
            throw IARError.validationFailed(reason: .signatureValidation(.unableToLoadAppleIncRootCertificate))
        }
        
        return appleRootData
    }
}


