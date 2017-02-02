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
///
/// - initializationFailed:                 Error occurs during initialization step
/// - validationFailed:                     Error occurs during the receipt validation process
public enum IARError: Error
{
    case initializationFailed(reason: ReceiptInitializationFailureReason)
    case validationFailed(reason: ValidationFailureReason)
    
    /// The underlying reason the receipt initialization error occurred.
    ///
    /// - appStoreReceiptNotFound:         In-App Receipt not found
    /// - pkcs7ParsingError:               PKCS7 Container can't be extracted from in-app receipt data
    public enum ReceiptInitializationFailureReason
    {
        case appStoreReceiptNotFound
        case pkcs7ParsingError
    }
    
    /// The underlying reason the receipt validation error occurred.
    ///
    /// - hashValidation:          Computed hash doesn't match the hash from the receipt's payload
    /// - signatureValidation:     Error occurs during signature validation. It has several reasons to failure
    public enum ValidationFailureReason
    {
        case hashValidation
        case signatureValidation(SignatureValidationFailureReason)
    }
    
    /// The underlying reason the signature validation error occurred.
    ///
    /// - appleIncRootCertificateNotFound:          Apple Inc Root Certificate Not Found
    /// - unableToLoadAppleIncRootCertificate:      Unable To Load Apple Inc Root Certificate
    /// - receiptIsNotSigned:                       The receipt doesn't contain a signature
    /// - receiptSignedDataNotFound:                The receipt does contain somr signature, but there is an error while creating a signature object
    /// - invalidSignature:                         The receipt contains invalid signature
    public enum SignatureValidationFailureReason
    {
        case appleIncRootCertificateNotFound
        case unableToLoadAppleIncRootCertificate
        case receiptIsNotSigned
        case receiptSignedDataNotFound
        case invalidSignature
    }
}
