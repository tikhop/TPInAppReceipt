//
//  ASN1Helper.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 29/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import openssl

public struct InAppReceiptAttribute
{
    var type: Int!
    var version: Int!
    var value: ASN1Object!
}

extension ASN1Object
{
    func enumerateInAppReceiptAttributes(with block: (InAppReceiptAttribute) -> Void)
    {
        for item in enumerated()
        {
            var attr = InAppReceiptAttribute()
            
            for i in item.element.enumerated()
            {
                let elmnt = i.element
                let type = elmnt.identifier.type
                
                guard type != .unknown else
                {
                    continue
                }
                
                switch type
                {
                case .integer:
                    if let value = elmnt.extractValue() as? Int
                    {
                        if attr.type == nil
                        {
                            attr.type = value
                        }else{
                            attr.version = value
                        }
                    }
                    break
                case .octetString:
                    attr.value = elmnt
                default:
                    continue
                }
            }
            
            block(attr)
        }
    }
}

func asn1ConsumeObject(_ ptr: UnsafeMutablePointer<UnsafePointer<UInt8>?>, _ l: Int)
{
    var pClass: Int32 = 0
    var tag: Int32 = 0
    var length: Int = 0
    
    ASN1_get_object(ptr, &length, &tag, &pClass, l)
    ptr.pointee = ptr.pointee?.advanced(by: length)
}

func asn1ReadInteger(_ ptr: UnsafeMutablePointer<UnsafePointer<UInt8>?>, _ l: Int) -> Int
{
    var pClass: Int32 = 0
    var tag: Int32 = 0
    var length: Int = 0
    
    var value: Int = 0
    var integer: UnsafeMutablePointer<ASN1_INTEGER>
    
    ASN1_get_object(ptr, &length, &tag, &pClass, l)
    if tag != V_ASN1_INTEGER
    {
        print("ASN1 error: attribute not an integer")
    }
    
    integer = c2i_ASN1_INTEGER(nil, ptr, length)
    value = ASN1_INTEGER_get(integer)
    ASN1_INTEGER_free(integer)
    
    return value
}

func asn1ReadOctectString(_ ptr: UnsafeMutablePointer<UnsafePointer<UInt8>?>, _ l: Int) -> Data
{
    var pClass: Int32 = 0
    var tag: Int32 = 0
    var length: Int = 0
    
    ASN1_get_object(ptr, &length, &tag, &pClass, l)
    if tag != V_ASN1_OCTET_STRING
    {
        print("ASN1 error: value not an octet string")
    }
    
    let data = Data(bytes: ptr.pointee!, count: length)
    ptr.pointee = ptr.pointee?.advanced(by: length)
    
    return data
}

func asn1ReadString(_ ptr: UnsafeMutablePointer<UnsafePointer<UInt8>?>, _ l: Int, _ expectedTag: Int32, _ encoding: String.Encoding) -> String?
{
    var tag: Int32 = 0
    var pClass: Int32 = 0
    var length: Int = 0
    
    ASN1_get_object(ptr, &length, &tag, &pClass, l)
    
    if tag != expectedTag
    {
        print("ASN1 error: value not a string")
    }
    
    let data = Data(bytes: ptr.pointee!, count: length)
    ptr.pointee = ptr.pointee?.advanced(by: length)
    
    return String(data: data, encoding: encoding)
}

func asn1ReadUTF8String(_ ptr: UnsafeMutablePointer<UnsafePointer<UInt8>?>, _ l: Int) -> String?
{
    return asn1ReadString(ptr, l, V_ASN1_UTF8STRING, .utf8)
}

func asn1ReadASCIIString(_ ptr: UnsafeMutablePointer<UnsafePointer<UInt8>?>, _ l: Int) -> String?
{
    return asn1ReadString(ptr, l, V_ASN1_IA5STRING, .ascii)
}
