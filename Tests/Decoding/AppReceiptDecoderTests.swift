import Foundation
import SwiftASN1
import Testing

@testable import TPInAppReceipt

@Suite("AppReceiptDecoder")
struct AppReceiptDecoderTests {

    @Test
    func staticReceiptFactoryMethod() throws {
        let receiptData = TestingUtility.readReceipt("Assets/receipt-sandbox-g5")
        let receipt = try AppReceipt.receipt(from: receiptData)

        #expect(receipt.hasValidStructure)
        #expect(!receipt.bundleIdentifier.isEmpty)
    }

    @Test
    func decodeThrowsOnInvalidData() throws {
        let invalidData = Data("invalid receipt data".utf8)
        let decoder = AppReceiptDecoder.default

        #expect(throws: Error.self) {
            try decoder.decode(from: invalidData)
        }
    }

    @Test
    func decodeThrowsOnEmptyData() throws {
        let emptyData = Data()
        let decoder = AppReceiptDecoder.default

        #expect(throws: Error.self) {
            try decoder.decode(from: emptyData)
        }
    }

    static let allReceiptPaths = [
        "Assets/receipt-sandbox-g5",
        "Assets/receipt-production",
        "Assets/receipt-sandbox-legacy",
        "Assets/receipt-xcode",
        "Assets/receipt-xcode-with-purchases",
    ]

    @Test(arguments: allReceiptPaths)
    func defaultDecoderDecodesAllReceipts(path: String) throws {
        let receiptData = TestingUtility.readReceipt(path)
        let decoder = AppReceiptDecoder.default

        let receipt = try decoder.decode(from: receiptData)

        #expect(receipt.hasValidStructure)
        #expect(!receipt.bundleIdentifier.isEmpty)
    }

    @Test
    func customEngineIsCalled() throws {
        final class MockEngine: AppReceiptDecoder.Engine {
            nonisolated(unsafe) var decodeCalled = false

            func decode(from data: Data) throws -> AppReceipt {
                decodeCalled = true
                return try AppReceipt(berEncoded: BER.parse(data.bytes))
            }
        }

        let mockEngine = MockEngine()
        let decoder = AppReceiptDecoder(engine: mockEngine)
        let receiptData = TestingUtility.readReceipt("Assets/receipt-sandbox-g5")

        _ = try decoder.decode(from: receiptData)

        #expect(mockEngine.decodeCalled)
    }
}
