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
    func extractInAppPayload() -> Data?
    {
        var raw = Data(bytesNoCopy: rawBuffer.baseAddress!, count: rawBuffer.count, deallocator: .none)
        
        guard var contentData = extractContent(by: PCKS7.OID.data, from: &raw) else
        {
            return nil
        }
        
        do
        {
            let id = try ASN1Object.extractIdentifier(from: &contentData)
            let l = try ASN1Object.extractLenght(from: &contentData)
            
            let cStart = contentData.startIndex + ASN1Object.identifierLenght + l.offset
            let cEnd = contentData.endIndex
            
            if id.encodingType == .constructed, id.type.rawValue == 0
            {
                return Data(contentData[cStart..<cEnd])
            }else{
                return nil
            }
        }catch{
            return nil
        }
    }
    

    
    func extractContent(by oid: PCKS7.OID, from data: inout Data) -> Data?
    {
        if !ASN1Object.isDataValid(checkingLength: false, &data) { return nil }
        
        do
        {
            let id = try ASN1Object.extractIdentifier(from: &data)
            let l = try ASN1Object.extractLenght(from: &data)
        
            var cStart = data.startIndex + ASN1Object.identifierLenght + l.offset
            let cEnd = data.endIndex
            
            if id.encodingType == .constructed
            {
                return extractContent(by: oid, from: &data[cStart..<cEnd])
            }
            
            var foundedOid: String?
            
            if id.type == .objectIdentifier
            {
                let end = cStart + l.value
                var slice = data[cStart..<end]
                foundedOid = ASN1.readOid(contentData: &slice)
            }
            
            cStart += l.value
            
            guard let fOid = foundedOid, fOid == oid.rawValue else
            {
                return extractContent(by: oid, from: &data[cStart..<cEnd])
            }
            
            var contentData = data[cStart..<cEnd]
            let contentDataId = try ASN1Object.extractIdentifier(from: &contentData)
            let contentDataLength = try ASN1Object.extractLenght(from: &contentData)
            let contentEnd = cStart + contentDataLength.offset + contentDataLength.value + ASN1Object.identifierLenght
            return data[cStart..<contentEnd]
        }catch{
            return nil
        }
    }
    
    func extractASN1Data() -> Data
    {
        let contents: UnsafeMutablePointer<pkcs7_st> = raw.pointee.d.sign.pointee.contents
        let octets: UnsafeMutablePointer<ASN1_OCTET_STRING> = contents.pointee.d.data
        let d = Data(bytes: octets.pointee.data, count: Int(octets.pointee.length))
        return d
    }
}
