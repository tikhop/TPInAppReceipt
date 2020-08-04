//
//  File.swift
//  
//
//  Created by Pavel Tikhonenko on 04.08.2020.
//

import Foundation

extension InAppReceiptPayload
{
	/// Initialize a `InAppReceipt` with asn1 payload
	///
	/// - parameter asn1Data: `Data` object that represents receipt's payload
	init(pkcs7payload: PKCS7Payload)
	{
		var bundleIdentifier = ""
		var appVersion = ""
		var originalAppVersion = ""
		var purchases = [InAppPurchase]()
		var bundleIdentifierData = Data()
		var opaqueValue = Data()
		var receiptHash = Data()
		var expirationDate: String? = ""
		var receiptCreationDate: String = ""
		var environment: String = ""
		
		pkcs7payload.attributes.forEach { (attribute) in
			if let field = InAppReceiptField(rawValue: attribute.type)
			{
				var value = attribute.value
				
				switch (field)
				{
				case .bundleIdentifier:
					let obj = ASN1Object(data: value)
					bundleIdentifier = obj.extractValue() as! String
					bundleIdentifierData = value
				case .appVersion:
					appVersion = ASN1.readString(from: &value, encoding: .utf8)
				case .opaqueValue:
					opaqueValue = value
				case .receiptHash:
					receiptHash = value
				case .inAppPurchaseReceipt:
					purchases.append(InAppPurchase(asn1Data: value))
					break
				case .originalAppVersion:
					originalAppVersion = ASN1.readString(from: &value, encoding: .utf8)
				case .expirationDate:
					expirationDate = ASN1.readString(from: &value, encoding: .ascii)
				case .receiptCreationDate:
					receiptCreationDate = ASN1.readString(from: &value, encoding: .ascii)
				case .environment:
					environment = ASN1.readString(from: &value, encoding: .utf8)
				default:
					print("attribute.type = \(String(describing: attribute.type)))")
				}
			}

		}
		
		self.bundleIdentifier = bundleIdentifier
		self.appVersion = appVersion
		self.originalAppVersion = originalAppVersion
		self.purchases = purchases
		self.expirationDate = expirationDate
		self.bundleIdentifierData = bundleIdentifierData
		self.opaqueValue = opaqueValue
		self.receiptHash = receiptHash
		self.creationDate = receiptCreationDate
		self.environment = environment
	}
}
