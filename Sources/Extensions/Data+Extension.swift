#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension Data {
    static func readBytes(from url: URL) async throws -> Data {
        try await URLSession.shared.data(from: url).0
    }
}
