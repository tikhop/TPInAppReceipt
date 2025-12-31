#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension UUID {
    var data: Data {
        var uuidBytes = self.uuid
        return Data(bytes: &uuidBytes, count: MemoryLayout.size(ofValue: uuidBytes))
    }
}
