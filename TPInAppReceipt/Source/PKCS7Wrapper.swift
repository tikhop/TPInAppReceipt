//
//  PKCS7Wrapper.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 19/01/17.
//  Copyright © 2017 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import openssl

class PKCS7Wrapper
{
    var raw: UnsafeMutablePointer<PKCS7>
    
    init(receipt: Data) throws
    {
        var values = [UInt8](repeating:0, count:receipt.count)
        receipt.copyBytes(to: &values, count: receipt.count)
        
        var p: UnsafePointer<UInt8>? = UnsafePointer(values)
        
        guard let receiptPKCS7 = d2i_PKCS7(nil, &p, values.count) else
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
        let d = Data(bytes: octets.pointee.data, count: Int(octets.pointee.length))
        return d
    }
}
