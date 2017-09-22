//
//  InAppReceiptValidator.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 19/01/17.
//  Copyright © 2017 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import openssl

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
    
    /// Verify only hash
    ///
    /// - throws: An error in the InAppReceipt domain, if verification can't be completed
    public func verifyHash() throws
    {
        if (computedHashData != receiptHash)
        {
            throw IARError.validationFailed(reason: .hashValidation)
        }
    }
    
    /// Computed SHA-1 hash, used to validate the receipt.
    /// Should be equal to `receiptHash` value
    internal var computedHashData: Data
    {
        let uuidData = DeviceGUIDRetriever.guid()
        let opaqueData = opaqueValue
        let bundleIdData = bundleIdentifierData
        
        var hash = Array<CUnsignedChar>(repeating: 0, count: 20)
        var ctx = SHA_CTX()
        
        SHA1_Init(&ctx)
        SHA1_Update(&ctx, uuidData.pointer, uuidData.count)
        SHA1_Update(&ctx, opaqueData.pointer, opaqueData.count)
        SHA1_Update(&ctx, bundleIdData.pointer, bundleIdData.count)
        SHA1_Final(&hash, &ctx);
        
        return Data(bytes: &hash, count: hash.count)
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
        try checkSignatureExistance(pkcs7: raw)
        let appleCertificate = try appleCertificateData()
        try verifySignature(pkcs7: raw, withCertificateData: appleCertificate)
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
