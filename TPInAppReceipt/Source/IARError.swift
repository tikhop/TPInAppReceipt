//
//  Constants.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 20/01/17.
//  Copyright © 2017 Pavel Tikhonenko. All rights reserved.
//

import Foundation

/// `IARError` is the error type returned by InAppReceipt.
/// It encompasses a few different types of errors, each with their own associated reasons.
public enum IARError: Error
{
    case initializationFailed(reason: ReceiptInitializationFailureReason)
    case validationFailed(reason: ValidationFailureReason)
    
    public enum ReceiptInitializationFailureReason
    {
        case appStoreReceiptNotFound
        case pkcs7ParsingError
    }
    
    public enum ValidationFailureReason
    {
        case hashValidationFailed
        case signatureValidationFailed(SignatureValidationFailureReason)
    }
    
    public enum SignatureValidationFailureReason
    {
        case appleIncRootCertificateNotFound
        case unableToLoadAppleIncRootCertificate
        case receiptIsNotSigned
        case receiptSignedDataNotFound
        case invalidSignature
    }
    
    
}
