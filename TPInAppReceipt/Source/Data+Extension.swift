//
//  Data+Extension.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 29/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation

extension Data
{
    /// Two octet checksum as defined in RFC-4880. Sum of all octets, mod 65536
    public func checksum() -> UInt16
    {
        var s: UInt32 = 0
        let bytesArray = bytes
        
        for i in 0 ..< bytesArray.count
        {
            s = s + UInt32(bytesArray[i])
        }
        
        s = s % 65536
        return UInt16(s)
    }
}

extension Data
{
    public init(hex: String)
    {
        self.init(Array<UInt8>(hex: hex))
    }
    
    public var bytes: Array<UInt8>
    {
        return Array(self)
    }
    
    public func toHexString() -> String
    {
        return bytes.`lazy`.reduce("")
        {
            var s = String($1, radix: 16)
            if s.count == 1
            {
                s = "0" + s
            }
            return $0 + s
        }
    }
}


public extension Data
{
    @inlinable var pointee: UnsafeRawPointer
    {
        let p: UnsafeRawPointer = self.withUnsafeBytes { rawBufferPointer in
            return rawBufferPointer.baseAddress!
        }
        
        return p
    }
}

extension Data
{
    var uint8: UInt8
    {
        get
        {
            var number: UInt8 = 0
            self.copyBytes(to: &number, count: MemoryLayout<UInt8>.size)
            return number
        }
    }
}
