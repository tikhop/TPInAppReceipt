//
// Created by Marcelo Schroeder on 2/2/17.
// Copyright (c) 2017 Pavel Tikhonenko. All rights reserved.
//

import XCTest
@testable import TPInAppReceipt

class InAppReceiptTests: XCTestCase
{
    override func setUp()
    {
        
    }
    
    func testNoOpenssl()
    {
        
        let oid = Data(base64Encoded: "BgsqhkiG9/f3DQEHAg==")!
        let asn1 = ASN1Object(data: oid)
        var d = asn1.valueData!
        let r = ASN1.readOid(contentData: &d)
        print(r)
//        
//        let r = Data(base64Encoded: receiptString64)!
//        
//        let asn1Object = ASN1Object(data: r)
//        
//        for item in asn1Object.enumerated()
//        {
//            print(item.element)
//        }
//
//        r.enumerateASN1AttributesNoOpenssl(withBlock: { (attribute) in
//
//        })
//
//        
//        
////
        let receipt = try! InAppReceipt(receiptData: Data(base64Encoded: receiptString64)!)
        let data = receipt.pkcs7Container.extractInAppPayload()
        print(receipt.creationDate)
//        self.measure
//        {
//            try? receipt.verifyHashNoOpenssl()
//        }
    }
//    
//    func test()
//    {
//        let receipt = InAppReceipt(pkcs7: p, payload: InAppReceiptPayload(asn1Data: asn1))
//
//        self.measure
//        {
//            try? receipt.verifyHash()
//        }
//    }
    
//    func testActiveAutoRenewableSubscriptionPurchasesWithoutCancellation() {
//
//        // Given
//        let purchase1 = InAppPurchase(webOrderLineItemID: 1, originalPurchaseDateString: "2017-02-01T07:03:18Z", purchaseDateString: "2017-02-01T07:03:16Z", subscriptionExpirationDateString: "2017-02-01T07:06:16Z", cancellationDateString: "")
//        let purchase2 = InAppPurchase(webOrderLineItemID: 2, originalPurchaseDateString: "2017-02-01T21:26:12Z", purchaseDateString: "2017-02-01T21:26:11Z", subscriptionExpirationDateString: "2017-02-01T21:29:11Z", cancellationDateString: "")
//        let purchase3 = InAppPurchase(webOrderLineItemID: 3, originalPurchaseDateString: "2017-02-01T21:28:41Z", purchaseDateString: "2017-02-01T21:29:11Z", subscriptionExpirationDateString: "2017-02-01T21:32:11Z", cancellationDateString: "")
//        let receiptPayload: InAppReceiptPayload = InAppReceiptPayload(purchases: [purchase1, purchase2, purchase3])
//
//        // When
//        let receipt = InAppReceipt(pkcs7: try! PKCS7WrapperMock())
//
//        // Then
//        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:03:15Z").dateFromISO8601!))
//        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:03:16Z").dateFromISO8601!))
//        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:04:16Z").dateFromISO8601!))
//        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:06:15Z").dateFromISO8601!))
//        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:06:16Z").dateFromISO8601!))
//        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:06:17Z").dateFromISO8601!))
//        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T21:27:11Z").dateFromISO8601!))
//        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T21:30:11Z").dateFromISO8601!))
//        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T21:32:11Z").dateFromISO8601!))
//
//    }
//
//    func testEmptyAutoRenewableSubscriptionExpirationDate()
//    {
//
//        // Given
//        let purchase1 = InAppPurchase(webOrderLineItemID: 1, originalPurchaseDateString: "2017-02-01T07:03:18Z", purchaseDateString: "2017-02-01T07:03:16Z", subscriptionExpirationDateString: "", cancellationDateString: "")
//
//        XCTAssertNil(purchase1.subscriptionExpirationDate)
//    }
//
//    func testActiveAutoRenewableSubscriptionPurchasesWithCancellation() {
//
//        // Given
//        let purchase1 = InAppPurchase(webOrderLineItemID: 1, originalPurchaseDateString: "2017-02-01T07:03:18Z", purchaseDateString: "2017-02-01T07:03:16Z", subscriptionExpirationDateString: "2017-02-01T07:06:16Z", cancellationDateString: "")
//        let purchase2 = InAppPurchase(webOrderLineItemID: 2, originalPurchaseDateString: "2017-02-01T21:26:12Z", purchaseDateString: "2017-02-01T21:26:11Z", subscriptionExpirationDateString: "2017-02-01T21:29:11Z", cancellationDateString: "2017-02-01T21:27:11Z")
//        let purchase3 = InAppPurchase(webOrderLineItemID: 3, originalPurchaseDateString: "2017-02-01T21:28:41Z", purchaseDateString: "2017-02-01T21:29:11Z", subscriptionExpirationDateString: "2017-02-01T21:32:11Z", cancellationDateString: "")
//        let receiptPayload: InAppReceiptPayload = InAppReceiptPayload(purchases: [purchase1, purchase2, purchase3])
//
//        // When
//        let receipt = InAppReceipt(payload: receiptPayload)
//
//        // Then
//        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:04:16Z").dateFromISO8601!))
//        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T21:28:11Z").dateFromISO8601!))
//        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T21:30:11Z").dateFromISO8601!))
//
//    }
//
//    func testActiveAutoRenewableSubscriptionPurchasesWhenProductIdentifierDoesNotMatch() {
//
//        // Given
//        let purchase1 = InAppPurchase(webOrderLineItemID: 1, originalPurchaseDateString: "2017-02-01T07:03:18Z", purchaseDateString: "2017-02-01T07:03:16Z", subscriptionExpirationDateString: "2017-02-01T07:06:16Z", cancellationDateString: "")
//        let receiptPayload: InAppReceiptPayload = InAppReceiptPayload(purchases: [purchase1])
//
//        // When
//        let receipt = InAppReceipt(payload: receiptPayload)
//
//        // Then
//        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier-does-not-match", forDate: String("2017-02-01T07:04:16Z").dateFromISO8601!))
//
//    }
//
//    func testHasActiveAutoRenewableSubscription() {
//
//        // Given
//        let purchase1 = InAppPurchase(webOrderLineItemID: 1, originalPurchaseDateString: "2017-02-01T07:03:18Z", purchaseDateString: "2017-02-01T07:03:16Z", subscriptionExpirationDateString: "2017-02-01T07:06:16Z", cancellationDateString: "")
//        let receiptPayload: InAppReceiptPayload = InAppReceiptPayload(purchases: [purchase1])
//
//        // When
//        let receipt = InAppReceipt(payload: receiptPayload)
//
//        // Then
//        XCTAssertFalse(receipt.hasActiveAutoRenewableSubscription(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:03:15Z").dateFromISO8601!))
//        XCTAssertTrue(receipt.hasActiveAutoRenewableSubscription(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:03:16Z").dateFromISO8601!))
//
//    }

}

fileprivate extension InAppPurchase
{
    init(webOrderLineItemID: Int, originalPurchaseDateString: String, purchaseDateString: String, subscriptionExpirationDateString: String, cancellationDateString: String)
    {
        self.init(asn1Data: Data())
        
        self.productIdentifier = "test-product-identifier"
        self.transactionIdentifier = "test-transaction-identifier"
        self.originalTransactionIdentifier = originalPurchaseDateString
        self.purchaseDateString = purchaseDateString
        self.originalPurchaseDateString = ""
        self.subscriptionExpirationDateString = subscriptionExpirationDateString
        self.cancellationDateString = cancellationDateString
        self.webOrderLineItemID = webOrderLineItemID
        self.quantity = 1
        
        
    }
}

fileprivate extension InAppReceipt
{
    init(payload: InAppReceiptPayload)
    {
        self.init(pkcs7: try! PKCS7WrapperMock(), payload: payload)
    }
}

fileprivate extension InAppReceiptPayload
{
    init(purchases: [InAppPurchase])
    {
        self.init(bundleIdentifier: "test-bundle-identifier", appVersion: "", originalAppVersion: "", purchases: purchases, expirationDate: "", bundleIdentifierData: Data(), opaqueValue: Data(), receiptHash: Data(), creationDate: "")
    }
}


fileprivate class PKCS7WrapperMock: PKCS7Wrapper
{
    init() throws
    {
        try super.init(receipt: Data(base64Encoded: receiptString64)!)
    }

}

fileprivate extension Date
{
    static let iso8601Formatter: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }()
    
    var iso8601: String
    {
        return Date.iso8601Formatter.string(from: self)
    }
}

fileprivate extension String
{
    var dateFromISO8601: Date?
    {
        return Date.iso8601Formatter.date(from: self)
    }
}











let receiptString64: String = "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"
