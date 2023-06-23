//
//  File.swift
//  
//
//  Created by PT on 6/22/23.
//

import Foundation
import SwiftASN1


/// ContentType ::= OBJECT IDENTIFIER
public typealias ContentType = ASN1ObjectIdentifier
extension ContentType: Sendable { }

/// CMSVersion ::= INTEGER
public typealias CMSVersion = UInt64
extension CMSVersion: Sendable { }

public typealias DigestAlgorithmIdentifiers = ASN1Set<DigestAlgorithmIdentifier>
public typealias SignerInfos = ASN1Set<SignerInfo>
public typealias CertificateSet = ASN1Set<X509Cetificate>
public typealias SignedAttributes = ASN1Set<X509Cetificate>
public typealias UnsignedAttributes = ASN1Set<X509Cetificate>
public typealias AttributeValue = ASN1Any
public typealias SignatureValue = ASN1OctetString

//MARK: PKCS7ContentInfo

/// The receipt is a Cryptographic Message Syntax (CMS) (PKCS #7) container, as defined by RFC 5652.
/// The App Store encodes the payload of the container using Abstract Syntax Notation One (ASN.1), as defined by ITU-T X.690.
/// The payload contains a set of receipt attributes. Each receipt attribute contains a type, a version, and a value.
///
/// ContentInfo ::= SEQUENCE {
///     contentType ContentType,
///     content [0] EXPLICIT ANY DEFINED BY contentType
/// }
///
///
public struct PKCS7ContentInfo<Content>: DERImplicitlyTaggable where Content: DERImplicitlyTaggable, Content: Sendable {
    public static var defaultIdentifier: ASN1Identifier {
        return .sequence
    }
    
    public let contentType: ContentType
    public var content: Content
    
    public init(derEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        self = try DER.sequence(derEncoded, identifier: identifier) { nodes in
            let contentType = try ContentType(derEncoded: &nodes)
            
            let content = try DER.optionalExplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { node in
                return try Content(derEncoded: node)
            }
            
            guard let content else {
                fatalError("Content should be presented")
            }
            
            return try .init(contentType: contentType, content: content)
        }
    }
    
    private init(contentType: ContentType, content: Content) throws {
        self.contentType = contentType
        self.content = content
    }
    
    public func serialize(into coder: inout SwiftASN1.DER.Serializer, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        // TODO: Implement serialize
    }
}

extension PKCS7ContentInfo: Sendable { }

//MARK: SignedData

/// SignedData ::= SEQUENCE {
///     version CMSVersion,
///     digestAlgorithms DigestAlgorithmIdentifiers,
///     encapContentInfo EncapsulatedContentInfo,
///     certificates [0] IMPLICIT CertificateSet OPTIONAL,
///     crls [1] IMPLICIT RevocationInfoChoices OPTIONAL,
///     signerInfos SignerInfos }
///
///
/// - Note: For our purposes we're skipping `crls` field
///
public struct SignedData<Payload>: DERImplicitlyTaggable where Payload: DERImplicitlyTaggable, Payload: Sendable {
    public static var defaultIdentifier: SwiftASN1.ASN1Identifier {
        .sequence
    }
    
    public let version: CMSVersion
    public let digestAlgorithms: DigestAlgorithmIdentifiers
    public let encapContentInfo: EncapsulatedContentInfo<Payload>
    public let certificates: CertificateSet?
    public let crls: ASN1Any?
    public let signerInfos: SignerInfos
    
    public init(derEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        self = try DER.sequence(derEncoded, identifier: identifier) { nodes in
            let version = try UInt64(derEncoded: &nodes)
            let digestAlgorithmIdentifiers = try DigestAlgorithmIdentifiers(derEncoded: &nodes)
            let encapContentInfo = try EncapsulatedContentInfo<Payload>(derEncoded: &nodes)
            
            let certificates = try DER.optionalImplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific, { node in
                try CertificateSet(derEncoded: node, withIdentifier: .init(tagWithNumber: 0, tagClass: .contextSpecific))
            })
            //let certificates: CertificateSet? = nil
            // We ignore the `crls` attribute
            _ = try DER.optionalExplicitlyTagged(&nodes, tagNumber: 1, tagClass: .contextSpecific) { _ in }
            
            let signerInfos = try SignerInfos(derEncoded: &nodes)
            
            return .init(version: version,
                         digestAlgorithms: digestAlgorithmIdentifiers,
                         encapContentInfo: encapContentInfo,
                         certificates: certificates,
                         crls: nil,
                         signerInfos: signerInfos)
        }
    }
    
    private init(version: UInt64,
                 digestAlgorithms: DigestAlgorithmIdentifiers,
                 encapContentInfo: EncapsulatedContentInfo<Payload>,
                 certificates: CertificateSet?,
                 crls: ASN1Any?,
                 signerInfos: SignerInfos) {
        self.version = version
        self.digestAlgorithms = digestAlgorithms
        self.encapContentInfo = encapContentInfo
        self.certificates = certificates
        self.crls = crls
        self.signerInfos = signerInfos
    }
    
    public func serialize(into coder: inout SwiftASN1.DER.Serializer, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        // TODO: Implement serialize
    }
}

extension SignedData: Sendable { }

// MARK: EncapsulatedContentInfo

//  EncapsulatedContentInfo ::= SEQUENCE {
//      eContentType ContentType,
//      eContent [0] EXPLICIT OCTET STRING OPTIONAL }
//
//  ContentType ::= OBJECT IDENTIFIER
public struct EncapsulatedContentInfo<Payload>: DERImplicitlyTaggable where Payload: DERImplicitlyTaggable,
                                                                            Payload: Sendable {
    public static var defaultIdentifier: SwiftASN1.ASN1Identifier {
        .sequence
    }
    
    let eContentType: ContentType
    let eContent: Payload?
    
    public init(derEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        self = try DER.sequence(derEncoded, identifier: identifier) { nodes in
            let eContentType = try ContentType(derEncoded: &nodes)
            
            guard let node = nodes.next() else {
                return .init(eContentType: eContentType, eContent: nil)
            }
            
            let eContent = try DER.explicitlyTagged(node, tagNumber: 0, tagClass: .contextSpecific) { node in
                try Payload(derEncoded: node)
            }
            
            return .init(eContentType: eContentType, eContent: eContent)
        }
    }
    
    public init(eContentType: ContentType, eContent: Payload?) {
        self.eContentType = eContentType
        self.eContent = eContent
    }
    
    public func serialize(into coder: inout SwiftASN1.DER.Serializer, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        // TODO: Implement serialize
    }
}

extension EncapsulatedContentInfo: Sendable { }

// MARK: SignerInfo

public struct SignerInfo: DERImplicitlyTaggable {
    @inlinable
    public static var defaultIdentifier: ASN1Identifier {
        .sequence
    }
    
    public let version: CMSVersion
    public let sid: SignerIdentifier
    public let digestAlgorithm: DigestAlgorithmIdentifier
    public let signedAttrs: SignedAttributes?
    public let signatureAlgorithm: SignatureAlgorithmIdentifier
    public let signature: SignatureValue
    public let unsignedAttrs: UnsignedAttributes?
    
    @inlinable
    public init(derEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        self = try DER.sequence(derEncoded, identifier: identifier) { nodes in
            let version = try UInt64(derEncoded: &nodes)
            
            guard let sidNode = nodes.next() else {
                fatalError("Can't decode SignerIdentifier")
            }
            
            let sid = try SignerIdentifier(derEncoded: sidNode, version: version)
            let digestAlgorithm = try DigestAlgorithmIdentifier(derEncoded: &nodes)
            let signedAttrs = try DER.optionalImplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { node in
                try SignedAttributes(derEncoded: node)
            }
            let signatureAlgorithm = try SignatureAlgorithmIdentifier(derEncoded: &nodes)
            let signature = try SignatureValue(derEncoded: &nodes)
            let unsignedAttrs = try DER.optionalImplicitlyTagged(&nodes, tagNumber: 1, tagClass: .contextSpecific) { node in
                try UnsignedAttributes(derEncoded: node)
            }
            
            return .init(version: version,
                         sid: sid,
                         digestAlgorithm: digestAlgorithm,
                         signedAttrs: signedAttrs,
                         signatureAlgorithm: signatureAlgorithm,
                         signature: signature,
                         unsignedAttrs: unsignedAttrs)
        }
    }
    
    @inlinable
    init(version: CMSVersion, sid: SignerIdentifier, digestAlgorithm: DigestAlgorithmIdentifier, signedAttrs: SignedAttributes?, signatureAlgorithm: SignatureAlgorithmIdentifier, signature: SignatureValue, unsignedAttrs: UnsignedAttributes?) {
        self.version = version
        self.sid = sid
        self.digestAlgorithm = digestAlgorithm
        self.signedAttrs = signedAttrs
        self.signatureAlgorithm = signatureAlgorithm
        self.signature = signature
        self.unsignedAttrs = unsignedAttrs
    }
    
    @inlinable
    public func serialize(into coder: inout SwiftASN1.DER.Serializer, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        // TODO: Implement serialize
    }
}

extension SignerInfo: Sendable { }

public enum SignerIdentifier: DERParseable, DERSerializable {
    
    public init(derEncoded: SwiftASN1.ASN1Node, version: CMSVersion) throws {
        switch version {
        case 1:
            self = .issuerAndSerialNumber(try IssuerAndSerialNumber(derEncoded: derEncoded))
        case 3:
            self = .subjectPublicKeyInfo(try? SubjectPublicKeyInfo(derEncoded: derEncoded))
        default:
            fatalError("Version should be either 1 or 3")
        }
    }
    
    public init(derEncoded: SwiftASN1.ASN1Node) throws {
        if let issuerAndSerialNumber = try? IssuerAndSerialNumber(derEncoded: derEncoded) {
            self = .issuerAndSerialNumber(issuerAndSerialNumber)
        }
        
        if let subjectPublicKeyInfo = try? SubjectPublicKeyInfo(derEncoded: derEncoded) {
            self = .subjectPublicKeyInfo(subjectPublicKeyInfo)
        }
        
        fatalError("SignerIdentifier not found")
    }
    
    public func serialize(into coder: inout SwiftASN1.DER.Serializer) throws {
        //NOP
    }
        
    case issuerAndSerialNumber(IssuerAndSerialNumber)
    case subjectPublicKeyInfo(SubjectPublicKeyInfo?)
}

extension SignerIdentifier: Sendable { }

public struct IssuerAndSerialNumber: DERImplicitlyTaggable {
    public static var defaultIdentifier: ASN1Identifier {
        .sequence
    }
    
    public let issuer: ASN1Any //Name
    public let serialNumber: [UInt8]
    
    public init(derEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        self = try DER.sequence(derEncoded, identifier: identifier) { nodes in
            let issuer = try ASN1Any(derEncoded: &nodes)
            
            guard let serialNumberNode = nodes.next() else {
                fatalError("Serial number should be presented")
            }
            
            guard case ASN1Node.Content.primitive(let bytes) = serialNumberNode.content else {
                fatalError("Serial number should be array of bytes")
            }
            
            let serialNumber = Array(bytes)
            return .init(issuer: issuer, serialNumber: serialNumber)
        }
    }
    
    private init(issuer: ASN1Any, serialNumber: [UInt8]) {
        self.issuer = issuer
        self.serialNumber = serialNumber
    }
    
    public func serialize(into coder: inout SwiftASN1.DER.Serializer, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        // TODO: Implement serialize
    }
}

extension IssuerAndSerialNumber: Sendable { }

public struct Attribute: DERImplicitlyTaggable {
    public static var defaultIdentifier: ASN1Identifier {
        .sequence
    }
    
    public let attrType: ASN1ObjectIdentifier
    public let attrValues: ASN1Set<AttributeValue>
    
    public init(derEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        self = try DER.sequence(derEncoded, identifier: identifier) { nodes in
            let attrType = try ASN1ObjectIdentifier(derEncoded: &nodes)
            let attrValues = try ASN1Set<AttributeValue>(derEncoded: &nodes)
            return .init(attrType: attrType, attrValues: attrValues)
        }
    }
    
    private init(attrType: ASN1ObjectIdentifier, attrValues: ASN1Set<AttributeValue>) {
        self.attrType = attrType
        self.attrValues = attrValues
    }
    
    public func serialize(into coder: inout SwiftASN1.DER.Serializer, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        // TODO: Implement serialize
    }
}

extension Attribute: Sendable { }

// MARK: AlgorithmIdentifiers

public typealias DigestAlgorithmIdentifier = AlgorithmIdentifier
public typealias SignatureAlgorithmIdentifier = AlgorithmIdentifier

public struct AlgorithmIdentifier: DERImplicitlyTaggable {
    public static var defaultIdentifier: ASN1Identifier {
        .sequence
    }
    
    public let algorithm: ASN1ObjectIdentifier
    public let parameters: ASN1Any?
    
    public init(derEncoded: SwiftASN1.ASN1Node, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        self = try DER.sequence(derEncoded, identifier: identifier) { nodes in
            let algorithm = try ASN1ObjectIdentifier(derEncoded: &nodes)
            let parameters = try? ASN1Any(derEncoded: &nodes)
            return .init(algorithm: algorithm, parameters: parameters)
        }
    }
    
    private init(algorithm: ASN1ObjectIdentifier, parameters: ASN1Any?) {
        self.algorithm = algorithm
        self.parameters = parameters
    }
    
    public func serialize(into coder: inout SwiftASN1.DER.Serializer, withIdentifier identifier: SwiftASN1.ASN1Identifier) throws {
        // TODO: Implement serialize
    }
}

extension AlgorithmIdentifier: Sendable { }
