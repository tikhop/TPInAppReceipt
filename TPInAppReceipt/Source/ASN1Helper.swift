//
//  ASN1Helper.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 29/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import openssl

func asn1ReadInteger(_ ptr: UnsafeMutablePointer<UnsafePointer<UInt8>?>, l: Int) -> Int
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

func asn1ReadOctectString(_ ptr: UnsafeMutablePointer<UnsafePointer<UInt8>?>, l: Int) -> Data
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
    //note increment ptr?
    return data
}

func asn1ReadString(_ ptr: UnsafeMutablePointer<UnsafePointer<UInt8>?>, _ l: Int, _ expectedTag: Int32, encoding: String.Encoding) -> String
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
    //*pp += length;
    
    return String(data: data, encoding: encoding)!
}

func asn1ReadUTF8String(_ ptr: UnsafeMutablePointer<UnsafePointer<UInt8>?>, _ l: Int) -> String
{
    return asn1ReadString(ptr, l, V_ASN1_UTF8STRING, encoding: .utf8)
}

func asn1ReadASCIIString(_ ptr: UnsafeMutablePointer<UnsafePointer<UInt8>?>, _ l: Int) -> String
{
    return asn1ReadString(ptr, l, V_ASN1_IA5STRING, encoding: .ascii)
}

//
//static NSString* RMASN1ReadString(const uint8_t **pp, long omax, int expectedTag, NSStringEncoding encoding)
//{
//    int tag, asn1Class;
//    long length;
//    NSString *value = nil;
//    ASN1_get_object(pp, &length, &tag, &asn1Class, omax);
//    if (tag == expectedTag)
//    {
//        value = [[NSString alloc] initWithBytes:*pp length:length encoding:encoding];
//    }
//    *pp += length;
//    return value;
//}
//
//static NSString* RMASN1ReadUTF8String(const uint8_t **pp, long omax)
//{
//    return RMASN1ReadString(pp, omax, V_ASN1_UTF8STRING, NSUTF8StringEncoding);
//}
//
//static NSString* RMASN1ReadIA5SString(const uint8_t **pp, long omax)
//{
//    return RMASN1ReadString(pp, omax, V_ASN1_IA5STRING, NSASCIIStringEncoding);
//}
