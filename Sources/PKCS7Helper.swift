//
//  PKCS7Wrapper.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 19/01/17.
//  Copyright © 2017-2020 Pavel Tikhonenko. All rights reserved.
//

import Foundation

extension PKCS7
{
    func extractInAppPayload() -> Data?
    {
        return nil
    }
    
    func extractiTunesCertContainer() -> Data?
    {
//        guard let signedData = extractContent(by: PKC7.OID.signedData) else
//        {
//            return nil
//        }
//
//        let asn1signedData = ASN1Object(data: signedData)
//
//        let firstBlock = asn1signedData.enumerated().map({ $0 })[0].element
//        let secondBlock = firstBlock.enumerated().map({ $0 })[3].element
//        let iTunesCertContainer = secondBlock.enumerated().map({ $0 })[0].element
        
		return nil
    }
    
    func extractiTunesPublicKeyContrainer() -> Data?
    {
//        guard let iTunesCertContainer = extractiTunesCertContainer() else
//        {
//            return nil
//        }
//
//        let asn1iTunesCertData = ASN1Object(data: iTunesCertContainer)
//        let firstBlock = asn1iTunesCertData.enumerated().map({ $0 })[0].element
//        let iTunesPublicKeyContainer = firstBlock.enumerated().map({ $0 })[6].element
        
		return nil
    }
    
    func extractWorldwideDeveloperCertContainer() -> Data?
    {
//        guard let signedData = extractContent(by: PKC7.OID.signedData) else
//        {
//            return nil
//        }
//        
//        let asn1signedData = ASN1Object(data: signedData)
//        
//        let firstBlock = asn1signedData.enumerated().map({ $0 })[0].element
//        let secondBlock = firstBlock.enumerated().map({ $0 })[3].element
//        let worldwideDeveloperCertContainer = secondBlock.enumerated().map({ $0 })[1].element
        
		return nil
    }
}
