//
//  PCKS7.swift
//  TPInAppReceipt iOS
//
//  Created by Pavel Tikhonenko on 22/06/2019.
//  Copyright © 2019-2020 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import ASN1Swift

enum OID: String
{
	/// NIST Algorithm
	case sha1 = "1.3.14.3.2.26"
	case sha256 = "2.16.840.1.101.3.4.2.1"
	
	/// PKCS1
	case sha1WithRSAEncryption = "1.2.840.113549.1.1.5"
	case sha256WithRSAEncryption = " 1.2.840.113549.1.1.11"
	
	/// PKCS7
	case data = "1.2.840.113549.1.7.1"
	case signedData = "1.2.840.113549.1.7.2"
	case envelopedData = "1.2.840.113549.1.7.3"
	case signedAndEnvelopedData = "1.2.840.113549.1.7.4"
	case digestedData = "1.2.840.113549.1.7.5"
	case encryptedData = "1.2.840.113549.1.7.6"
}

extension OID
{
	@available(iOS 10.0, *)
	func encryptionAlgorithm() -> SecKeyAlgorithm
	{
		switch self
		{
		case .sha1:
			return SecKeyAlgorithm.rsaSignatureMessagePKCS1v15SHA1
		case .sha256:
			return SecKeyAlgorithm.rsaSignatureMessagePKCS1v15SHA256
		case .sha1WithRSAEncryption:
			return SecKeyAlgorithm.rsaEncryptionOAEPSHA1
		case .sha256WithRSAEncryption:
			return SecKeyAlgorithm.rsaEncryptionOAEPSHA256
		default:
			assertionFailure("Don't even try to obtain a value for this type")
			return SecKeyAlgorithm.rsaSignatureRaw
		}
	}
}

protocol PKCS7: ASN1Decodable
{
	var payload: PKCS7Payload { get }
	var signedData: PKCS7Container.SignedData { get }
	
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
