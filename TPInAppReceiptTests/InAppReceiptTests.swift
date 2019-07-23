//
// Created by Marcelo Schroeder on 2/2/17.
// Copyright (c) 2019 Pavel Tikhonenko. All rights reserved.
//

import XCTest
@testable import TPInAppReceipt

class InAppReceiptTests: XCTestCase
{
    override func setUp()
    {
        
    }
    
    func testCrash()
    {
        let r = Data(base64Encoded:  "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")!
        
        let receipt = try! InAppReceipt(receiptData: r)
        print(receipt)
    }
    
//    func testActiveAutoRenewableSubscriptionPurchasesWithoutCancellation()
//    {
//
////        // Given
////        let purchase1 = InAppPurchase(webOrderLineItemID: 1, originalPurchaseDateString: "2017-02-01T07:03:18Z", purchaseDateString: "2017-02-01T07:03:16Z", subscriptionExpirationDateString: "2017-02-01T07:06:16Z", cancellationDateString: "")
////        let /Users/tikhop/Work/TPInAppReceipt/TPInAppReceiptTests/InAppReceiptTests.swiftpurchase2 = InAppPurchase(webOrderLineItemID: 2, originalPurchaseDateString: "2017-02-01T21:26:12Z", purchaseDateString: "2017-02-01T21:26:11Z", subscriptionExpirationDateString: "2017-02-01T21:29:11Z", cancellationDateString: "")
////        let purchase3 = InAppPurchase(webOrderLineItemID: 3, originalPurchaseDateString: "2017-02-01T21:28:41Z", purchaseDateString: "2017-02-01T21:29:11Z", subscriptionExpirationDateString: "2017-02-01T21:32:11Z", cancellationDateString: "")
////        let receiptPayload: InAppReceiptPayload = InAppReceiptPayload(purchases: [purchase1, purchase2, purchase3])
////
////        // When
////        let receipt = InAppReceipt(pkcs7: try! PKCS7WrapperMock())
////
////        // Then
////        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:03:15Z").dateFromISO8601!))
////        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:03:16Z").dateFromISO8601!))
////        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:04:16Z").dateFromISO8601!))
////        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:06:15Z").dateFromISO8601!))
////        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:06:16Z").dateFromISO8601!))
////        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:06:17Z").dateFromISO8601!))
////        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T21:27:11Z").dateFromISO8601!))
////        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T21:30:11Z").dateFromISO8601!))
////        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T21:32:11Z").dateFromISO8601!))
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
//
}
//
//fileprivate extension InAppPurchase
//{
//    init(webOrderLineItemID: Int, originalPurchaseDateString: String, purchaseDateString: String, subscriptionExpirationDateString: String, cancellationDateString: String)
//    {
//        self.init()
//
//        self.productIdentifier = "test-product-identifier"
//        self.transactionIdentifier = "test-transaction-identifier"
//        self.originalTransactionIdentifier = originalPurchaseDateString
//        self.purchaseDateString = purchaseDateString
//        self.originalPurchaseDateString = ""
//        self.subscriptionExpirationDateString = subscriptionExpirationDateString
//        self.cancellationDateString = cancellationDateString
//        self.webOrderLineItemID = webOrderLineItemID
//        self.quantity = 1
//    }
//}
//
//fileprivate extension InAppReceipt
//{
//    init(payload: InAppReceiptPayload)
//    {
//        self.init(pkcs7: try! PKCS7WrapperMock(), payload: payload)
//    }
//}
//
//fileprivate extension InAppReceiptPayload
//{
//    init(purchases: [InAppPurchase])
//    {
//        self.init(bundleIdentifier: "test-bundle-identifier", appVersion: "", originalAppVersion: "", purchases: purchases, expirationDate: "", bundleIdentifierData: Data(), opaqueValue: Data(), receiptHash: Data(), creationDate: "")
//    }
//}
//
//
//fileprivate class PKCS7WrapperMock: PKCS7Wrapper
//{
//    init() throws
//    {
//        try super.init(receipt: Data(base64Encoded: "MCcGCSqGSIb3DQEHAqAaMBgCAQExADALBgkqhkiG9w0BBwGgAKEAMQA=")!)
//    }
//
//}
//
//fileprivate extension Date
//{
//    static let iso8601Formatter: DateFormatter =
//    {
//        let formatter = DateFormatter()
//        formatter.calendar = Calendar(identifier: .iso8601)
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
//        return formatter
//    }()
//
//    var iso8601: String
//    {
//        return Date.iso8601Formatter.string(from: self)
//    }
//}
//
//fileprivate extension String
//{
//    var dateFromISO8601: Date?
//    {
//        return Date.iso8601Formatter.date(from: self)
//    }
//}
