//
//  Data+Extension.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 29/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import openssl

public typealias ASN1Attribute = (data: Data, type: Int)

public extension Data
{
    public func enumerateASN1Attributes(withBlock block: (ASN1Attribute) -> ())
    {
        var type: Int32 = 0
        var tag: Int32 = 0
        var length = 0
    
        var receiptBytes = [UInt8](repeating:0, count:self.count)
        self.copyBytes(to: &receiptBytes, count: self.count)
        
        var ptr = UnsafePointer<UInt8>?(receiptBytes)
        let end = ptr!.advanced(by: receiptBytes.count)
        
        ASN1_get_object(&ptr, &length, &type, &tag, end - ptr!)
        
        if (type != V_ASN1_SET)
        {
            print("Could not read a ASN1 set from the receipt")
            return
        }
        
        while ptr! < end
        {
            var integer: UnsafeMutablePointer<ASN1_INTEGER>
            
            ASN1_get_object(&ptr, &length, &type, &tag, end - ptr!)
            if (type != V_ASN1_SEQUENCE) { break }
            
            let sequenceEnd = ptr!.advanced(by: length)

            // Parse the attribute type
            var attributeType = 0
            ASN1_get_object(&ptr, &length, &type, &tag, sequenceEnd - ptr!)
            if type != V_ASN1_INTEGER
            {
                print("ASN1 error: attribute not an integer")
            }
            
            integer = c2i_ASN1_INTEGER(nil, &ptr, length)
            attributeType = ASN1_INTEGER_get(integer)
            ASN1_INTEGER_free(integer)
            
            // Skip attribute version
            ASN1_get_object(&ptr, &length, &type, &tag, sequenceEnd - ptr!)
            if type != V_ASN1_INTEGER
            {
                print("ASN1 error: attribute not an integer")
            }

            integer = c2i_ASN1_INTEGER(nil, &ptr, length)
            ASN1_INTEGER_free(integer)
            
            // Check the attribute value
            ASN1_get_object(&ptr, &length, &type, &tag, sequenceEnd - ptr!)
            if type != V_ASN1_OCTET_STRING
            {
                print("ASN1 error: value not an octet string")
            }
            
            let data = Data(bytes: &ptr!, count: sequenceEnd - ptr!)
            block((data, attributeType))
            
            // Skip remaining fields
            while ptr! < sequenceEnd
            {
                ASN1_get_object(&ptr, &length, &type, &tag, sequenceEnd - ptr!)
                ptr = ptr?.advanced(by: length)
            }
        }
    }
}
