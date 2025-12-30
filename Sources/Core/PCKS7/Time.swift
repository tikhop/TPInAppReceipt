#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import SwiftASN1

/// A time representation in ASN.1 format.
///
/// Time can be represented in either UTC format (for dates up to 2050) or generalized format (for all dates).
public enum Time: Hashable, Sendable {
    /// A UTC time representation.
    case utcTime(UTCTime)

    /// A generalized time representation.
    case generalTime(GeneralizedTime)
}

extension GeneralizedTime {
    @inlinable
    init(_ time: Time) {
        switch time {
        case let .generalTime(t):
            self = t
        case let .utcTime(t):
            // This can never throw, all valid UTCTimes are valid GeneralizedTimes
            self = try! GeneralizedTime(
                year: t.year,
                month: t.month,
                day: t.day,
                hours: t.hours,
                minutes: t.minutes,
                seconds: t.seconds,
                fractionalSeconds: 0
            )
        }
    }

    @inlinable
    init(_ components: (year: Int, month: Int, day: Int, hours: Int, minutes: Int, seconds: Int)) throws {
        try self.init(
            year: components.year,
            month: components.month,
            day: components.day,
            hours: components.hours,
            minutes: components.minutes,
            seconds: components.seconds,
            fractionalSeconds: 0.0
        )
    }
}

extension UTCTime {
    @inlinable
    init(_ components: (year: Int, month: Int, day: Int, hours: Int, minutes: Int, seconds: Int)) throws {
        try self.init(
            year: components.year,
            month: components.month,
            day: components.day,
            hours: components.hours,
            minutes: components.minutes,
            seconds: components.seconds
        )
    }
}
