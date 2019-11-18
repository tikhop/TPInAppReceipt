//
//  X509Helper.swift
//  TPInAppReceipt iOS
//
//  Created by Soulchild on 18/11/2019.
//  Copyright © 2019 Pavel Tikhonenko. All rights reserved.
//

import Foundation

extension X509Wrapper
{
    func extractPublicKey() -> Data?
    {
        // verify if RSA encryption field exist and is equal to null
        guard var contentData = extractContent(by: X509.OID.rsaEncryption) else
        {
            return nil
        }
        
        do
        {
            let id = try ASN1Object.extractIdentifier(from: &contentData)
            
            // rsaEncryption field must be primitive and has null value
            guard id.encodingType == .primitive, id.type.rawValue == 5 else {
                return nil
            }
        } catch {
            return nil
        }
        
        let raw = Data(bytesNoCopy: rawBuffer.baseAddress!, count: rawBuffer.count, deallocator: .none)
        let asn1certData = ASN1Object(data: raw)
        
        let firstBlock = asn1certData.enumerated().map({ $0 })[0].element
        let secondBlock = firstBlock.enumerated().map({ $0 })[6].element
        let thirdBlock  = secondBlock.enumerated().map({ $0 })[1].element
        
        // the public key is the second element inside a bitString tuple
        guard let bitStringSequenceData = thirdBlock.extractValue() as? Data,
            thirdBlock.type.rawValue == 3 else {
            return nil
        }
        
        let keySequenceData = ASN1Object(data: bitStringSequenceData)
        
        if let publicKeyData = keySequenceData.enumerated().map({ $0 })[0].element.valueData {
            return publicKeyData
        }
        
        return nil
    }
}
