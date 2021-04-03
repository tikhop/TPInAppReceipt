//
//  InAppReceipt+ASN1Decodable.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 04/08/20.
//  Copyright © 2017-2021 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import ASN1Swift

class _InAppReceipt
{
	private var pkcs7container: PKCS7Container
	
	var payload: InAppReceiptPayload!
	
	init(rawData: Data) throws
	{
		let asn1decoder = ASN1Decoder()
		self.pkcs7container = try asn1decoder.decode(PKCS7Container.self, from: rawData)
		
		do
		{
			self.payload = try asn1decoder.decode(PayloadContainer.self, from: pkcs7container.signedData.contentInfo.payload.rawData).payload
		}catch{
			self.payload = try asn1decoder.decode(_PayloadContainer.self, from: pkcs7container.signedData.contentInfo.payload.rawData).payload
		}
	}
}

extension _InAppReceipt
{
	var digestAlgorithm: SecKeyAlgorithm?
	{
		guard let algName = pkcs7container.signedData.alg.items.first?.algorithm else
		{
			return nil
		}
		
		guard let alg = OID(rawValue: algName)?.encryptionAlgorithm() else
		{
			return nil
		}
		
		return alg
	}
	
	var worldwideDeveloperCertificateData: Data?
	{
		let arr = pkcs7container.signedData.certificates.certificates
		
		guard arr.count >= 2 else
		{
			return nil
		}
		
		return arr[1].rawData
	}
	
	var signatureData: Data
	{
		return pkcs7container.signedData.signerInfos.encryptedDigest
	}
	
	var iTunesCertificateContainer: PKCS7Container.Certificate?
	{
		return pkcs7container.signedData.certificates.certificates.first
	}
	
	var iTunesCertificateData: Data?
	{
		return iTunesCertificateContainer?.rawData
	}
	
	var iTunesPublicKeyData: Data?
	{
		return iTunesCertificateContainer?.cert.subjectPublicKeyInfo
	}
}

extension InAppReceiptPayload: ASN1Decodable
{
	static var template: ASN1Template
	{
		return ASN1Template.universal(ASN1Identifier.Tag.octetString)
	}
	
	enum CodingKeys: ASN1CodingKey
	{
		case set
		
		var template: ASN1Template
		{
			return ASN1Template.universal(ASN1Identifier.Tag.set).constructed()
		}
	}
	
	init(from decoder: Decoder) throws
	{
		let asn1d = decoder as! ASN1DecoderProtocol
		
		let rawData: Data = try asn1d.extractValueData()
		var bundleIdentifier = ""
		var bundleIdentifierData = Data()
		var appVersion = ""
		var originalAppVersion = ""
		var purchases = [InAppPurchase]()
		var opaqueValue = Data()
		var receiptHash = Data()
		var expirationDate: Date?
		var receiptCreationDate: Date!
		var ageRating: String = ""
		var environment: String = ""
		
		let c = try decoder.container(keyedBy: CodingKeys.self)
		var container = try c.nestedUnkeyedContainer(forKey: .set) as! ASN1UnkeyedDecodingContainerProtocol
		
		while !container.isAtEnd
		{
			do
			{
				var attributeContainer = try container.nestedUnkeyedContainer(for: ReceiptAttribute.template) as! ASN1UnkeyedDecodingContainerProtocol
				let type: Int32 = try attributeContainer.decode(Int32.self)
				let _ = try attributeContainer.skip(template: .universal(ASN1Identifier.Tag.integer)) // Consume
				var valueContainer = try attributeContainer.nestedUnkeyedContainer(for: .universal(ASN1Identifier.Tag.octetString)) as! ASN1UnkeyedDecodingContainerProtocol
				
				switch type
				{
				case InAppReceiptField.bundleIdentifier:
					bundleIdentifier = try valueContainer.decode(String.self)
					bundleIdentifierData = valueContainer.valueData
				case InAppReceiptField.appVersion:
					appVersion = try valueContainer.decode(String.self)
				case InAppReceiptField.opaqueValue:
					opaqueValue = valueContainer.valueData
				case InAppReceiptField.receiptHash:
					receiptHash = valueContainer.valueData
				case InAppReceiptField.inAppPurchaseReceipt:
					purchases.append(try valueContainer.decode(InAppPurchase.self))
				case InAppReceiptField.originalAppVersion:
					originalAppVersion = try valueContainer.decode(String.self)
				case InAppReceiptField.expirationDate:
					let expirationDateString = try valueContainer.decode(String.self, template: .universal(ASN1Identifier.Tag.ia5String))
					expirationDate = expirationDateString.rfc3339date()
				case InAppReceiptField.receiptCreationDate:
					let receiptCreationDateString = try valueContainer.decode(String.self, template: .universal(ASN1Identifier.Tag.ia5String))
					receiptCreationDate = receiptCreationDateString.rfc3339date()
				case InAppReceiptField.ageRating:
					ageRating = try valueContainer.decode(String.self, template: .universal(ASN1Identifier.Tag.ia5String))
				case InAppReceiptField.environment:
					environment = try valueContainer.decode(String.self)
				default:
					break
				}
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
				  ageRating: ageRating,
				  environment: environment,
				  rawData: rawData)
	}
}

extension InAppPurchase: ASN1Decodable
{
	public init(from decoder: Decoder) throws
	{
		var container = try decoder.unkeyedContainer() as! ASN1UnkeyedDecodingContainerProtocol
		
		var originalTransactionIdentifier = ""
		var productIdentifier = ""
		var transactionIdentifier = ""
		var purchaseDate: Date!
		var originalPurchaseDate: Date!
		
		while !container.isAtEnd
		{
			do
			{
				var attributeContainer = try container.nestedUnkeyedContainer(for: ReceiptAttribute.template) as! ASN1UnkeyedDecodingContainerProtocol
				let type: Int32 = try attributeContainer.decode(Int32.self)
				let _ = try attributeContainer.skip(template: .universal(ASN1Identifier.Tag.integer)) // Consume
				var valueContainer = try attributeContainer.nestedUnkeyedContainer(for: .universal(ASN1Identifier.Tag.octetString)) as! ASN1UnkeyedDecodingContainerProtocol
		
				switch type
				{
				case InAppReceiptField.quantity:
					quantity = try valueContainer.decode(Int.self)
				case InAppReceiptField.productIdentifier:
					productIdentifier = try valueContainer.decode(String.self)
				case InAppReceiptField.productType:
					productType = Type(rawValue: try valueContainer.decode(Int32.self)) ?? .unknown
				case InAppReceiptField.transactionIdentifier:
					transactionIdentifier = try valueContainer.decode(String.self)
				case InAppReceiptField.purchaseDate:
					let purchaseDateString = try valueContainer.decode(String.self, template: .universal(ASN1Identifier.Tag.ia5String))
					purchaseDate = purchaseDateString.rfc3339date()
				case InAppReceiptField.originalTransactionIdentifier:
					originalTransactionIdentifier = try valueContainer.decode(String.self)
				case InAppReceiptField.originalPurchaseDate:
					let originalPurchaseDateString = try valueContainer.decode(String.self, template: .universal(ASN1Identifier.Tag.ia5String))
					originalPurchaseDate = originalPurchaseDateString.rfc3339date()
				case InAppReceiptField.subscriptionExpirationDate:
					let str = try valueContainer.decode(String.self, template: .universal(ASN1Identifier.Tag.ia5String))
					let subscriptionExpirationDateString = str == "" ? nil : str
					subscriptionExpirationDate = subscriptionExpirationDateString?.rfc3339date()
				case InAppReceiptField.cancellationDate:
					let str = try valueContainer.decode(String.self, template: .universal(ASN1Identifier.Tag.ia5String))
					let cancellationDateString = str == "" ? nil : str
					cancellationDate = cancellationDateString?.rfc3339date()
				case InAppReceiptField.webOrderLineItemID:
					webOrderLineItemID = try valueContainer.decode(Int.self)
				case InAppReceiptField.subscriptionTrialPeriod:
					subscriptionTrialPeriod = (try valueContainer.decode(Int32.self)) != 0
				case InAppReceiptField.subscriptionIntroductoryPricePeriod:
					subscriptionIntroductoryPricePeriod = (try valueContainer.decode(Int32.self)) != 0
				case InAppReceiptField.promotionalOfferIdentifier:
					promotionalOfferIdentifier = try valueContainer.decode(String.self)
				default:
					break
				}
			}
		}
		
		self.originalTransactionIdentifier = originalTransactionIdentifier
		self.productIdentifier = productIdentifier
		self.transactionIdentifier = transactionIdentifier
		self.purchaseDate = purchaseDate
		self.originalPurchaseDate = originalPurchaseDate
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

/// Legacy payload format
struct _PayloadContainer: ASN1Decodable
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
