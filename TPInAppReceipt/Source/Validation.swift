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
    
    /// Verify that the bundle identifier in the receipt matches a hard-coded constant containing the CFBundleIdentifier value you expect in the Info.plist file. If they do not match, validation fails.
    /// Verify that the version identifier string in the receipt matches a hard-coded constant containing the CFBundleShortVersionString value (for macOS) or the CFBundleVersion value (for iOS) that you expect in the Info.plist file.
    ///
    ///
    /// - throws: An error in the InAppReceipt domain, if verification fails
    func verifyBundleIdentifierAndVersion() throws
    {
        guard let bid = Bundle.main.bundleIdentifier, bid == bundleIdentifier else
        {
            throw IARError.validationFailed(reason: .bundleIdentifierVefirication)
        }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        guard let v = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
            v == originalAppVersion else
        {
            throw IARError.validationFailed(reason: .bundleVersionVefirication)
        }
        #elseif os(macOS)
        guard let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            v == originalAppVersion else
        {
            throw IARError.validationFailed(reason: .bundleVersionVefirication)
        }
        #endif
    }
    
    /// Verify signature inside pkcs7 container
    ///
    /// - throws: An error in the InAppReceipt domain, if verification can't be completed
    func verifySignature() throws
    {
        try checkSignatureExistance()
    }
    
    /// Verifies existance of the signature inside pkcs7 container
    ///
    /// - throws: An error in the InAppReceipt domain, if verification can't be completed
    fileprivate func checkSignatureExistance() throws
    {
        var r = pkcs7Container.checkContentExistance(by: PKC7.OID.signedData)
        
        if !r
        {
            throw IARError.validationFailed(reason: .signatureValidation(.receiptSignedDataNotFound))
        }
        
        r = pkcs7Container.checkContentExistance(by: PKC7.OID.data)
        
        if !r
        {
            throw IARError.validationFailed(reason: .signatureValidation(.receiptDataNotFound))
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
