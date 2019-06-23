//
//  Asn1Coder.swift
//  TPInAppReceipt iOS
//
//  Created by Pavel Tikhonenko on 22/06/2019.
//  Copyright © 2019 Pavel Tikhonenko. All rights reserved.
//

import Foundation

class ASN1Coder
{
    func decode()
    {
        
    }
}



extension ASN1Object
{
    var type: ASN1Object.Identifier.`Type`
    {
        return identifier.type
    }
}

struct ASN1Object
{
    let identifier: Identifier
    var length: Length
    
    var rawData: Data! //Might be nil in this case use pointer
    var pointer: UnsafePointer<UInt8> //Always awailable
    var bytesCount: Int
    
    enum Length
    {
        case short(value: Int)
        case long(length: Int, value: Int)
    }
    
    struct Identifier
    {
        public enum Class: UInt8
        {
            case universal = 0
            case application = 1
            case contextSpecific = 2
            case `private` = 3
        }
        
        public enum `Type`: UInt8
        {
            case endOfContent = 0x00
            case boolean = 1
            case integer = 2
            case bitString = 3
            case octetString = 4
            case null = 5
            case objectIdentifier = 6
            case objectDescriptor = 7
            case external = 8
            case real = 9
            case enumerated = 10
            case embeddedPdv = 11
            case utf8String = 12
            case relativeOid = 13
            case sequence = 16
            case set = 17
            case numericString = 18
            case printableString = 19
            case t61String = 20
            case videotexString = 21
            case ia5String = 22
            case utcTime = 23
            case generalizedTime = 24
            case graphicString = 25
            case visibleString = 26
            case generalString = 27
            case universalString = 28
            case characterString = 29
            case bmpString = 30
            case unknown = 126
        }
        
        public enum EncodingType: UInt8
        {
            case primitive = 0
            case constructed = 1
        }
        
        let `class`: Class
        let encodingType: EncodingType
        var tagNumber: UInt8
        
        var type: `Type` { return Type(rawValue: tagNumber) ?? .unknown }
        
        let raw: UInt8
        
        init(data: Data) throws
        {
            try self.init(raw: data.uint8)
        }
        
        init(raw: UInt8) throws
        {
            self.raw = raw
            self.tagNumber = raw & 0b11111
            
            guard let c = Class(rawValue: (raw >> 5) & 0b11), let e = EncodingType(rawValue: (raw >> 4) & 0b1) else
            {
                throw ASN1Error.initializationFailed(reason: .dataIsInvalid)
            }
            
            self.class = c
            self.encodingType = e
            
            guard type != .unknown else
            {
                throw ASN1Error.initializationFailed(reason: .dataIsInvalid)
            }
        }
    }
}

extension ASN1Object
{
    //Using this initialization method we assume that data containt a proper asn1 object as defined by ITU-T X.690
    init(data: Data)
    {
        rawData = data
        bytesCount = 1
        pointer = rawData.pointer
        identifier = try! Identifier(data: data)
        length = .short(value: 0)
        length = ASN1Object.extractLenght(from: pointer.advanced(by: 1))
        bytesCount += (length.offset + length.value)
    }
    
    //Using this initialization method we assume that pointer to asn1 object containt a proper asn1 object as defined by ITU-T X.690
    init(bytes: UnsafePointer<UInt8>)
    {
        pointer = bytes
        bytesCount = 1
        identifier = try! Identifier(raw: pointer[0])
        length = .short(value: 0)
        length = ASN1Object.extractLenght(from: pointer.advanced(by: 1))
        bytesCount += (length.offset + length.value)
    }
}


extension ASN1Object.Identifier
{
    var isPrimitive: Bool
    {
        return encodingType == .primitive
    }
    
    var isConstructed: Bool
    {
        return encodingType == .constructed
    }
}

extension ASN1Object.Length
{
    var value: Int
    {
        switch self
        {
        case .long(_, let value):
            return value
        case .short(let value):
            return value
        }
    }
    
    var offset: Int
    {
        switch self
        {
        
        case .long(let length, _):
            return 1 + length
        default:
            return 1
        }
    }
}

//Value Data Types we expect from ASN1
protocol ASN1ExtractableValueTypes {}

extension ASN1Object: ASN1ExtractableValueTypes { }
extension Bool: ASN1ExtractableValueTypes { }
extension Data: ASN1ExtractableValueTypes { }
extension String: ASN1ExtractableValueTypes { }
extension Date: ASN1ExtractableValueTypes { }
extension Int: ASN1ExtractableValueTypes { }


/// `ASN1Error`
public enum ASN1Error: Error
{
    case initializationFailed(reason: InitializationFailureReason)
    case validationFailed(reason: ValidationFailureReason)
    
    
    /// The underlying reason the receipt initialization error occurred.
    ///
    /// - dataIsInvalid:         Provided data don't contain any asn1 object
    public enum InitializationFailureReason
    {
        case dataIsInvalid
    }
    
    /// The underlying reason the receipt validation error occurred.
    ///
    /// - hashValidation:          Computed hash doesn't match the hash from the receipt's payload
    /// - signatureValidation:     Error occurs during signature validation. It has several reasons to failure
    public enum ValidationFailureReason
    {
        case hashValidation
        case signatureValidation(SignatureValidationFailureReason)
    }
    
    /// The underlying reason the signature validation error occurred.
    ///
    /// - rootCertificateNotFound:          Apple Inc Root Certificate Not Found
    /// - invalidSignature:                 The receipt contains invalid signature
    public enum SignatureValidationFailureReason
    {
        case rootCertificateNotFound
        case invalidSignature
    }
}
