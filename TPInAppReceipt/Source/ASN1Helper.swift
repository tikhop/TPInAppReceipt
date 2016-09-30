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
    var tag: Int32 = 0
    var type: Int32 = 0
    var value: Int = 0
    var length: Int = 0
    var integer: UnsafeMutablePointer<ASN1_INTEGER>
    
    ASN1_get_object(ptr, &length, &type, &tag, l)
    if type != V_ASN1_INTEGER
    {
        print("ASN1 error: attribute not an integer")
    }
    
    integer = c2i_ASN1_INTEGER(nil, ptr, length)
    value = ASN1_INTEGER_get(integer)
    ASN1_INTEGER_free(integer)
    
    return value
}
//
//static int RM
//{
//    int tag, asn1Class;
//    long length;
//    int value = 0;
//    
//    if (tag == V_ASN1_INTEGER)
//    {
//        for (int i = 0; i < length; i++)
//        {
//            value = value * 0x100 + (*pp)[i];
//        }
//    }
//    *pp += length;
//    return value;
//}
//
//static NSData* RMASN1ReadOctectString(const uint8_t **pp, long omax)
//{
//    int tag, asn1Class;
//    long length;
//    NSData *data = nil;
//    ASN1_get_object(pp, &length, &tag, &asn1Class, omax);
//    if (tag == V_ASN1_OCTET_STRING)
//    {
//        data = [NSData dataWithBytes:*pp length:length];
//    }
//    *pp += length;
//    return data;
//}
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
