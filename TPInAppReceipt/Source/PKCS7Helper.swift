//
//  PKCS7Wrapper.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 19/01/17.
//  Copyright © 2017 Pavel Tikhonenko. All rights reserved.
//

import Foundation

extension PKCS7Wrapper
{
    func extractInAppPayload() -> Data?
    {
        guard var contentData = extractContent(by: PKC7.OID.data) else
        {
            return nil
        }
        
        do
        {
            let id = try ASN1Object.extractIdentifier(from: &contentData)
            let l = try ASN1Object.extractLenght(from: &contentData)
            
            var cStart = contentData.startIndex + ASN1Object.identifierLenght + l.offset
            let cEnd = contentData.endIndex
            
            if id.encodingType == .constructed, id.type.rawValue == 0
            {
                // Octet string
                var cD = contentData[cStart..<cEnd]
                let l = try ASN1Object.extractLenght(from: &cD)
                
                cStart += ASN1Object.identifierLenght + l.offset
                return Data(contentData[cStart..<cEnd])
            }else{
                return nil
            }
        }catch{
            return nil
        }
    }
}
