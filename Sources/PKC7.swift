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

protocol PKCS7Container: ASN1Decodable
{
	var payload: PKCS7Payload { get }
}

protocol PKCS7Payload: ASN1Decodable
{
	var attributes: [ReceiptAttribute] { get }
}

/// In App Receipt
class _PKCS7Container: PKCS7Container
{
	static var template: ASN1Template
	{
		return ASN1Template.universal(16).constructed()
	}
	
	var oid: ASN1SkippedField
	var signedData: SignedData
	
	enum CodingKeys: ASN1CodingKey
	{
		case oid
		case signedData
		
		var template: ASN1Template
		{
			switch self
			{
			case .oid:
				return .universal(ASN1Identifier.Tag.objectIdentifier)
			case .signedData:
				return SignedData.template
			}
		}
	}
	
}

/// Legacy In App Receipt
class __PKCS7Container: PKCS7Container
{
	static var template: ASN1Template
	{
		return ASN1Template.universal(16).constructed()
	}
	
	var oid: ASN1SkippedField
	var signedData: SignedData
	
	enum CodingKeys: ASN1CodingKey
	{
		case oid
		case signedData
		
		var template: ASN1Template
		{
			switch self
			{
			case .oid:
				return .universal(ASN1Identifier.Tag.objectIdentifier)
			case .signedData:
				return SignedData.template
			}
		}
	}
	
}

extension _PKCS7Container
{
	var payload: PKCS7Payload
	{
		return signedData.contentInfo.payload
	}
}

extension __PKCS7Container
{
	var payload: PKCS7Payload
	{
		return signedData.contentInfo.payload
	}
}

extension _PKCS7Container
{
	struct SignedData: ASN1Decodable
	{
		static var template: ASN1Template
		{
			return ASN1Template.contextSpecific(0).constructed().explicit(tag: 16).constructed()
		}
		
		var version: Int
		var alg: ASN1SkippedField
		var contentInfo: ContentInfo
		
		enum CodingKeys: ASN1CodingKey
		{
			case version
			case alg
			case contentInfo
			
			var template: ASN1Template
			{
				switch self
				{
				case .version:
					return .universal(ASN1Identifier.Tag.integer)
				case .alg:
					return ASN1Template.universal(ASN1Identifier.Tag.set).constructed()
				case .contentInfo:
					return ContentInfo.template
				}
			}
		}
	}
	
	struct ContentInfo: ASN1Decodable
	{
		static var template: ASN1Template
		{
			return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
		}
		
		var oid: ASN1SkippedField
		var payload: _Payload
		
		enum CodingKeys: ASN1CodingKey
		{
			case oid
			case payload
			
			var template: ASN1Template
			{
				switch self
				{
				case .oid:
					return .universal(ASN1Identifier.Tag.objectIdentifier)
				case .payload:
					return _Payload.template
				}
			}
		}
		
		init(from decoder: Decoder) throws
		{
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			oid = try container.decode(ASN1SkippedField.self, forKey: .oid)
			
			payload = try container.decode(_Payload.self, forKey: .payload)
		}
	}
	
	struct _Payload: PKCS7Payload
	{
		static var template: ASN1Template
		{
			return ASN1Template.contextSpecific(0).constructed().explicit(tag: ASN1Identifier.Tag.octetString).constructed().explicit(tag: ASN1Identifier.Tag.octetString).explicit(tag: ASN1Identifier.Tag.set).constructed()
		}
		
		var attributes: [ReceiptAttribute]
		
		init(from decoder: Decoder) throws
		{
			var container = try decoder.unkeyedContainer()
			
			var attr: [ReceiptAttribute] = []
			while !container.isAtEnd
			{
				do
			{
				let element = try container.decode(ReceiptAttribute.self)
				attr.append(element)
			}catch{
				assertionFailure("Something wrong here")
			}
			}
			
			attributes = attr
		}
	}
}

/// Legacy
extension __PKCS7Container
{
	struct SignedData: ASN1Decodable
	{
		static var template: ASN1Template
		{
			return ASN1Template.contextSpecific(0).constructed().explicit(tag: 16).constructed()
		}
		
		var version: Int
		var alg: ASN1SkippedField
		var contentInfo: ContentInfo
		
		enum CodingKeys: ASN1CodingKey
		{
			case version
			case alg
			case contentInfo
			
			var template: ASN1Template
			{
				switch self
				{
				case .version:
					return .universal(ASN1Identifier.Tag.integer)
				case .alg:
					return ASN1Template.universal(ASN1Identifier.Tag.set).constructed()
				case .contentInfo:
					return ContentInfo.template
				}
			}
		}
	}
	
	struct ContentInfo: ASN1Decodable
	{
		static var template: ASN1Template
		{
			return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
		}
		
		var oid: ASN1SkippedField
		var payload: __Payload
		
		enum CodingKeys: ASN1CodingKey
		{
			case oid
			case payload
			
			var template: ASN1Template
			{
				switch self
				{
				case .oid:
					return .universal(ASN1Identifier.Tag.objectIdentifier)
				case .payload:
					return __Payload.template
				}
			}
		}
		
		init(from decoder: Decoder) throws
		{
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			oid = try container.decode(ASN1SkippedField.self, forKey: .oid)
			
			payload = try container.decode(__Payload.self, forKey: .payload)
		}
	}
	
	struct __Payload: PKCS7Payload
	{
		static var template: ASN1Template
		{
			return ASN1Template.contextSpecific(0).constructed().explicit(tag: ASN1Identifier.Tag.octetString).explicit(tag: ASN1Identifier.Tag.set).constructed()
		}
		
		var attributes: [ReceiptAttribute]
		
		init(from decoder: Decoder) throws
		{
			var container = try decoder.unkeyedContainer()
			
			var attr: [ReceiptAttribute] = []
			while !container.isAtEnd
			{
				do
			{
				let element = try container.decode(ReceiptAttribute.self)
				attr.append(element)
			}catch{
				assertionFailure("Something wrong here")
			}
			}
			
			attributes = attr
		}
	}
}


struct ReceiptAttribute: ASN1Decodable
{
	static var template: ASN1Template
	{
		return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
	}
	
	var type: Int
	var version: Int
	var value: Data
	
	enum CodingKeys: ASN1CodingKey
	{
		case type
		case version
		case value
		
		
		var template: ASN1Template
		{
			switch self
			{
			case .type:
				return .universal(ASN1Identifier.Tag.integer)
			case .version:
				return .universal(ASN1Identifier.Tag.integer)
			case .value:
				return .universal(ASN1Identifier.Tag.octetString)
			}
		}
	}
}

extension PKCS7Container
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
        if !ASN1Object.isDataValid(checkingLength: false, &data) { return nil }
        
        do
        {
            let r = checkContentExistance(by: oid, in: &data)
            
            guard r.0, let offset = r.offset else
            {
                return nil
            }
            
            var contentData = data[offset..<data.endIndex]
            let _ = try ASN1Object.extractIdentifier(from: &contentData)
            let contentDataLength = try ASN1Object.extractLenght(from: &contentData)
            let contentEnd = offset + ASN1Object.identifierLenght + contentDataLength.offset + contentDataLength.value
            return data[offset..<contentEnd]
        }catch{
            return nil
        }
    }
    
    /// Check if any data available for provided pkcs7 oid
    ///
    ///
    func checkContentExistance(by oid: PKC7.OID) -> Bool
    {
        var raw = Data()
        
        let r = checkContentExistance(by: oid, in: &raw)
        guard r.0, let _ = r.offset else
        {
            return false
        }
        
        return true
    }
    
    /// Extract content by pkcs7 oid
    ///
    /// - Returns: Data slice make sure you allocate memory and copy bytes for long term usage
    func checkContentExistance(by oid: PKC7.OID, in data: inout Data) -> (Bool, offset: Int?)
    {
        if !ASN1Object.isDataValid(checkingLength: false, &data) { return (false, nil) }
        
        do
        {
            let id = try ASN1Object.extractIdentifier(from: &data)
            let l = try ASN1Object.extractLenght(from: &data)
            
            var cStart = data.startIndex + ASN1Object.identifierLenght + l.offset
            let cEnd = data.endIndex
            
            if id.encodingType == .constructed
            {
                return checkContentExistance(by: oid, in: &data[cStart..<cEnd])
            }
            
            var foundedOid: String?
            
            if id.type == .objectIdentifier
            {
                let end = cStart + l.value
                var slice = data[cStart..<end]
                foundedOid = ASN1.readOid(contentData: &slice)
            }
            
            cStart += l.value
            
            guard let fOid = foundedOid, fOid == oid.rawValue else
            {
                return checkContentExistance(by: oid, in: &data[cStart..<cEnd])
            }
            
            var contentData = data[cStart..<cEnd]
            let _ = try ASN1Object.extractIdentifier(from: &contentData)
            let _ = try ASN1Object.extractLenght(from: &contentData)
            return (true, cStart)
        }catch{
            return (false, nil)
        }
    }
}

extension PKCS7Container
{
    var base64: String
    {
		var raw = Data()
        return raw.base64EncodedString()
    }
}
