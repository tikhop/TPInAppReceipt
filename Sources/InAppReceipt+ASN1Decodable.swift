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
	
	var iTunesCertificateData: Data? { get }
	var iTunesPublicKeyData: Data? { get }
	var worldwideDeveloperCertificateData: Data? { get }
	var signatureData: Data { get }
	var digestAlgorithm: SecKeyAlgorithm? { get }
}

extension PKCS7Container
{
	var payload: PKCS7Payload
	{
		return signedData.contentInfo.payload
	}
		
	var digestAlgorithm: SecKeyAlgorithm?
	{
		guard let algName = signedData.alg.items.first?.algorithm else
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
		let arr = signedData.certificates.certificates
		
		guard arr.count >= 2 else
		{
			return nil
		}
		
		return arr[1].rawData
	}
	
	var signatureData: Data
	{
		return signedData.signerInfos.encryptedDigest
	}
	
	var iTunesCertificateContainer: PKCS7Container.Certificate?
	{
		return signedData.certificates.certificates.first
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

extension _InAppReceipt
{
	var receiptPayload: InAppReceiptPayload { return payload as! InAppReceiptPayload }
}

extension InAppReceiptPayload: PKCS7Payload
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
		let c = try decoder.container(keyedBy: CodingKeys.self)
		
		var container = try c.nestedUnkeyedContainer(forKey: .set)
		
		let rawData: Data = try asn1d.extractValueData()
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
				  environment: environment,
				  rawData: rawData)
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
class PKCS7Container: _InAppReceipt
{
	
	
	var oid: ASN1SkippedField
	private(set) var signedData: SignedData
	
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



extension PKCS7Container.SignedData
{
//	var digestAlgorithm: DigestAlgorithmIdentifiers
//	{
//		return alg.items.first?
//	}
}
extension PKCS7Container
{
	struct SignedData: ASN1Decodable
	{
		static var template: ASN1Template
		{
			return ASN1Template.contextSpecific(0).constructed().explicit(tag: 16).constructed()
		}
		
		var version: Int
		var alg: DigestAlgorithmIdentifiersContainer
		var contentInfo: ContentInfo
		var certificates: CetrificatesContaner
		var signerInfos: SignerInfos
		
		enum CodingKeys: ASN1CodingKey
		{
			case version
			case alg
			case contentInfo
			case certificates
			case signerInfos
			
			var template: ASN1Template
			{
				switch self
				{
				case .version:
					return .universal(ASN1Identifier.Tag.integer)
				case .alg:
					return DigestAlgorithmIdentifiersContainer.template
				case .contentInfo:
					return ContentInfo.template
				case .certificates:
					return CetrificatesContaner.template
				case .signerInfos:
					return SignerInfos.template
				}
			}
		}
	}
	
	struct DigestAlgorithmIdentifiersContainer: ASN1Decodable
	{
		var items: [Item]
		
		init(from decoder: Decoder) throws
		{
			var container: UnkeyedDecodingContainer = try decoder.unkeyedContainer()
			
			var items: [Item] = []
			
			while !container.isAtEnd
			{
				items.append(try container.decode(Item.self))
			}
			
			self.items = items
		}
		
		static var template: ASN1Template { ASN1Template.universal(ASN1Identifier.Tag.set).constructed() }
		
		struct Item: ASN1Decodable
		{
			var algorithm: String
			var parameters: ASN1Null
			
			enum CodingKeys: ASN1CodingKey
			{
				case algorithm
				case parameters
				
				var template: ASN1Template
				{
					switch self
					{
					case .algorithm:
						return .universal(ASN1Identifier.Tag.objectIdentifier)
					case .parameters:
						return .universal(ASN1Identifier.Tag.null)
					}
				}
			}
			
			static var template: ASN1Template
			{
				return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
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
		var payload: InAppReceiptPayload
		
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
		
		enum LegacyCodingKeys: ASN1CodingKey
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
					return _PayloadContainer.template
				}
			}
		}
		
		init(from decoder: Decoder) throws
		{
			do
			{
				let container = try decoder.container(keyedBy: CodingKeys.self)
				oid = try container.decode(ASN1SkippedField.self, forKey: .oid)
				let payloadContainer = try container.decode(PayloadContainer.self, forKey: .payload)
				payload = payloadContainer.payload
			}catch{
				let container = try decoder.container(keyedBy: LegacyCodingKeys.self)
				oid = try container.decode(ASN1SkippedField.self, forKey: .oid)
				let payloadContainer = try container.decode(_PayloadContainer.self, forKey: .payload)
				payload = payloadContainer.payload
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
	
	struct Certificate: ASN1Decodable
	{
		var cert: TPSCertificate
		var signatureAlgorithm: ASN1SkippedField
		var signatureValue: Data
		
		var rawData: Data
		
		enum CodingKeys: ASN1CodingKey
		{
			case cert
			case signatureAlgorithm
			case signatureValue
			
			var template: ASN1Template
			{
				switch self
				{
				case .cert:
					return TPSCertificate.template
				case .signatureAlgorithm:
					return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
				case .signatureValue:
					return ASN1Template.universal(ASN1Identifier.Tag.bitString)
				}
			}
		}
		
		init(from decoder: Decoder) throws
		{
			let dec = decoder as! ASN1DecoderProtocol
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			self.rawData = dec.dataToDecode
			self.cert = try container.decode(TPSCertificate.self, forKey: .cert)
			self.signatureAlgorithm = try container.decode(ASN1SkippedField.self, forKey: .signatureAlgorithm)
			self.signatureValue = try container.decode(Data.self, forKey: .signatureValue)
		}
		
		static var template: ASN1Template
		{
			return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
		}
	}
	
	struct TPSCertificate: ASN1Decodable
	{
		var version: Int
		var serialNumber: Int
		var signature: ASN1SkippedField
		var issuer: ASN1SkippedField
		var validity: ASN1SkippedField
		var subject: ASN1SkippedField
		var subjectPublicKeyInfo: Data // We will need only this field
		var extensions: ASN1SkippedField
		
		enum CodingKeys: ASN1CodingKey
		{
			case version
			case serialNumber
			case signature
			case issuer
			case validity
			case subject
			case subjectPublicKeyInfo
			case extensions
			
			var template: ASN1Template
			{
				switch self
				{
				case .version:
					return ASN1Template.contextSpecific(0).constructed().explicit(tag: ASN1Identifier.Tag.integer)
				case .serialNumber:
					return ASN1Template.universal(ASN1Identifier.Tag.integer)
				case .signature:
					return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
				case .issuer:
					return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
				case .validity:
					return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
				case .subject:
					return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
				case .subjectPublicKeyInfo:
					return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
				case .extensions:
					return ASN1Template.contextSpecific(3).constructed().explicit(tag: ASN1Identifier.Tag.sequence).constructed()
				}
			}
		}
		
		init(from decoder: Decoder) throws
		{
			let container = try decoder.container(keyedBy: CodingKeys.self)

			self.version = try container.decode(Int.self, forKey: .version)
			self.serialNumber = try container.decode(Int.self, forKey: .serialNumber)
			self.signature = try container.decode(ASN1SkippedField.self, forKey: .signature)
			self.issuer = try container.decode(ASN1SkippedField.self, forKey: .issuer)
			self.validity = try container.decode(ASN1SkippedField.self, forKey: .validity)
			self.subject = try container.decode(ASN1SkippedField.self, forKey: .subject)
			
			let subDec = try container.superDecoder(forKey: .subjectPublicKeyInfo) as! ASN1DecoderProtocol
			self.subjectPublicKeyInfo = subDec.dataToDecode
			
			self.extensions = try container.decode(ASN1SkippedField.self, forKey: .extensions)
		}
		
		static var template: ASN1Template
		{
			return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
		}
	}
	
	struct CetrificatesContaner: ASN1Decodable
	{
		let certificates: [Certificate]
		
		init(from decoder: Decoder) throws
		{
			var container: UnkeyedDecodingContainer = try decoder.unkeyedContainer()
			
			var certificates: [Certificate] = []
			
			while !container.isAtEnd {
				certificates.append(try container.decode(Certificate.self))
			}
			
			self.certificates = certificates
		}
		
		static var template: ASN1Template
		{
			return ASN1Template.contextSpecific(0).constructed().implicit(tag: ASN1Identifier.Tag.sequence)
		}
	}
	
	struct SignerInfos: ASN1Decodable
	{
		static var template: ASN1Template
		{
			return ASN1Template.universal(ASN1Identifier.Tag.set).constructed().explicit(tag: ASN1Identifier.Tag.sequence).constructed()
		}
		
		var version: Int
		var signerIdentifier: ASN1SkippedField
		var digestAlgorithm: ASN1SkippedField
		var digestEncryptionAlgorithm: ASN1SkippedField
		var encryptedDigest: Data
		
		enum CodingKeys: ASN1CodingKey
		{
			case version
			case signerIdentifier
			case digestAlgorithm
			case digestEncryptionAlgorithm
			case encryptedDigest
			
			var template: ASN1Template
			{
				switch self
				{
				case .version:
					return .universal(ASN1Identifier.Tag.integer)
				case .signerIdentifier:
					return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
				case .digestAlgorithm:
					return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
				case .digestEncryptionAlgorithm:
					return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
				case .encryptedDigest:
					return .universal(ASN1Identifier.Tag.octetString)
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
}
