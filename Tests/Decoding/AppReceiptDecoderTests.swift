import Foundation
import SwiftASN1
import Testing

@testable import TPInAppReceipt

@Suite("AppReceiptDecoder")
struct AppReceiptDecoderTests {
    @Test
    func defaultDecoderDecodesReceipt() throws {
        let receiptData = TestingUtility.readReceipt("Assets/receipt-from-known-device")
        let decoder = AppReceiptDecoder.default

        let receipt = try decoder.decode(from: receiptData)

        #expect(receipt.hasValidStructure)
        #expect(!receipt.bundleIdentifier.isEmpty)
    }

    @Test
    func staticReceiptFactoryMethod() throws {
        let receiptData = TestingUtility.readReceipt("Assets/receipt-from-known-device")

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
        let receiptData = TestingUtility.readReceipt("Assets/receipt-from-known-device")

        _ = try decoder.decode(from: receiptData)

        #expect(mockEngine.decodeCalled)
    }
}
