//
//  PCKS7.swift
//  TPInAppReceipt iOS
//
//  Created by Pavel Tikhonenko on 22/06/2019.
//  Copyright © 2019 Pavel Tikhonenko. All rights reserved.
//

import Foundation

struct PCKS7
{
    enum OID: String
    {
        case data = "1.2.840.113549.1.7.1"
        case signedData = "1.2.840.113549.1.7.2"
        case envelopedData = "1.2.840.113549.1.7.3"
        case signedAndEnvelopedData = "1.2.840.113549.1.7.4"
        case digestedData = "1.2.840.113549.1.7.5"
        case encryptedData = "1.2.840.113549.1.7.6"
    }
}
