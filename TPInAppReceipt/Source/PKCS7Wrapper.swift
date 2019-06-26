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

    var rawBuffer: UnsafeMutableBufferPointer<UInt8>
    
    init(receipt: Data) throws
    {
        rawBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: receipt.count)
        let _ = rawBuffer.initialize(from: receipt)
        
        var p: UnsafePointer<UInt8>? = UnsafePointer(rawBuffer.baseAddress)
        
        guard let receiptPKCS7 = d2i_PKCS7(nil, &p, receipt.count) else
        {
            throw IARError.initializationFailed(reason: .pkcs7ParsingError)
        }
        

        
        raw = receiptPKCS7
    }
    
    deinit
    {
        rawBuffer.deallocate()
        PKCS7_free(raw)
    }
}

extension PKCS7Wrapper
{
    func extractInAppPayload() -> Data
    {
        var d = Data(bytesNoCopy: rawBuffer.baseAddress!, count: rawBuffer.count, deallocator: .none)
        var dd = extractContent(by: PCKS7.OID.data, from: &d)
        
        return Data()
    }
    

    
    func extractContent(by oid: PCKS7.OID, from data: inout Data) -> Data?
    {
        if !ASN1Object.isDataValid(checkingLength: false, &data) { return nil }
        
        let start = data.startIndex
        
        do
        {
            let id = try ASN1Object.extractIdentifier(from: &data)
            let l = try ASN1Object.extractLenght(from: &data)
            
            if id.encodingType == .constructed
            {
                let cStart = start + ASN1Object.identifierLenght + l.offset
                let cEnd = data.endIndex
                return extractContent(by: oid, from: &data[cStart..<cEnd])
            }
            
            var foundedOid: String?
            
            if id.type == .objectIdentifier
            {
                let start = start + ASN1Object.identifierLenght + l.offset
                let end = start + l.value
                var slice = data[start..<end]
                foundedOid = ASN1.readOid(contentData: &slice)
            }
            
            let cStart = start + ASN1Object.identifierLenght + l.offset + l.value
            let cEnd = data.endIndex
            
            guard let fOid = foundedOid, fOid == oid.rawValue else
            {
                return extractContent(by: oid, from: &data[cStart..<cEnd])
            }
            
            return data[cStart..<cEnd]
        }catch{
            return nil
        }
    }
    
    func findOid(in data: inout Data) -> (name: String, offset: Int, l: Int)?
    {
        let start = data.startIndex
        
        for (i, item) in data.enumerated()
        {
            do
            {
                let id = try ASN1Object.Identifier(raw: item)
                
                if id.type == .objectIdentifier
                {
                    let curOffset = i + start
                    
                    var slice = data[curOffset..<data.endIndex]
                    let l = try ASN1Object.extractLenght(from: &slice)
                    
                    let start = curOffset + ASN1Object.identifierLenght + l.offset
                    let end = start + l.value
                    slice = data[start..<end]
                    let d = ASN1.readOid(contentData: &slice)
                    return (d, curOffset, end - curOffset)
                }
            }catch{
                continue
            }
        }
        
        return nil
    }
    
    func extractASN1Data() -> Data
    {
        let contents: UnsafeMutablePointer<pkcs7_st> = raw.pointee.d.sign.pointee.contents
        let octets: UnsafeMutablePointer<ASN1_OCTET_STRING> = contents.pointee.d.data
        let d = Data(bytes: octets.pointee.data, count: Int(octets.pointee.length))
        return d
    }
}
