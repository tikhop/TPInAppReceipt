#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension UUID {
    @inlinable
    var data: Data {
        var uuidBytes = uuid
        return Data(bytes: &uuidBytes, count: MemoryLayout.size(ofValue: uuidBytes))
    }
}
