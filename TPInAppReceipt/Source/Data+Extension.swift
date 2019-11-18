//
//  Data+Extension.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 29/09/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import CommonCrypto

public typealias DigestAlgorithmClosure = (_ data: UnsafePointer<UInt8>, _ dataLength: UInt32) -> [UInt8]

public enum DigestAlgorithm: CustomStringConvertible {
    case sha1
    
    func progressClosure() -> DigestAlgorithmClosure {
        var closure: DigestAlgorithmClosure?
        
        switch self {
            case .sha1:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_SHA1($0, $1, &hash)
                
                return hash
            }
        }
        
        return closure!
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
            case .sha1:
            result = CC_SHA1_DIGEST_LENGTH
        }
        return Int(result)
    }
    
    public var description: String {
        get {
            switch self {
                case .sha1:
                return "Digest.SHA1"
            }
        }
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
    
    /// Array of UInt8, to use for SecKeyEncrypt
    public func arrayOfBytes() -> [UInt8] {
        let count = self.count / MemoryLayout<UInt8>.size
        var bytesArray = [UInt8](repeating: 0, count: count)
        (self as NSData).getBytes(&bytesArray, length:count * MemoryLayout<UInt8>.size)
        return bytesArray
    }
    
    /// Digest data to an array of UInt8
    public func digestBytes(_ algorithm:DigestAlgorithm)->[UInt8]{
        let string = (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.count)
        let stringLength = UInt32(self.count)
        
        let closure = algorithm.progressClosure()
        
        let bytes = closure(string, stringLength)
        return bytes
    }
    
    /// Digest data with an algorithm
    public func digestData(_ algorithm:DigestAlgorithm)->Data{
        let bytes = self.digestBytes(algorithm)
        return Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
    }
}
