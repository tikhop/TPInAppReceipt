//
//  PCKS7.swift
//  TPInAppReceipt iOS
//
//  Created by Pavel Tikhonenko on 22/06/2019.
//  Copyright © 2019-2020 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import ASN1Swift

struct PKC7
{
    enum OID: String
    {
        case data = "1.2.840.113549.1.7.1"
        case signedData = "1.2.840.113549.1.7.2"
        case envelopedData = "1.2.840.113549.1.7.3"
        case signedAndEnvelopedData = "1.2.840.113549.1.7.4"
        case digestedData = "1.2.840.113549.1.7.5"
        case encryptedData = "1.2.840.113549.1.7.6"
    }
}

protocol PKCS7: ASN1Decodable
{
	var payload: PKCS7Payload { get }
}

extension PKCS7
{
	static var template: ASN1Template
	{
		return ASN1Template.universal(16).constructed()
	}
}

protocol PKCS7Payload: ASN1Decodable
{

}


extension PKCS7
{
    /// Find content by pkcs7 oid
    ///
    /// - Returns: Data slice make sure you allocate memory and copy bytes for long term usage
    func extractContent(by oid: PKC7.OID) -> Data?
    {
		var raw = Data()
        return extractContent(by: oid, from: &raw)
    }
    
    /// Extract content by pkcs7 oid
    ///
    /// - Returns: Data slice make sure you allocate memory and copy bytes for long term usage
    func extractContent(by oid: PKC7.OID, from data: inout Data) -> Data?
    {
        return nil
    }

}

struct CertificateSet: ASN1Decodable
{
	static var template: ASN1Template { return ASN1Template.contextSpecific(0).constructed().implicit(tag: ASN1Identifier.Tag.set)}
}
