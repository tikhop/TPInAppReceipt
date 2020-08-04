//
//  File.swift
//  
//
//  Created by Pavel Tikhonenko on 04.08.2020.
//

import Foundation
import ASN1Swift

protocol _InAppReceipt: PKCS7
{
	var receiptPayload: InAppReceiptPayload { get }
}

extension _InAppReceipt
{
	var receiptPayload: InAppReceiptPayload { return payload as! InAppReceiptPayload }
}

extension InAppReceiptPayload: PKCS7Payload
{
	static var template: ASN1Template
	{
		return ASN1Template.universal(ASN1Identifier.Tag.octetString).explicit(tag: ASN1Identifier.Tag.set).constructed()
	}
		
	init(from decoder: Decoder) throws
	{
		var container = try decoder.unkeyedContainer()
		
		var bundleIdentifier = ""
		var bundleIdentifierData = Data()
		var appVersion = ""
		var originalAppVersion = ""
		var purchases = [InAppPurchase]()
		var opaqueValue = Data()
		var receiptHash = Data()
		var expirationDate: String? = ""
		var receiptCreationDate: String = ""
		var environment: String = ""

		
		var attr: [ReceiptAttribute] = []
		
		let asn1Decoder = ASN1Decoder()
		
		while !container.isAtEnd
		{
			do
			{
				let attribute = try container.decode(ReceiptAttribute.self)
				
				guard let receiptField = InAppReceiptField(rawValue: attribute.type) else
				{
					continue
				}
				
				let octetString = attribute.value
				let valueData = try asn1Decoder.decode(Data.self, from: octetString, template: .universal(ASN1Identifier.Tag.octetString))
				
				switch (receiptField)
				{
				case .bundleIdentifier:
					bundleIdentifier = try asn1Decoder.decode(String.self, from: valueData)
					bundleIdentifierData = octetString //valueData TODO: check this
				case .appVersion:
					appVersion = try asn1Decoder.decode(String.self, from: valueData)
				case .opaqueValue:
					opaqueValue = valueData
				case .receiptHash:
					receiptHash = valueData
				case .inAppPurchaseReceipt:
					purchases.append(try asn1Decoder.decode(InAppPurchase.self, from: valueData))
					break
				case .originalAppVersion:
					originalAppVersion = try asn1Decoder.decode(String.self, from: valueData)
				case .expirationDate:
					expirationDate = try asn1Decoder.decode(String.self, from: valueData, template: .universal(ASN1Identifier.Tag.ia5String))
				case .receiptCreationDate:
					receiptCreationDate = try asn1Decoder.decode(String.self, from: valueData, template: .universal(ASN1Identifier.Tag.ia5String))
				case .environment:
					environment = try asn1Decoder.decode(String.self, from: valueData)
				default:
					print("attribute.type = \(String(describing: attribute.type)))")
				}

				attr.append(attribute)
			}catch{
				assertionFailure("Something wrong here")
			}
		}
		
		self.init(bundleIdentifier: bundleIdentifier,
				  appVersion: appVersion,
				  originalAppVersion: originalAppVersion,
				  purchases: purchases,
				  expirationDate: expirationDate,
				  bundleIdentifierData: bundleIdentifierData,
				  opaqueValue: opaqueValue,
				  receiptHash: receiptHash,
				  creationDate: receiptCreationDate,
				  environment: environment)
	}
}

extension InAppPurchase: ASN1Decodable
{
	public init(from decoder: Decoder) throws
	{
		
		self.init()
		
		var container = try decoder.unkeyedContainer()
		let asn1Decoder = ASN1Decoder()
		
		while !container.isAtEnd
		{
			do
			{
				let attribute = try container.decode(ReceiptAttribute.self)
				
				guard let field = InAppReceiptField(rawValue: attribute.type) else
				{
					continue
				}
				
				let octetString = attribute.value
				let valueData = try asn1Decoder.decode(Data.self, from: octetString, template: .universal(ASN1Identifier.Tag.octetString))
				
				switch field
				{
				case .quantity:
					quantity = try asn1Decoder.decode(Int.self, from: valueData)
				case .productIdentifier:
					productIdentifier = try asn1Decoder.decode(String.self, from: valueData)
				case .productType:
					productType = Type(rawValue: try asn1Decoder.decode(Int.self, from: valueData)) ?? .unknown
				case .transactionIdentifier:
					transactionIdentifier = try asn1Decoder.decode(String.self, from: valueData)
				case .purchaseDate:
					purchaseDateString = try asn1Decoder.decode(String.self, from: valueData, template: .universal(ASN1Identifier.Tag.ia5String))
				case .originalTransactionIdentifier:
					originalTransactionIdentifier = try asn1Decoder.decode(String.self, from: valueData)
				case .originalPurchaseDate:
					originalPurchaseDateString = try asn1Decoder.decode(String.self, from: valueData, template: .universal(ASN1Identifier.Tag.ia5String))
				case .subscriptionExpirationDate:
					if !valueData.isEmpty
					{
						let str = try asn1Decoder.decode(String.self, from: valueData, template: .universal(ASN1Identifier.Tag.ia5String))
						subscriptionExpirationDateString = str == "" ? nil : str
					}
				case .cancellationDate:
					if !valueData.isEmpty
					{
						let str = try asn1Decoder.decode(String.self, from: valueData, template: .universal(ASN1Identifier.Tag.ia5String))
						cancellationDateString = str == "" ? nil : str
					}
				case .webOrderLineItemID:
					webOrderLineItemID = try asn1Decoder.decode(Int.self, from: valueData)
				case .subscriptionTrialPeriod:
					subscriptionTrialPeriod = (try asn1Decoder.decode(Int.self, from: valueData)) != 0
				case .subscriptionIntroductoryPricePeriod:
					subscriptionIntroductoryPricePeriod = (try asn1Decoder.decode(Int.self, from: valueData)) != 0
				case .promotionalOfferIdentifier:
					promotionalOfferIdentifier = try asn1Decoder.decode(String.self, from: valueData)
				default:
					break
				}
			}
		}
	}
	
	public static var template: ASN1Template
	{
		return ASN1Template.universal(ASN1Identifier.Tag.set).constructed()
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

/// In App Receipt
class _PKCS7Container: _InAppReceipt
{
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
		return signedData.contentInfo.payload.payload
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
		var payload: PayloadContainer
		
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
					return PayloadContainer.template
				}
			}
		}
	}
	
	struct PayloadContainer: ASN1Decodable
	{
		var payload: InAppReceiptPayload
		
		static var template: ASN1Template
		{
			return ASN1Template.contextSpecific(0).constructed().explicit(tag: ASN1Identifier.Tag.octetString).constructed()
		}
		
		enum CodingKeys: ASN1CodingKey
		{
			case payload
			
			var template: ASN1Template
			{
				switch self
				{
				case .payload:
					return InAppReceiptPayload.template
				}
			}
		}
	}
}

/// Legacy In App Receipt
class __PKCS7Container: _InAppReceipt
{
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

extension __PKCS7Container
{
	var payload: PKCS7Payload
	{
		return signedData.contentInfo.payload.payload
	}
}

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
		var payload: PayloadContainer
		
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
					return PayloadContainer.template
				}
			}
		}
	}
	
	struct PayloadContainer: ASN1Decodable
	{
		var payload: InAppReceiptPayload
		
		static var template: ASN1Template
		{
			return ASN1Template.contextSpecific(0).constructed()
		}
		
		enum CodingKeys: ASN1CodingKey
		{
			case payload
			
			var template: ASN1Template
			{
				switch self
				{
				case .payload:
					return InAppReceiptPayload.template
				}
			}
		}
	}
}
