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
    public var pointer: UnsafePointer<UInt8>
    {
        var bytes = [UInt8](repeating:0, count: self.count)
        copyBytes(to: &bytes, count: self.count)
        return UnsafePointer<UInt8>(bytes)
    }
    
    public func enumerateASN1Attributes(withBlock block: (ASN1Attribute) -> ())
    {
        var type: Int32 = 0
        var tag: Int32 = 0
        var length = 0
    
        let count = self.count
        
        var receiptBytes = [UInt8](repeating:0, count: count)
        self.copyBytes(to: &receiptBytes, count: count)
        
        var ptr = UnsafePointer<UInt8>?(receiptBytes)
        let end = ptr!.advanced(by: count)
        
        ASN1_get_object(&ptr, &length, &type, &tag, end - ptr!)
        
        if (type != V_ASN1_SET)
        {
            print("Could not read a ASN1 set from the receipt")
            return
        }
        
        while ptr! < end
        {
            ASN1_get_object(&ptr, &length, &type, &tag, end - ptr!)
            if (type != V_ASN1_SEQUENCE) { break }
            
            let sequenceEnd = ptr!.advanced(by: length)

            // Parse the attribute type
            let attributeType = asn1ReadInteger(&ptr, sequenceEnd - ptr!)
        
            // Skip attribute version
            asn1ConsumeObject(&ptr, sequenceEnd - ptr!)
            
            // Check the attribute value
            let data = asn1ReadOctectString(&ptr, sequenceEnd - ptr!)
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
