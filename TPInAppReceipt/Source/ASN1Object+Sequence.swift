//
//  ASN1Object+Sequence.swift
//  TPInAppReceipt iOS
//
//  Created by Pavel Tikhonenko on 24/06/2019.
//  Copyright © 2019 Pavel Tikhonenko. All rights reserved.
//

import Foundation

struct ASN1Iterator: IteratorProtocol
{
    typealias Element = ASN1Object
    
    let asn1: ASN1Object
    var lastItem: ASN1Object
    var bytesLeft: Int = 0
    
    init(_ asn1: ASN1Object)
    {
        self.asn1 = asn1
        self.lastItem = asn1
        self.bytesLeft = asn1.length.value
    }
    
    mutating func next() -> Element?
    {
        guard asn1.identifier.encodingType == .constructed, bytesLeft > 0 else
        {
            return nil
        }
        
        var contents: UnsafePointer<UInt8> = lastItem.pointer
        contents = contents.advanced(by: 1) //Identifier
        contents = contents.advanced(by: lastItem.length.offset)
        
        if bytesLeft != asn1.length.value
        {
            contents = contents.advanced(by: lastItem.length.value)
        }
        
        let asn1 = ASN1Object(bytes: contents)
        lastItem = asn1
        
        bytesLeft -= asn1.bytesCount
        
        return asn1
    }
}

extension ASN1Object: Sequence
{
    func makeIterator() -> ASN1Iterator
    {
        return ASN1Iterator(self)
    }
    
    typealias Element = ASN1Object
}
