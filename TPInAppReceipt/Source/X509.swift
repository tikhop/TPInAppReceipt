//
//  X509.swift
//  TPInAppReceipt iOS
//
//  Created by Soulchild on 18/11/2019.
//  Copyright © 2019 Pavel Tikhonenko. All rights reserved.
//

import Foundation

struct X509
{
    enum OID: String
    {
        case rsaEncryption = "1.2.840.113549.1.1.1"
    }
}

class X509Wrapper
{
    var rawBuffer: UnsafeMutableBufferPointer<UInt8>
    
    init(cert: Data) throws
    {
        rawBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: cert.count)
        let _ = rawBuffer.initialize(from: cert)
    }
    
    deinit
    {
        rawBuffer.deallocate()
    }
}

extension X509Wrapper
{
    /// Find content by x509 oid
    ///
    /// - Returns: Data slice make sure you allocate memory and copy bytes for long term usage
    func extractContent(by oid: X509.OID) -> Data?
    {
        var raw = Data(bytesNoCopy: rawBuffer.baseAddress!, count: rawBuffer.count, deallocator: .none)
        return extractContent(by: oid, from: &raw)
    }
    
    /// Extract content by x509 oid
    ///
    /// - Returns: Data slice make sure you allocate memory and copy bytes for long term usage
    func extractContent(by oid: X509.OID, from data: inout Data) -> Data?
    {
        if !ASN1Object.isDataValid(checkingLength: false, &data) { return nil }

        do
        {
            let r = checkContentExistance(by: oid, in: &data)
            
            guard r.0, let offset = r.offset else
            {
                return nil
            }
            
            var contentData = data[offset..<data.endIndex]
            let _ = try ASN1Object.extractIdentifier(from: &contentData)
            let contentDataLength = try ASN1Object.extractLenght(from: &contentData)
            let contentEnd = offset + ASN1Object.identifierLenght + contentDataLength.offset + contentDataLength.value
            return data[offset..<contentEnd]
        }catch{
            return nil
        }
    }
    
    /// Check if any data available for provided x509 oid
    ///
    ///
    func checkContentExistance(by oid: X509.OID) -> Bool
    {
        var raw = Data(bytesNoCopy: rawBuffer.baseAddress!, count: rawBuffer.count, deallocator: .none)
        
        let r = checkContentExistance(by: oid, in: &raw)
        guard r.0, let _ = r.offset else
        {
            return false
        }
        
        return true
    }
    
    /// Extract content by x509 oid
    ///
    /// - Returns: Data slice make sure you allocate memory and copy bytes for long term usage
    func checkContentExistance(by oid: X509.OID, in data: inout Data) -> (Bool, offset: Int?)
    {
        if !ASN1Object.isDataValid(checkingLength: false, &data) { return (false, nil) }
        
        do
        {
            let id = try ASN1Object.extractIdentifier(from: &data)
            let l = try ASN1Object.extractLenght(from: &data)
            
            var cStart = data.startIndex + ASN1Object.identifierLenght + l.offset
            let cEnd = data.endIndex
            
            if id.encodingType == .constructed
            {
                return checkContentExistance(by: oid, in: &data[cStart..<cEnd])
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
                return checkContentExistance(by: oid, in: &data[cStart..<cEnd])
            }
            
            var contentData = data[cStart..<cEnd]
            let _ = try ASN1Object.extractIdentifier(from: &contentData)
            let _ = try ASN1Object.extractLenght(from: &contentData)
            return (true, cStart)
        }catch{
            return (false, nil)
        }
    }
}

extension X509Wrapper
{
    var base64: String
    {
        let raw = Data(bytesNoCopy: rawBuffer.baseAddress!, count: rawBuffer.count, deallocator: .none)
        return raw.base64EncodedString()
    }
}
