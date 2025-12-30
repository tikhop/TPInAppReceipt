import Testing
import Foundation
import SwiftASN1

@testable import TPInAppReceipt

@Suite("SwiftASN1ReceiptDecoder Tests")
struct SwiftASN1DecoderTests {

    static let allReceipts = [
        "Assets/receipt-from-known-device",
        "Assets/receipt-crash",
        "Assets/receipt-legacy",
        "Assets/receipt-new",
        "Assets/receipt-no-orig-purchase-date",
        "Assets/receipt-production",
        "Assets/receipt-watch",
        "Assets/receipt-with-transaction"
    ]

    @Test("Decode all receipts successfully", arguments: allReceipts)
    func decodeAllReceipts(receiptPath: String) throws {
        let receiptData = TestingUtility.readReceipt(receiptPath)
        let decoder = SwiftASN1ReceiptDecoder()

        let receipt = try decoder.decode(from: receiptData)

        #expect(receipt.hasValidStructure)
    }

    @Test("Decode throws on malformed data")
    func decodeThrowsOnMalformedData() throws {
        let malformedData = Data([0x01, 0x02, 0x03, 0x04])
        let decoder = SwiftASN1ReceiptDecoder()

        #expect(throws: Error.self) {
            try decoder.decode(from: malformedData)
        }
    }

    @Test("Decode throws on empty data")
    func decodeThrowsOnEmptyData() throws {
        let emptyData = Data()
        let decoder = SwiftASN1ReceiptDecoder()

        #expect(throws: Error.self) {
            try decoder.decode(from: emptyData)
        }
    }
    
    @Test("Decode production receipt")
    func decodeProductionReceipt() throws {
        let receiptData = TestingUtility.readReceipt("Assets/receipt-production")
        let decoder = SwiftASN1ReceiptDecoder()

        let receipt = try decoder.decode(from: receiptData)

        #expect(receipt.hasValidStructure)
        #expect(receipt.environment == .production)
    }

    @Test("Decode xcode receipt")
    func decodeXcodeReceipt() throws {
        let receiptData = TestingUtility.readReceipt("Assets/receipt-no-orig-purchase-date")
        let decoder = SwiftASN1ReceiptDecoder()

        let receipt = try decoder.decode(from: receiptData)

        #expect(receipt.hasValidStructure)
        #expect(receipt.environment == .xcode)
    }

    @Test("Decode sandbox receipt")
    func decodeSandboxReceipt() throws {
        let receiptData = TestingUtility.readReceipt("Assets/receipt-from-known-device")
        let decoder = SwiftASN1ReceiptDecoder()

        let receipt = try decoder.decode(from: receiptData)

        #expect(receipt.hasValidStructure)
        #expect(receipt.environment == .productionSandbox)
    }
}
