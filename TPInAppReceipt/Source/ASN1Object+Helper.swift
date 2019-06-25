//
//  ASN1Object+Helper.swift
//  TPInAppReceipt iOS
//
//  Created by Pavel Tikhonenko on 24/06/2019.
//  Copyright © 2019 Pavel Tikhonenko. All rights reserved.
//

import Foundation

///
/// Utils methods
extension ASN1Object
{
    static func initializeASN1Object(from data: Data) throws ->  ASN1Object
    {
        guard isDataValid(data) else
        {
            throw ASN1Error.initializationFailed(reason: .dataIsInvalid)
        }
        
        return ASN1Object(data: data)
    }
    
    static func isDataValid(_ data: Data) -> Bool
    {
        let c = data.count
        
        if c == 0 { return false }
        
        guard let identifier = try? Identifier(data: data) else
        {
            return false
        }
        
        var d: Data = data
        
        var bytesCount = 1
        
        let length = ASN1Object.extractLenght(from: &d)
        bytesCount += (length.offset + length.value)
        
        if c != bytesCount
        {
            return false
        }
        
        return true
    }

    static func extractLenght(from asn1data: inout Data) -> Length
    {
        if asn1data.count < 3 { return Length.short(value: 0) } //invalid data
        
        let lByte = asn1data[1]
        
        if ((lByte & 0x80) != 0)
        {
            let l: Int = Int(lByte - 0x80)
            var d = asn1data[2..<2+l]
            
            let r = readInt(from: &d, l: l)
            return Length.long(length: l, value: r)
        }else{
            return Length.short(value: Int(lByte))
        }
    }
}
