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
    static var identifierLenght: Int { return 1 }
    
    static func isDataValid(_ data: inout Data) -> Bool
    {
        let c = data.count
        
        if c == 0 { return false }
        
        guard let _ = try? extractIdentifier(from: &data),
            let length = try? ASN1Object.extractLenght(from: &data),
            (identifierLenght + length.offset + length.value) == c else
        {
            return false
        }
        
        return true
    }

    static func extractIdentifier(from asn1data: inout Data) throws -> Identifier
    {
        guard asn1data.count > 0 else
        {
            throw ASN1Error.initializationFailed(reason: .dataIsInvalid)
        }
        
        let raw = asn1data[0]
        let tagNumber = raw & 0b11111
        
        guard let c = Identifier.Class(rawValue: (raw >> 6) & 0b11),
            let e = Identifier.EncodingType(rawValue: (raw >> 5) & 0b1) else
        {
            throw ASN1Error.initializationFailed(reason: .dataIsInvalid)
        }
        
        return Identifier(raw: raw, tagNumber: tagNumber, class: c, encodingType: e)
    }
    
    static func extractLenght(from asn1data: inout Data) throws -> Length
    {
        if asn1data.count < 3 { return Length.short(value: 0) } //invalid data
        
        // Skip identifier
        let lByte = asn1data[1]
        
        if ((lByte & 0x80) != 0)
        {
            let l: Int = Int(lByte - 0x80)
            let start = identifierLenght + 1 // skip identifier and lenght header
            let end = start+l
            var d = asn1data[start..<end]
            
            let r = ASN1.readInt(from: &d, l: l)
            return Length.long(length: l, value: r)
        }else{
            return Length.short(value: Int(lByte))
        }
    }
}
