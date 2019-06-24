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
        
        var bytesCount = 1
        
        let length = ASN1Object.extractLenght(from: data.pointer.advanced(by: 1))
        bytesCount += (length.offset + length.value)
        
        if c != bytesCount
        {
            return false
        }
        
        return true
    }
    
    static func isPointerValid(_ pointer: UnsafePointer<UInt8>) -> Bool
    {
        return true
    }
    
    static func extractLenght(from data: Data) -> Length
    {
        guard let firstByte = data.first else
        {
            return Length.short(value: 0)
        }
        
        if ((firstByte & 0x80) != 0)
        {
            let l: Int = Int(firstByte - 0x80)
            
            var lData = data.dropLast(data.count - 1 - l).advanced(by: 1)
            let r = readInt(from: lData.pointer, l: l)
  
            
            return Length.long(length: l, value: r)
        }else{
            return Length.short(value: Int(firstByte))
        }
    }
    
    static func extractLenght(from pointer: UnsafePointer<UInt8>) -> Length
    {
        let firstByte = pointer[0]
        
        if ((firstByte & 0x80) != 0)
        {
            let l: Int = Int(firstByte - 0x80)
            let nextOctet = pointer.advanced(by: 1)
            
            return Length.long(length: l, value: readInt(from: nextOctet, l: l))
        }else{
            return Length.short(value: Int(firstByte))
        }
    }
}
