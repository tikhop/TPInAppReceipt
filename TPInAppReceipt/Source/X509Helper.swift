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
    func extractPublicKeyPayload() -> Data?
    {
        guard var contentData = extractContent(by: X509.OID.rsaEncryption) else
        {
            print("content data not found")
            return nil
        }
        
        do
        {
            let id = try ASN1Object.extractIdentifier(from: &contentData)
            let l = try ASN1Object.extractLenght(from: &contentData)
            
            var cStart = contentData.startIndex + ASN1Object.identifierLenght + l.offset + 9
            
//            let cEnd = contentData.endIndex
            let cEnd = 291 + 4 + 257
            
            if id.encodingType == .primitive, id.type.rawValue == 5
            {
                print("yes")
                // Octet string
                var cD = contentData[cStart..<cEnd]
                print("cD")
                let l = try ASN1Object.extractLenght(from: &cD)
                print("l is \(l)")
                cStart += ASN1Object.identifierLenght + l.offset
                let d = Data(contentData[cStart..<cEnd])
                
                return d
            }else{
                return nil
            }
        }catch{
            print("error thrown \(error.localizedDescription)")
            return nil
        }
    }
}
