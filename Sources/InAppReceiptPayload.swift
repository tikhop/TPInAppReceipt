//
//  InAppReceiptPayload.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 20/01/17.
//  Copyright © 2017-2020 Pavel Tikhonenko. All rights reserved.
//

import Foundation
import ASN1Swift

struct InAppReceiptPayload
{
    /// In-app purchase's receipts
	let purchases: [InAppPurchase]
    
    /// The app’s bundle identifier
	let bundleIdentifier: String
    
    /// The app’s version number
	let appVersion: String
    
    /// The version of the app that was originally purchased.
	let originalAppVersion: String
    
    /// The date that the app receipt expires
	let expirationDate: String?
    
    /// Used to validate the receipt
	let bundleIdentifierData: Data
    
    /// An opaque value used, with other data, to compute the SHA-1 hash during validation.
	let opaqueValue: Data
    
    /// A SHA-1 hash, used to validate the receipt.
	let receiptHash: Data
    
    /// The date when the app receipt was created.
	let creationDate: String
    
	/// Receipt's environment
	let environment: String
	
    /// Initialize a `InAppReceipt` passing all values
    ///
	init(bundleIdentifier: String, appVersion: String, originalAppVersion: String, purchases: [InAppPurchase], expirationDate: String?, bundleIdentifierData: Data, opaqueValue: Data, receiptHash: Data, creationDate: String, environment: String)
    {
        self.bundleIdentifier = bundleIdentifier
        self.appVersion = appVersion
        self.originalAppVersion = originalAppVersion
        self.purchases = purchases
        self.expirationDate = expirationDate
        self.bundleIdentifierData = bundleIdentifierData
        self.opaqueValue = opaqueValue
        self.receiptHash = receiptHash
        self.creationDate = creationDate
		self.environment = environment
    }
}
