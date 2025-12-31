#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import SwiftASN1

public final class SwiftASN1ReceiptDecoder: AppReceiptDecoder.Engine {
    public func decode(from data: Data) throws -> AppReceipt {
        try AppReceipt(berEncoded: try BER.parse(data.bytes))
    }
}
