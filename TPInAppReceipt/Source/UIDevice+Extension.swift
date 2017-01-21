//
//  UIDevice+Extension.swift
//  TPInAppReceipt
//
//  Created by Pavel Tikhonenko on 20/01/17.
//  Copyright © 2017 Pavel Tikhonenko. All rights reserved.
//

import Foundation

extension TPInAppReceipt.UIDevice
{
    var uuidData: Data
    {
        let uuid = identifierForVendor!
        var uuidBytes = uuid.uuid
        
        return Data(bytes: &uuidBytes, count: MemoryLayout.size(ofValue: uuidBytes))
    }
}
