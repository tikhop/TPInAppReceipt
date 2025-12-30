import Testing
import Foundation
import SwiftASN1

@testable import TPInAppReceipt

@Suite("AppReceiptDecoder Tests")
struct AppReceiptDecoderTests {

    @Test("Default decoder uses SwiftASN1 engine")
    func defaultDecoderUsesSwiftASN1Engine() throws {
        let receiptData = TestingUtility.readReceipt("Assets/receipt-from-known-device")
        let decoder = AppReceiptDecoder.default

        let receipt = try decoder.decode(from: receiptData)

        #expect(receipt.hasValidStructure)
        #expect(!receipt.bundleIdentifier.isEmpty)
    }

    @Test("Static receipt factory method works")
    func staticReceiptFactoryMethod() throws {
        let receiptData = TestingUtility.readReceipt("Assets/receipt-from-known-device")

        let receipt = try AppReceipt.receipt(from: receiptData)

        #expect(receipt.hasValidStructure)
        #expect(!receipt.bundleIdentifier.isEmpty)
    }

    @Test("Decode throws on invalid data")
    func decodeThrowsOnInvalidData() throws {
        let invalidData = Data("invalid receipt data".utf8)
        let decoder = AppReceiptDecoder.default

        #expect(throws: Error.self) {
            try decoder.decode(from: invalidData)
        }
    }

    @Test("Decode throws on empty data")
    func decodeThrowsOnEmptyData() throws {
        let emptyData = Data()
        let decoder = AppReceiptDecoder.default

        #expect(throws: Error.self) {
            try decoder.decode(from: emptyData)
        }
    }

    @Test("Custom engine is called during decode")
    func customEngineIsCalled() throws {
        final class MockEngine: AppReceiptDecoder.Engine {
            nonisolated(unsafe) var decodeCalled = false

            func decode(from data: Data) throws -> AppReceipt {
                decodeCalled = true
                return try AppReceipt(berEncoded: try BER.parse(data.bytes))
            }
        }

        let mockEngine = MockEngine()
        let decoder = AppReceiptDecoder(engine: mockEngine)
        let receiptData = TestingUtility.readReceipt("Assets/receipt-from-known-device")

        _ = try decoder.decode(from: receiptData)

        #expect(mockEngine.decodeCalled)
    }
}
