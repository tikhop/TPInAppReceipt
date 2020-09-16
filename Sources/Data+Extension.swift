//
//  Data+Extension.swift
//  TPReceiptValidator
//
//  Created by Pavel Tikhonenko on 29/09/16.
//  Copyright © 2016-2020 Pavel Tikhonenko. All rights reserved.
//

import Foundation
    
extension Data
{
    public var bytes: Array<UInt8>
    {
        return Array(self)
    }
}


