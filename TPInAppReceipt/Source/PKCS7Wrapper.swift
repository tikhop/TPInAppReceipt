//
//  PKCS7Wrapper.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 19/01/17.
//  Copyright © 2017 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import openssl

class PKCS7Wrapper: PKCS7WrapperProtocol
{
    var raw: UnsafeMutablePointer<PKCS7>
    
    required init(receipt: Data) throws
    {
        let receiptBio = BIO_new(BIO_s_mem())
        
        defer
        {
            BIO_free(receiptBio)
        }
        
        var values = [UInt8](repeating:0, count:receipt.count)
        receipt.copyBytes(to: &values, count: receipt.count)
        
        BIO_write(receiptBio, values, Int32(receipt.count))
        
        guard let receiptPKCS7 = d2i_PKCS7_bio(receiptBio, nil) else
        {
            throw IARError.initializationFailed(reason: .pkcs7ParsingError)
        }
        
        raw = receiptPKCS7
    }
    
    deinit
    {
        PKCS7_free(raw)
    }
}

extension PKCS7Wrapper
{
    func extractASN1Data() -> Data
    {
        let contents: UnsafeMutablePointer<pkcs7_st> = raw.pointee.d.sign.pointee.contents
        let octets: UnsafeMutablePointer<ASN1_OCTET_STRING> = contents.pointee.d.data
        
        return Data(bytes: octets.pointee.data, count: Int(octets.pointee.length))
    }
}

protocol PKCS7WrapperProtocol {
    init(receipt: Data) throws
    func extractASN1Data() -> Data
    func verifySignature() throws
}
