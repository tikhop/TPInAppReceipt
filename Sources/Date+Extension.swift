//
//  Date+Extension.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 01/10/16.
//  Copyright © 2016-2021 Pavel Tikhonenko. All rights reserved.
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
    func rfc3339date() -> Date?
    {
        let date = rfc3339DateFormater.date(from: self)
        return date
    }
}

fileprivate var rfc3339DateFormater: ISO8601DateFormatter = {
	let formatter = ISO8601DateFormatter()
	formatter.formatOptions = .withInternetDateTime
	formatter.timeZone = TimeZone(abbreviation: "UTC")
	return formatter
}()
