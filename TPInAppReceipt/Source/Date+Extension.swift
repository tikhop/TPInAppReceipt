//
//  Date+Extension.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 01/10/16.
//  Copyright © 2016 Pavel Tikhonenko. All rights reserved.
//

import Foundation

public extension Date
{
    public static func date(fromString string: String, dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'", timeZone: TimeZone = TimeZone.autoupdatingCurrent) -> Date?
    {
        return string.date(withDateFormat: dateFormat, timeZone: timeZone)
    }
}

public extension String
{
    public func date(withDateFormat dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'", timeZone: TimeZone = TimeZone.autoupdatingCurrent) -> Date
    {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = timeZone
        
        let date = formatter.date(from: self)
        return date!
    }
}
