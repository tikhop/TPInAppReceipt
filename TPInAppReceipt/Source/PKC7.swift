//
//  PCKS7.swift
//  TPInAppReceipt iOS
//
//  Created by Pavel Tikhonenko on 22/06/2019.
//  Copyright © 2019 Pavel Tikhonenko. All rights reserved.
//

import Foundation

struct PKC7
{
    enum OID: String
    {
        case data = "1.2.840.113549.1.7.1"
        case signedData = "1.2.840.113549.1.7.2"
        case envelopedData = "1.2.840.113549.1.7.3"
        case signedAndEnvelopedData = "1.2.840.113549.1.7.4"
        case digestedData = "1.2.840.113549.1.7.5"
        case encryptedData = "1.2.840.113549.1.7.6"
    }
}

class PKCS7Wrapper
{
    var rawBuffer: UnsafeMutableBufferPointer<UInt8>
    
    init(receipt: Data) throws
    {
        rawBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: receipt.count)
        let _ = rawBuffer.initialize(from: receipt)
    }
    
    deinit
    {
        rawBuffer.deallocate()
    }
}

extension PKCS7Wrapper
{
    func extractContent(by oid: PKC7.OID, from data: inout Data) -> Data?
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
}

extension PKCS7Wrapper
{
    var base64: String
    {
        let raw = Data(bytesNoCopy: rawBuffer.baseAddress!, count: rawBuffer.count, deallocator: .none)
        return raw.base64EncodedString()
    }
}
