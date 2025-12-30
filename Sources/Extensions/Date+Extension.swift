#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import SwiftASN1

extension Date {
    static func date(from rfc3339String: String) -> Date? {
        rfc3339DateFormatter.date(from: rfc3339String)
    }
}

nonisolated(unsafe) fileprivate let rfc3339DateFormatter: ISO8601DateFormatter = {
	let formatter = ISO8601DateFormatter()
	formatter.formatOptions = .withInternetDateTime
	formatter.timeZone = TimeZone(abbreviation: "UTC")
	return formatter
}()


