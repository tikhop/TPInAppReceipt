#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import SwiftASN1

public final class SwiftASN1ReceiptDecoder: AppReceiptDecoder.Engine {
    public func decode(from data: Data) throws -> AppReceipt {
        try AppReceipt(berEncoded: data)
    }
}

extension BERParseable {
    public init(berEncoded data: Data) throws {
        try self.init(berEncoded: data.bytes)
    }
}

extension DERParseable {
    public init(derEncoded data: Data) throws {
        try self.init(derEncoded: data.bytes)
    }
}

extension Data {
    fileprivate var bytes: [UInt8] {
        Array(self)
    }
}
