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
    public static func rfc3339date(fromString string: String) -> Date?
    {
        return string.rfc3339date()
    }
}

public extension String
{
    public func rfc3339date() -> Date?
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = formatter.date(from: self)
        return date
    }
}
