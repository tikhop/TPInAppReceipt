//
//  File.swift
//  
//
//  Created by PT on 6/22/23.
//

import Foundation
import SwiftASN1

/// The receipt is a Cryptographic Message Syntax (CMS) (PKCS #7) container, as defined by RFC 5652.
/// The App Store encodes the payload of the container using Abstract Syntax Notation One (ASN.1), as defined by ITU-T X.690.
typealias AppStoreReceipt = PKCS7ContentInfo<SignedData<ASN1OctetString>>
