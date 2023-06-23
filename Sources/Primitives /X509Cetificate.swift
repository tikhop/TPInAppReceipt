//
//  X509Cetificate.swift
//  
//
//  Created by PT on 6/22/23.
//

import Foundation
import SwiftASN1

// MARK: X509Cetificate

/// The X.509 v3 certificate
/// Certificate  ::=  SEQUENCE  {
///     tbsCertificate       TBSCertificate,
///     signatureAlgorithm   AlgorithmIdentifier,
///     signatureValue       BIT STRING  }
///
public struct X509Cetificate: DERImplicitlyTaggable {
    public static var defaultIdentifier: ASN1Identifier {
        .sequence
    }
    
    let tbsCertificate: ASN1Any
    let signatureAlgorithm: AlgorithmIdentifier
    let signatureValue: ASN1BitString
    
    public init(derEncoded: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(derEncoded, identifier: identifier) { nodes in
            let tbsCertificate = try ASN1Any(derEncoded: &nodes)
            let signatureAlgorithm = try AlgorithmIdentifier(derEncoded: &nodes)
            let signatureValue = try ASN1BitString(derEncoded: &nodes)
            
            return .init(tbsCertificate: tbsCertificate,
                         signatureAlgorithm: signatureAlgorithm,
                         signatureValue: signatureValue)
        }
    }
    
    public init(tbsCertificate: ASN1Any, signatureAlgorithm: AlgorithmIdentifier, signatureValue: ASN1BitString) {
        self.tbsCertificate = tbsCertificate
        self.signatureAlgorithm = signatureAlgorithm
        self.signatureValue = signatureValue
    }
    
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
    
    }
}

extension X509Cetificate: Sendable { }

public typealias SubjectPublicKeyInfo = ASN1OctetString
