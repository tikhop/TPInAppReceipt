//
//  File.swift
//  
//
//  Created by PT on 6/22/23.
//

import Foundation
import SwiftASN1

//MARK: ASN1Set
public struct ASN1Set<Element>: DERImplicitlyTaggable where Element: DERParseable,
                                                            Element: DERSerializable,
                                                            Element: Sendable {
    public static var defaultIdentifier: ASN1Identifier {
        .set
    }
    
    var inner: [Element]
    
    public init(derEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        self = try DER.set(derEncoded, identifier: identifier, { iter in
            var arr = [Element]()
            
            while let next = iter.next() {
                arr.append(try Element(derEncoded: next))
            }
            
            return .init(inner: arr)
        })
    }
    
    private init(inner: [Element]) {
        self.inner = inner
    }
    
    public func serialize(into coder: inout SwiftASN1.DER.Serializer, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        // TODO: Implement serialize
    }
}

public extension ASN1Set {
    subscript(index: Int) -> Element {
        return inner[index]
    }
}

extension ASN1Set: Sendable { }

//MARK: ASN1Set
public struct ASN1Sequence<Element>: DERImplicitlyTaggable where Element: DERParseable,
                                                                 Element: DERSerializable,
                                                                 Element: Sendable {
    public static var defaultIdentifier: ASN1Identifier {
        .sequence
    }
    
    private var inner: [Element]
    
    public init(derEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        self = try DER.sequence(derEncoded, identifier: identifier, { iter in
            var arr = [Element]()
            
            while let next = iter.next() {
                arr.append(try Element(derEncoded: next))
            }
            
            return .init(inner: arr)
        })
    }
    
    private init(inner: [Element]) {
        self.inner = inner
    }
    
    public func serialize(into coder: inout SwiftASN1.DER.Serializer, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        // TODO: Implement serialize
    }
}

public extension ASN1Sequence {
    subscript(index: Int) -> Element {
        return inner[index]
    }
}

extension ASN1Sequence: Sendable { }
