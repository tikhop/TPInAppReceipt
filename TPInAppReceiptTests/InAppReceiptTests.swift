//
// Created by Marcelo Schroeder on 2/2/17.
// Copyright (c) 2017 Pavel Tikhonenko. All rights reserved.
//

import XCTest
@testable import TPInAppReceipt
import openssl

class InAppReceiptTests: XCTestCase {

    func testActiveAutoRenewableSubscriptionPurchasesWithoutCancellation() {

        // Given
        let purchase1 = InAppPurchase(webOrderLineItemID: 1, originalPurchaseDateString: "2017-02-01T07:03:18Z", purchaseDateString: "2017-02-01T07:03:16Z", subscriptionExpirationDateString: "2017-02-01T07:06:16Z", cancellationDateString: "")
        let purchase2 = InAppPurchase(webOrderLineItemID: 2, originalPurchaseDateString: "2017-02-01T21:26:12Z", purchaseDateString: "2017-02-01T21:26:11Z", subscriptionExpirationDateString: "2017-02-01T21:29:11Z", cancellationDateString: "")
        let purchase3 = InAppPurchase(webOrderLineItemID: 3, originalPurchaseDateString: "2017-02-01T21:28:41Z", purchaseDateString: "2017-02-01T21:29:11Z", subscriptionExpirationDateString: "2017-02-01T21:32:11Z", cancellationDateString: "")
        let receiptPayload: InAppReceiptPayload = InAppReceiptPayload(purchases: [purchase1, purchase2, purchase3])

        // When
        let receipt = InAppReceipt(payload: receiptPayload)

        // Then
        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:03:15Z")!.dateFromISO8601!))
        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:03:16Z")!.dateFromISO8601!))
        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:04:16Z")!.dateFromISO8601!))
        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:06:15Z")!.dateFromISO8601!))
        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:06:16Z")!.dateFromISO8601!))
        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:06:17Z")!.dateFromISO8601!))
        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T21:27:11Z")!.dateFromISO8601!))
        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T21:30:11Z")!.dateFromISO8601!))
        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T21:32:11Z")!.dateFromISO8601!))

    }

    func testActiveAutoRenewableSubscriptionPurchasesWithCancellation() {

        // Given
        let purchase1 = InAppPurchase(webOrderLineItemID: 1, originalPurchaseDateString: "2017-02-01T07:03:18Z", purchaseDateString: "2017-02-01T07:03:16Z", subscriptionExpirationDateString: "2017-02-01T07:06:16Z", cancellationDateString: "")
        let purchase2 = InAppPurchase(webOrderLineItemID: 2, originalPurchaseDateString: "2017-02-01T21:26:12Z", purchaseDateString: "2017-02-01T21:26:11Z", subscriptionExpirationDateString: "2017-02-01T21:29:11Z", cancellationDateString: "2017-02-01T21:27:11Z")
        let purchase3 = InAppPurchase(webOrderLineItemID: 3, originalPurchaseDateString: "2017-02-01T21:28:41Z", purchaseDateString: "2017-02-01T21:29:11Z", subscriptionExpirationDateString: "2017-02-01T21:32:11Z", cancellationDateString: "")
        let receiptPayload: InAppReceiptPayload = InAppReceiptPayload(purchases: [purchase1, purchase2, purchase3])

        // When
        let receipt = InAppReceipt(payload: receiptPayload)

        // Then
        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:04:16Z")!.dateFromISO8601!))
        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T21:28:11Z")!.dateFromISO8601!))
        XCTAssertNotNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T21:30:11Z")!.dateFromISO8601!))

    }

    func testActiveAutoRenewableSubscriptionPurchasesWhenProductIdentifierDoesNotMatch() {

        // Given
        let purchase1 = InAppPurchase(webOrderLineItemID: 1, originalPurchaseDateString: "2017-02-01T07:03:18Z", purchaseDateString: "2017-02-01T07:03:16Z", subscriptionExpirationDateString: "2017-02-01T07:06:16Z", cancellationDateString: "")
        let receiptPayload: InAppReceiptPayload = InAppReceiptPayload(purchases: [purchase1])

        // When
        let receipt = InAppReceipt(payload: receiptPayload)

        // Then
        XCTAssertNil(receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: "test-product-identifier-does-not-match", forDate: String("2017-02-01T07:04:16Z")!.dateFromISO8601!))

    }

    func testHasActiveAutoRenewableSubscription() {

        // Given
        let purchase1 = InAppPurchase(webOrderLineItemID: 1, originalPurchaseDateString: "2017-02-01T07:03:18Z", purchaseDateString: "2017-02-01T07:03:16Z", subscriptionExpirationDateString: "2017-02-01T07:06:16Z", cancellationDateString: "")
        let receiptPayload: InAppReceiptPayload = InAppReceiptPayload(purchases: [purchase1])

        // When
        let receipt = InAppReceipt(payload: receiptPayload)

        // Then
        XCTAssertFalse(receipt.hasActiveAutoRenewableSubscription(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:03:15Z")!.dateFromISO8601!))
        XCTAssertTrue(receipt.hasActiveAutoRenewableSubscription(ofProductIdentifier: "test-product-identifier", forDate: String("2017-02-01T07:03:16Z")!.dateFromISO8601!))

    }

}

fileprivate extension InAppPurchase
{
    init(webOrderLineItemID: Int, originalPurchaseDateString: String, purchaseDateString: String, subscriptionExpirationDateString: String, cancellationDateString: String)
    {
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
        self.payload = payload
        self.pkcs7Container = try! PKCS7WrapperMock()
    }
}

fileprivate extension InAppReceiptPayload
{
    init(purchases: [InAppPurchase])
    {
        self.purchases = purchases
        self.bundleIdentifier = "test-bundle-identifier"
        self.appVersion = ""
        self.originalAppVersion = ""
        self.expirationDate = ""
        self.bundleIdentifierData = Data()
        self.opaqueValue = Data()
        self.receiptHash = Data()
    }
}


fileprivate class PKCS7WrapperMock: PKCS7Wrapper
{
    init() throws
    {
        try super.init(receipt: Data(base64Encoded: "MCcGCSqGSIb3DQEHAqAaMBgCAQExADALBgkqhkiG9w0BBwGgAKEAMQA=")!)
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
