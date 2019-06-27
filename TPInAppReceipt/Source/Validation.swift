//
//  InAppReceiptValidator.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 19/01/17.
//  Copyright © 2017 Pavel Tikhonenko. All rights reserved.
//

import Foundation

/// A InAppReceipt extension helps to validate the receipt
public extension InAppReceipt
{
    /// Verify only hash
    /// Should be equal to `receiptHash` value
    ///
    /// - throws: An error in the InAppReceipt domain, if verification fails
    func verifyHash() throws
    {
        if (computedHashData != receiptHash)
        {
            throw IARError.validationFailed(reason: .hashValidation)
        }
    }
    
    func verifyBundleIdentifier() throws
    {
        guard let bid = Bundle.main.bundleIdentifier, bid == bundleIdentifier else
        {
            throw IARError.validationFailed(reason: .bundleIdentifierVefirication)
        }
    }
    
    /// Computed SHA-1 hash, used to validate the receipt.
    internal var computedHashData: Data
    {
        let uuidData = DeviceGUIDRetriever.guid()
        let opaqueData = opaqueValue
        let bundleIdData = bundleIdentifierData
        
        var hash: Array<UInt8>!
        var sha1 = SHA1()
        hash = try! sha1.update(withBytes: uuidData.bytes)
        hash = try! sha1.update(withBytes: opaqueData.bytes)
        hash = sha1.calculate(for: bundleIdData.bytes)
        
        return Data(bytes: &hash, count: hash.count)
    }
}
