//
//  InAppReceiptValidator.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 19/01/17.
//  Copyright © 2017 Pavel Tikhonenko. All rights reserved.
//

import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import IOKit
#endif

import CommonCrypto

/// A InAppReceipt extension helps to validate the receipt
public extension InAppReceipt
{
    /// Verify In App Receipt
    /// Should be equal to `receiptHash` value
    ///
    /// - throws: An error in the InAppReceipt domain, if verification fails
    func verify() throws
    {
        try verifyHash()
        try verifyBundleIdentifierAndVersion()
        try verifySignature()
    }
    
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
        #if targetEnvironment(simulator)
        #else
        guard let bid = Bundle.main.bundleIdentifier, bid == bundleIdentifier else
        {
            throw IARError.validationFailed(reason: .bundleIdentifierVefirication)
        }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        guard let v = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
            v == appVersion else
        {
            throw IARError.validationFailed(reason: .bundleVersionVefirication)
        }
        #elseif os(macOS)
        guard let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            v == appVersion else
        {
            throw IARError.validationFailed(reason: .bundleVersionVefirication)
        }
        #endif
        #endif
    }
    
    /// Verify signature inside pkcs7 container
    ///
    /// - throws: An error in the InAppReceipt domain, if verification can't be completed
    func verifySignature() throws
    {
        try checkSignatureExistance()
        try checkAppleRootCertExistence()
        try checkSignatureValidity()
    }
    
    /// Verifies existance of the signature inside pkcs7 container
    ///
    /// - throws: An error in the InAppReceipt domain, if verification can't be completed
    fileprivate func checkSignatureExistance() throws
    {
        guard pkcs7Container.checkContentExistance(by: PKC7.OID.signedData) else
        {
            throw IARError.validationFailed(reason: .signatureValidation(.receiptSignedDataNotFound))
        }
        
        guard pkcs7Container.checkContentExistance(by: PKC7.OID.data) else
        {
            throw IARError.validationFailed(reason: .signatureValidation(.receiptDataNotFound))
        }
    }
    
    /// Verifies existence of Apple Root Certificate in bundle
    ///
    /// - throws: An error in the InAppReceipt domain, if Apple Root Certificate does not exist
    fileprivate func checkAppleRootCertExistence() throws
    {
        guard let certPath = rootCertificatePath,
            FileManager.default.fileExists(atPath: certPath) else {
                throw IARError.validationFailed(reason: .signatureValidation(.appleIncRootCertificateNotFound))
        }
        
    }
    
    func checkSignatureValidity() throws {
        guard let path = rootCertificatePath,
            let certData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                throw IARError.validationFailed(reason: .signatureValidation(.unableToLoadAppleIncRootCertificate))
        }
        
        guard let wrappedCertData = try? X509Wrapper(cert: certData),
            let publicKeyData =  wrappedCertData.extractPublicKeyContainer() else {
            throw IARError.validationFailed(reason: .signatureValidation(.unableToLoadAppleIncPublicKey))
        }
        
        guard let signedData = signedData else {
            throw IARError.validationFailed(reason: .signatureValidation(.receiptSignedDataNotFound))
        }
        
        guard let originalData = originalData else {
            throw IARError.validationFailed(reason: .signatureValidation(.receiptDataNotFound))
        }
        
        guard let signature = signature else {
            throw IARError.validationFailed(reason: .signatureValidation(.signatureNotFound))
        }
        
        guard let iTunesPublicKeyContainer = pkcs7Container.extractiTunesPublicKeyContrainer() else {
            throw IARError.validationFailed(reason: .signatureValidation(.unableToLoadiTunesPublicKey))
        }
        
        let keyDict: [String:Any] =
        [
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
        ]

        guard let iTunesPublicKeySec = SecKeyCreateWithData(iTunesPublicKeyContainer as CFData, keyDict as CFDictionary, nil) else {
            throw IARError.validationFailed(reason: .signatureValidation(.unableToLoadAppleIncPublicSecKey))
        }
        
        var umErrorCF: Unmanaged<CFError>? = nil
        if SecKeyVerifySignature(iTunesPublicKeySec, .rsaSignatureMessagePKCS1v15SHA1, originalData as CFData, signature as CFData, &umErrorCF) {
            
        } else {
            let error = umErrorCF?.takeRetainedValue() as Error? as NSError?
            print("error is \(error)")
            throw IARError.validationFailed(reason: .signatureValidation(.invalidSignature))
        }
        
    }
    
    /// Computed SHA-1 hash, used to validate the receipt.
    internal var computedHashData: Data
    {
        var uuidData = guid()
        var opaqueData = opaqueValue
        var bundleIdData = bundleIdentifierData
        
        var hash = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        var ctx = CC_SHA1_CTX()
        CC_SHA1_Init(&ctx)
        CC_SHA1_Update(&ctx, uuidData.bytes, CC_LONG(uuidData.count))
        CC_SHA1_Update(&ctx, opaqueData.bytes, CC_LONG(opaqueData.count))
        CC_SHA1_Update(&ctx, bundleIdData.bytes, CC_LONG(bundleIdData.count))
        CC_SHA1_Final(&hash, &ctx)
        
        return Data(hash)
    }
}

fileprivate func guid() -> Data
{
    
#if targetEnvironment(simulator) // Debug purpose only
    var uuidBytes = UUID(uuidString: "A2BDE35A-B11A-44B0-95AB-7BBA7A2890C8")!.uuid
    return Data(bytes: &uuidBytes, count: MemoryLayout.size(ofValue: uuidBytes))
#elseif os(iOS) || os(watchOS) || os(tvOS)
    var uuidBytes = UIDevice.current.identifierForVendor!.uuid
    return Data(bytes: &uuidBytes, count: MemoryLayout.size(ofValue: uuidBytes))
#elseif os(macOS)
    var masterPort = mach_port_t()
    var kernResult: kern_return_t = IOMasterPort(mach_port_t(MACH_PORT_NULL), &masterPort)
    if (kernResult != KERN_SUCCESS)
    {
        assertionFailure("Failed to initialize master port")
    }
    
    var matchingDict = IOBSDNameMatching(masterPort, 0, "en0")
    if (matchingDict == nil)
    {
        assertionFailure("Failed to retrieve guid")
    }
    
    var iterator = io_iterator_t()
    kernResult = IOServiceGetMatchingServices(masterPort, matchingDict, &iterator)
    if (kernResult != KERN_SUCCESS)
    {
        assertionFailure("Failed to retrieve guid")
    }
    
    var guidData: Data?
    var service = IOIteratorNext(iterator)
    var parentService = io_object_t()
    
    defer
    {
        IOObjectRelease(iterator)
    }
    
    while(service != 0)
    {
        kernResult = IORegistryEntryGetParentEntry(service, kIOServicePlane, &parentService)
        
        if (kernResult == KERN_SUCCESS)
        {
            guidData = IORegistryEntryCreateCFProperty(parentService, "IOMACAddress" as CFString, nil, 0).takeRetainedValue() as? Data
            
            IOObjectRelease(parentService)
        }
        IOObjectRelease(service)
        
        if  guidData != nil {
            break
        }else{
            service = IOIteratorNext(iterator)
        }
    }
    
    if guidData == nil
    {
        assertionFailure("Failed to retrieve guid")
    }
    
    return guidData!    
#endif
}
