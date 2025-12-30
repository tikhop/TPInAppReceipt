import Foundation
import SwiftASN1
import Testing

@testable import TPInAppReceipt

@Suite("SwiftASN1ReceiptDecoder")
struct SwiftASN1DecoderTests {
    struct ReceiptTestCase: Sendable, CustomTestStringConvertible {
        let path: String
        let expectedEnvironment: InAppReceiptPayload.Environment?

        var testDescription: String { path }
    }

    static let allReceipts: [ReceiptTestCase] = [
        .init(path: "Assets/receipt-from-known-device", expectedEnvironment: .productionSandbox),
        .init(path: "Assets/receipt-production", expectedEnvironment: .production),
        .init(path: "Assets/receipt-no-orig-purchase-date", expectedEnvironment: .xcode),
        .init(path: "Assets/receipt-crash", expectedEnvironment: nil),
        .init(path: "Assets/receipt-legacy", expectedEnvironment: nil),
        .init(path: "Assets/receipt-new", expectedEnvironment: nil),
        .init(path: "Assets/receipt-watch", expectedEnvironment: nil),
        .init(path: "Assets/receipt-with-transaction", expectedEnvironment: nil),
    ]

    @Test(arguments: allReceipts)
    func decodeReceipt(testCase: ReceiptTestCase) throws {
        let receiptData = TestingUtility.readReceipt(testCase.path)
        let decoder = SwiftASN1ReceiptDecoder()

        let receipt = try decoder.decode(from: receiptData)

        #expect(receipt.hasValidStructure)
        if let expected = testCase.expectedEnvironment {
            #expect(receipt.environment == expected)
        }
    }

    @Test
    func decodeThrowsOnMalformedData() throws {
        let malformedData = Data([0x01, 0x02, 0x03, 0x04])
        let decoder = SwiftASN1ReceiptDecoder()

        #expect(throws: Error.self) {
            try decoder.decode(from: malformedData)
        }
    }
}
