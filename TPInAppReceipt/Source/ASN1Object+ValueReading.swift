//
//  ASN1Object+ValueReading.swift
//  TPInAppReceipt iOS
//
//  Created by Pavel Tikhonenko on 24/06/2019.
//  Copyright © 2019 Pavel Tikhonenko. All rights reserved.
//

import Foundation

extension ASN1Object
{
    static func readString(from contents: UnsafePointer<UInt8>, _ l: Int, encoding: String.Encoding) -> String
    {
        let data = Data(bytes: contents, count: l)
        return String(data: data, encoding: encoding) ?? ""
    }
    
    static func readInt(from contents: UnsafePointer<UInt8>, l: Int) -> Int
    {
        var r: UInt64 = 0
        
        for i in 0..<l
        {
            r |= UInt64(contents[i])
            
            if i < (l - 1)
            {
                r = r << 8
            }
        }
        
        if r >= Int.max
        {
            return -1
        }
        
        return Int(r)
    }
    
    static func asn1ReadUTF8String(_ ptr: UnsafePointer<UInt8>, _ l: Int) -> String?
    {
        return readString(from: ptr, l, encoding: .utf8)
    }
    
    static func asn1ReadASCIIString(_ ptr: UnsafePointer<UInt8>, _ l: Int) -> String?
    {
        return readString(from: ptr, l, encoding: .ascii)
    }
    
    
    func extractValue() -> Any?
    {
        return value()
    }
    
    fileprivate func contentsBytes() -> Data
    {
        var contents: Data = rawData
        contents = contents.advanced(by: 1) //Identifier
        contents = contents.advanced(by: length.offset) //Identifier
        return contents
    }
    
    fileprivate func value() -> ASN1ExtractableValueTypes?
    {
        let type = identifier.type
        
        guard type != .unknown else
        {
            return nil
        }
        
        let l = length.value
        
        if l == 0 { return nil }
        
        let contents: UnsafePointer<UInt8> = contentsBytes().pointer
        
        switch type
        {
        case .integer:
            return ASN1Object.readInt(from: contents, l: l)
        case .octetString:
            let data = Data(bytes: contents, count: l)
            if let asn1 = try? ASN1Object.initializeASN1Object(from: data)
            {
                return asn1
            }else{
                return Data(bytes: contents, count: l)
            }
        case .endOfContent:
            return nil
        case .boolean:
            return true
        case .bitString:
            return ""
        case .null:
            return nil
        case .objectIdentifier:
            return "objectIdentifier"
        case .objectDescriptor:
            return "objectIdentifier"
        case .external:
            return "external"
        case .real:
            return "real"
        case .enumerated:
            return "enumerated"
        case .embeddedPdv:
            return "embeddedPdv"
        case .utf8String:
            return ASN1Object.readString(from: contents, l, encoding: .utf8)
        case .relativeOid:
            return "relativeOid"
        case .sequence:
            if let asn1 = try? ASN1Object.initializeASN1Object(from: Data(bytes: contents, count: l))
            {
                return asn1
            }else{
                return "sequence"
            }
            
        case .set:
            if let asn1 = try? ASN1Object.initializeASN1Object(from: Data(bytes: contents, count: l))
            {
                return asn1
            }else{
                return "set"
            }
        case .numericString:
            return "numericString"
        case .printableString:
            return "printableString"
        case .t61String:
            return "t61String"
        case .videotexString:
            return "videotexString"
        case .ia5String:
            return ASN1Object.readString(from: contents, l, encoding: .ascii)
        case .utcTime:
            return "utcTime"
        case .generalizedTime:
            return "generalizedTime"
        case .graphicString:
            return "graphicString"
        case .visibleString:
            return "visibleString"
        case .generalString:
            return "generalString"
        case .universalString:
            return "universalString"
        case .characterString:
            return "characterString"
        case .bmpString:
            return "bmpString"
        default:
            return nil
        }
        return Data()
    }
}
