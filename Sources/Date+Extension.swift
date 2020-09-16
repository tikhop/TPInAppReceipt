//
//  Date+Extension.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 01/10/16.
//  Copyright © 2016-2020 Pavel Tikhonenko. All rights reserved.
//

import Foundation

public extension Date
{
    func rfc3339date(fromString string: String) -> Date?
    {
        return string.rfc3339date()
    }
}

public extension String
{
    func utcTime() -> Date?
    {
        
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.formatOptions = .withInternetDateTime

        let date = formatter.date(from: self)
        return date
    }
    
    func rfc3339date() -> Date?
    {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        formatter.timeZone = TimeZone(abbreviation: "UTC")

        let date = formatter.date(from: self)
        return date
    }
}
