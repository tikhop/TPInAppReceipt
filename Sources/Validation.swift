//
//  Validation.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 19/01/17.
//  Copyright © 2017-2021 Pavel Tikhonenko. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

#if os(watchOS)
import WatchKit
#endif

#if canImport(Cocoa)
import Cocoa
import IOKit
#endif

import CommonCrypto

/// A InAppReceipt extension helps to validate the receipt
public extension InAppReceipt
{
	/// Determine whether receipt is valid or not
	///
	/// - Returns:`true` if the receipt is valid, otherwise `false`
	var isValid: Bool
	{
		do {
			try validate()
			return true
		} catch {
			return false
		}
	}
	
	/// Validate In App Receipt
	///
	/// - throws: An error in the InAppReceipt domain, if verification fails
	func validate() throws
	{
		try verifyHash()
		try verifyBundleIdentifierAndVersion()
		try verifySignature()
	}
	
    /// Verify In App Receipt
    ///
    /// - throws: An error in the InAppReceipt domain, if verification fails
	@available(*, deprecated, renamed: "validate")
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
        if (computedHash != receiptHash)
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
        try verifyBundleIdentifier()
		try verifyBundleVersion()
    }
    
	/// Verify that the bundle identifier in the receipt matches a hard-coded constant containing the CFBundleIdentifier value you expect in the Info.plist file. If they do not match, validation fails.
	///
	///
	/// - throws: An error in the InAppReceipt domain, if verification fails
	func verifyBundleIdentifier() throws
	{
		guard let bid = Bundle.main.bundleIdentifier,
			  bid == bundleIdentifier else
		{
			throw IARError.validationFailed(reason: .bundleIdentifierVerification)
		}
	}
	
	/// Verify that the version identifier string in the receipt matches a hard-coded constant containing the CFBundleShortVersionString value (for macOS) or the CFBundleVersion value (for iOS) that you expect in the Info.plist file.
	///
	///
	/// - throws: An error in the InAppReceipt domain, if verification fails
	func verifyBundleVersion() throws
	{
		guard let v = Bundle.main.appVersion,
			  v == appVersion else
		{
			throw IARError.validationFailed(reason: .bundleVersionVerification)
		}
	}
	
    /// Verify signature inside pkcs7 container
    ///
    /// - throws: An error in the InAppReceipt domain, if verification can't be completed
    func verifySignature() throws
    {
        try checkAppleRootCertExistence()
        
        // only check certificate chain of trust and signature validity after these version
        if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 5.0, *)
		{
			#if DEBUG
			try checkSignatureValidity()
			#else
			try checkChainOfTrust()
			try checkSignatureValidity()
			#endif
        }
    }
    
    /// Verifies existence of Apple Root Certificate in bundle
    ///
    /// - throws: An error in the InAppReceipt domain, if Apple Root Certificate does not exist
    fileprivate func checkAppleRootCertExistence() throws
    {
        guard let certPath = rootCertificatePath,
			  FileManager.default.fileExists(atPath: certPath) else
        {
            throw IARError.validationFailed(reason: .signatureValidation(.appleIncRootCertificateNotFound))
        }
    }
    
    @available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 5.0, *)
    func checkChainOfTrust() throws
    {
        // Validate chain of trust of certificate
        // Ensure the iTunes certificate included in the receipt is indeed signed by Apple root cert
        // https://developer.apple.com/documentation/security/certificate_key_and_trust_services/trust/creating_a_trust_object
        
        // root cert data is loaded from the bundled Apple Root Certificate
        guard let path = rootCertificatePath,
			  let rootCertData = try? Data(contentsOf: URL(fileURLWithPath: path)) else
        {
            throw IARError.validationFailed(reason: .signatureValidation(.unableToLoadAppleIncRootCertificate))
        }
        
        guard let iTunesCertData = iTunesCertificateData else
        {
           throw IARError.validationFailed(reason: .signatureValidation(.unableToLoadiTunesCertificate))
        }
        
        guard let worldwideDeveloperCertData = worldwideDeveloperCertificateData else
		{
            throw IARError.validationFailed(reason: .signatureValidation(.unableToLoadWorldwideDeveloperCertificate))
        }
        
        guard let rootCertSec = SecCertificateCreateWithData(nil, rootCertData as CFData) else {
            throw IARError.validationFailed(reason: .signatureValidation(.unableToLoadAppleIncRootCertificate))
        }
        
        guard let iTunesCertSec =  SecCertificateCreateWithData(nil, iTunesCertData as CFData) else {
           throw IARError.validationFailed(reason: .signatureValidation(.unableToLoadiTunesCertificate))
        }
        
        guard let worldwideDevCertSec = SecCertificateCreateWithData(nil, worldwideDeveloperCertData as CFData) else {
           throw IARError.validationFailed(reason: .signatureValidation(.unableToLoadWorldwideDeveloperCertificate))
        }
        
        let policy = SecPolicyCreateBasicX509()
        
        var wwdcTrust: SecTrust?
        var iTunesTrust: SecTrust?
        
        // verify worldwide developer cert in the receipt is signed by Apple Root Cert
        let worldwideDevCertVerifyStatus = SecTrustCreateWithCertificates([worldwideDevCertSec, rootCertSec] as AnyObject,
                                                                            policy,
                                                                            &wwdcTrust)
        
        guard worldwideDevCertVerifyStatus == errSecSuccess && wwdcTrust != nil else
		{
            throw IARError.validationFailed(reason: .signatureValidation(.invalidCertificateChainOfTrust))
        }
        
        // verify iTunes cert in the receipt is signed by worldwide developer cert, which is signed by Apple Root Cert
        let iTunesCertVerifystatus = SecTrustCreateWithCertificates([iTunesCertSec, worldwideDevCertSec, rootCertSec] as AnyObject,
                                                                    policy,
                                                                    &iTunesTrust)
        
        guard iTunesCertVerifystatus == errSecSuccess && iTunesTrust != nil else
		{
            throw IARError.validationFailed(reason: .signatureValidation(.invalidCertificateChainOfTrust))
        }
        
        var secTrustResult: SecTrustResultType = SecTrustResultType.unspecified
        
        if #available(OSX 10.14, iOS 12.0, tvOS 12.0, *)
        {
            var error: CFError?
            guard SecTrustEvaluateWithError(wwdcTrust!, &error) else
			{
                throw IARError.validationFailed(reason: .signatureValidation(.invalidCertificateChainOfTrust))
            }
        } else {
            guard SecTrustEvaluate(wwdcTrust!, &secTrustResult) == errSecSuccess else
			{
                throw IARError.validationFailed(reason: .signatureValidation(.invalidCertificateChainOfTrust))
            }
        }
        
        if #available(OSX 10.14, iOS 12.0, tvOS 12.0, *)
        {
            var error: CFError?
            guard SecTrustEvaluateWithError(iTunesTrust!, &error) else
			{
                throw IARError.validationFailed(reason: .signatureValidation(.invalidCertificateChainOfTrust))
            }
        } else {
            guard SecTrustEvaluate(iTunesTrust!, &secTrustResult) == errSecSuccess else
			{
                throw IARError.validationFailed(reason: .signatureValidation(.invalidCertificateChainOfTrust))
            }
        }
    }
    
    @available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
    func checkSignatureValidity() throws
    {
        guard let signature = signature else
        {
            throw IARError.validationFailed(reason: .signatureValidation(.signatureNotFound))
        }
        
        guard let iTunesPublicKeyContainer = receipt.iTunesPublicKeyData else
		{
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
		guard let alg = receipt.digestAlgorithm,
			  SecKeyVerifySignature(iTunesPublicKeySec, alg, payloadRawData as CFData, signature as CFData, &umErrorCF) else {
            
            let error = umErrorCF?.takeRetainedValue() as Error? as NSError?
			print("error is \(String(describing: error))")
             
            throw IARError.validationFailed(reason: .signatureValidation(.invalidSignature))
        }
        
    }
    
    /// Computed SHA-1 hash, used to validate the receipt.
    internal var computedHash: Data
    {
        let uuidData = guid()
        let opaqueData = opaqueValue
        let bundleIdData = bundleIdentifierData
        
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
#if os(watchOS)
    var uuidBytes = WKInterfaceDevice.current().identifierForVendor!.uuid
    return Data(bytes: &uuidBytes, count: MemoryLayout.size(ofValue: uuidBytes))
#elseif targetEnvironment(macCatalyst) || os(macOS)
    
	if let guid = getMacAddress()
	{
		return guid
	}else{
		assertionFailure("Failed to retrieve guid")
	}
	
	return Data() // Never get called
#elseif canImport(UIKit)
    var uuidBytes = UIDevice.current.identifierForVendor!.uuid
    return Data(bytes: &uuidBytes, count: MemoryLayout.size(ofValue: uuidBytes))
#endif
}

#if targetEnvironment(macCatalyst) || os(macOS)
func getMacAddress() -> Data?
{
	guard let service = ioService(named: "en0", wantBuiltIn: true)
			?? ioService(named: "en1", wantBuiltIn: true)
			?? ioService(named: "en0", wantBuiltIn: false)
	else { return nil }
	
	defer { IOObjectRelease(service) }
	
	if let cftype = IORegistryEntrySearchCFProperty(service, kIOServicePlane, "IOMACAddress" as CFString, kCFAllocatorDefault, IOOptionBits(kIORegistryIterateRecursively | kIORegistryIterateParents))
	{
		return (cftype as? Data)
	}
	
	return nil
}

func ioService(named name: String, wantBuiltIn: Bool) -> io_service_t?
{
	let main_port: mach_port_t
	if #available(macOS 12.0, macCatalyst 15.0, *) {
		main_port = kIOMainPortDefault
	} else {
		main_port = 0 // the kIOMasterPortDefault symbol is unavailable on xcode 14 and later.
	}
	var iterator = io_iterator_t()
	
	defer
	{
		if iterator != IO_OBJECT_NULL
		{
			IOObjectRelease(iterator)
		}
	}
	
	guard let matchingDict = IOBSDNameMatching(main_port, 0, name),
		  IOServiceGetMatchingServices(main_port, matchingDict as CFDictionary, &iterator) == KERN_SUCCESS,
		  iterator != IO_OBJECT_NULL
	else
	{
		return nil
	}
	
	var candidate = IOIteratorNext(iterator)
	while candidate != IO_OBJECT_NULL
	{
		if let cftype = IORegistryEntryCreateCFProperty(candidate, "IOBuiltin" as CFString, kCFAllocatorDefault, 0)
		{
			let isBuiltIn = cftype.takeRetainedValue() as! CFBoolean
			if wantBuiltIn == CFBooleanGetValue(isBuiltIn)
			{
				return candidate
			}
		}
		
		IOObjectRelease(candidate)
		candidate = IOIteratorNext(iterator)
	}
	
	return nil
}
#endif
